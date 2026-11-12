#!/usr/bin/env bash
# bench-lint.sh: lint output for the benchmark's round 2 (lab ADR-0013).
#
#   uat/bench-lint.sh RUN_DIR [--jobs N] [--cases ID,ID]
#
# For each case in RUN_DIR (checked out by uat/bench.sh in .cache/bench-repos),
# lints the files the change touched, at head, and writes
# RUN_DIR/<case>/lint.{json,sarif} plus lint.status ("ok <n>", "none: <why>"
# or "failed: <why>"). Vizzini filters the diagnostics to changed lines.
#
# Static linters only, the same configuration for every case, never the
# projects' own configs or plugins, and nothing from a project is built or
# run:
#   Go          golangci-lint (default linters, --no-config). Type-checking
#               needs the changed packages' dependencies: `go list` fetches
#               them first through the Go module proxy (network on; it runs
#               no project code), then the lint runs with no network.
#   Python      ruff --isolated, rules E4,E7,E9,F (ruff's defaults) and B
#   JS/TS       ESLint 9 with bench/eslint (recommended rules, no type info)
#   C#, Rust    none: their analyzers (Roslyn, clippy) need a build
#   seeded      csharp-seeded and ts-seeded: the fixtures' own Roslyn and
#               ESLint SARIF (uat/fixture.sh, built from lab code);
#               ctx-seeded: golangci-lint as above
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
run=${1:?usage: bench-lint.sh RUN_DIR [--jobs N]}
shift
jobs=3 only=""
while (($#)); do
	case $1 in
	--jobs) jobs=${2:?}; shift 2 ;;
	--cases) only=${2:?}; shift 2 ;;
	*) printf 'bench-lint: unknown argument %s\n' "$1" >&2; exit 1 ;;
	esac
done
repos="$root/.cache/bench-repos"
mkdir -p "$root/.cache/gomod" "$root/.cache/bench-eslint"
if [[ ! -d $root/.cache/bench-eslint/node_modules ]]; then
	cp "$root/bench/eslint/package.json" "$root/bench/eslint/package-lock.json" "$root/bench/eslint/eslint.config.mjs" "$root/.cache/bench-eslint/"
	podman run --rm -v "$root/.cache/bench-eslint:/tool:Z" -v "$root/.cache/npm:/npm-cache:Z" -w /tool \
		-e npm_config_cache=/npm-cache -e npm_config_update_notifier=false "$NODE_IMAGE" \
		npm ci --no-audit --no-fund --ignore-scripts --loglevel=error
fi

# lint_case ID: one case's lint.
lint_case() {
	local id=$1 dir="$repos/$1" out="$run/$1" files
	[[ -d $dir ]] || { echo "none: no checkout" >"$out/lint.status"; return 0; }
	files="$(git -C "$dir" diff --name-only --diff-filter=AM base head)"
	case $id in
	csharp-seeded | ts-seeded)
		local tmp="$root/.cache/bench-fixture-$id"
		rm -rf "$tmp" "$tmp".*
		if "$root/uat/fixture.sh" "$id" "$tmp" >"$out/lint.log" 2>&1; then
			# Make the SARIF's absolute file URIs relative to the repository.
			python3 -I - "$tmp.sarif" "$tmp" "$out/lint.sarif" <<'EOF'
import json, sys
src, base, dst = sys.argv[1:]
s = open(src).read().replace("file://" + base + "/", "").replace(base + "/", "")
json.dump(json.loads(s), open(dst, "w"))
EOF
			echo "ok $(python3 -I -c 'import json,sys; print(sum(len(r.get("results", [])) for r in json.load(open(sys.argv[1]))["runs"]))' "$out/lint.sarif")" >"$out/lint.status"
		else
			echo "failed: fixture lint (see lint.log)" >"$out/lint.status"
		fi
		rm -rf "$tmp" "$tmp".*
		return 0
		;;
	esac
	local go py js
	go="$(grep -E '\.go$' <<<"$files" || true)"
	py="$(grep -E '\.py$' <<<"$files" || true)"
	js="$(grep -E '\.(js|mjs|cjs|jsx|ts|mts|cts|tsx)$' <<<"$files" | grep -v '\.d\.ts$' || true)"
	if [[ -n $go ]]; then
		lint_go "$id" "$dir" "$out" "$go"
	elif [[ -n $py ]]; then
		set +e
		# shellcheck disable=SC2086 # one argument per file
		podman run --rm --network none -v "$dir:/src:ro,Z" -w /src "$RUFF_IMAGE" \
			check --isolated --no-cache --select E4,E7,E9,F,B --output-format sarif --exit-zero $py >"$out/lint.sarif" 2>"$out/lint.log"
		local rc=$?
		set -e
		[[ $rc == 0 && -s $out/lint.sarif ]] && echo "ok $(sarif_count "$out/lint.sarif")" >"$out/lint.status" || echo "failed: ruff exited $rc" >"$out/lint.status"
	elif [[ -n $js ]]; then
		set +e
		# shellcheck disable=SC2086 # one argument per file
		podman run --rm --network none -v "$dir:/src:ro,Z" -v "$root/.cache/bench-eslint:/tool:ro,Z" -v "$out:/out:Z" -w /src "$NODE_IMAGE" \
			/tool/node_modules/.bin/eslint --no-config-lookup -c /tool/eslint.config.mjs --no-warn-ignored \
			-f /tool/node_modules/@microsoft/eslint-formatter-sarif/sarif.js -o /out/lint.sarif $js >"$out/lint.log" 2>&1
		local rc=$?
		set -e
		if ((rc <= 1)) && [[ -s $out/lint.sarif ]]; then
			python3 -I - "$out/lint.sarif" <<'EOF'
import json, sys
p = sys.argv[1]
s = open(p).read().replace("file:///src/", "")
json.dump(json.loads(s), open(p, "w"))
EOF
			echo "ok $(sarif_count "$out/lint.sarif")" >"$out/lint.status"
		else
			echo "failed: eslint exited $rc" >"$out/lint.status"
		fi
	else
		echo "none: no linter for $(sed -E 's/.*\.//' <<<"$files" | sort -u | tr '\n' ' ')" >"$out/lint.status"
	fi
}

sarif_count() { python3 -I -c 'import json,sys; print(sum(len(r.get("results", [])) for r in json.load(open(sys.argv[1]))["runs"]))' "$1"; }

# lint_go ID DIR OUT FILES: golangci-lint per Go module, on the changed
# packages; the issues of all modules merged into OUT/lint.json with
# repository-relative paths.
lint_go() {
	local id=$1 dir=$2 out=$3 files=$4 mods mod pkgs rc failed=""
	# A build cache per case, removed afterwards: large modules fill a disk.
	local cache="$root/.cache/golint-$id"
	rm -rf "$cache"
	mkdir -p "$cache/go" "$cache/lint" "$cache/tmp"
	mods="$(while read -r f; do
		d=$(dirname "$f")
		while [[ $d != . && ! -f $dir/$d/go.mod ]]; do d=$(dirname "$d"); done
		echo "$d"
	done <<<"$files" | sort -u)"
	: >"$out/lint.log"
	rm -f "$out"/lint-*.json
	local n=0
	for mod in $mods; do
		[[ -f $dir/$mod/go.mod ]] || continue
		n=$((n + 1))
		pkgs="$(while read -r f; do
			[[ $f == "$mod"/* || $mod == . ]] || continue
			rel=${f#"$mod"/}
			[[ $mod == . ]] && rel=$f
			echo "./$(dirname "$rel")"
		done <<<"$files" | sort -u | tr '\n' ' ')"
		local goenv=(-e GOMODCACHE=/gomod -e GOCACHE=/cache/go -e GOLANGCI_LINT_CACHE=/cache/lint -e GOTMPDIR=/cache/tmp -e TMPDIR=/cache/tmp
			-e GOFLAGS=-mod=mod -e GOTOOLCHAIN=auto)
		local mounts=(-v "$dir:/src:ro,Z" -v "$root/.cache/gomod:/gomod:Z" -v "$cache:/cache:Z")
		set +e
		# shellcheck disable=SC2086 # one argument per package
		timeout 1200 podman run --rm "${mounts[@]}" "${goenv[@]}" -w "/src/$mod" "$GOLANGCI_LINT_IMAGE" \
			go list -e -deps -test $pkgs >/dev/null 2>>"$out/lint.log"
		# shellcheck disable=SC2086
		timeout 1200 podman run --rm --network none "${mounts[@]}" "${goenv[@]}" -e GOPROXY=off -w "/src/$mod" "$GOLANGCI_LINT_IMAGE" \
			golangci-lint run --no-config --output.json.path stdout --output.text.path stderr --issues-exit-code 0 \
			--max-issues-per-linter 0 --max-same-issues 0 $pkgs >"$out/lint-$n.json" 2>>"$out/lint.log"
		rc=$?
		set -e
		[[ $rc == 0 ]] || failed="$failed $mod:$rc"
		printf '%s\n' "$mod" >"$out/lint-$n.mod"
	done
	echo '{"Issues": []}' >"$out/lint.json"
	python3 -I - "$out" "$n" <<'EOF' || failed="$failed report-unparsable"
import json, os, sys
out, n = sys.argv[1], int(sys.argv[2])
issues = []
for i in range(1, n + 1):
    mod = open(os.path.join(out, f"lint-{i}.mod")).read().strip()
    # golangci-lint v2 may print more than one JSON document: the first holds
    # the issues. A report that does not parse fails the lint (exit 3).
    try:
        doc, _ = json.JSONDecoder().raw_decode(open(os.path.join(out, f"lint-{i}.json")).read().lstrip())
    except (OSError, ValueError):
        sys.exit(3)
    for it in doc.get("Issues") or []:
        fn = it["Pos"]["Filename"]
        if mod != "." and not fn.startswith(mod + "/"):
            it["Pos"]["Filename"] = mod + "/" + fn
        issues.append(it)
json.dump({"Issues": issues}, open(os.path.join(out, "lint.json"), "w"))

EOF
	local count
	count="$(python3 -I -c 'import json,sys; print(len(json.load(open(sys.argv[1]))["Issues"]))' "$out/lint.json")"
	rm -f "$out"/lint-*.json "$out"/lint-*.mod
	chmod -R u+w "$cache" 2>/dev/null || true
	rm -rf "$cache"
	# golangci-lint reports a package it could not type-check as an issue in
	# its text output only: that is a failed lint, not a clean one.
	if grep -q '(typecheck)' "$out/lint.log"; then
		failed="$failed typecheck"
	fi
	if [[ -n $failed ]]; then echo "failed:$failed ($count issues from the rest)" >"$out/lint.status"; else echo "ok $count" >"$out/lint.status"; fi
}

export -f lint_case lint_go sarif_count
export run repos root NODE_IMAGE RUFF_IMAGE GOLANGCI_LINT_IMAGE
cases="$run/cases.all.tsv"
[[ -s $cases ]] || cases="$run/cases.tsv"
# shellcheck disable=SC2016 # the child bash expands $1
cut -f1 "$cases" | { if [[ -n $only ]]; then grep -xF -f <(tr ',' '\n' <<<"$only"); else cat; fi; } |
	xargs -P "$jobs" -I{} bash -c 'lint_case "$1"' _ {}
while IFS=$'\t' read -r c _; do printf '   %-44s %s\n' "$c" "$(cat "$run/$c/lint.status" 2>/dev/null || echo missing)"; done <"$cases"
