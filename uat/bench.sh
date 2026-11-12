#!/usr/bin/env bash
# shellcheck disable=SC2030,SC2031 # each subshell sets its own model's environment
# bench.sh: the head-to-head review benchmark (Vizzini ISSUE-022): Vizzini
# and PR-Agent review the same diffs with the same models, through the same
# LiteLLM proxy. uat/bench.py scores the run.
#
#   uat/bench.sh [--round 1|2|3] [--models "M1 M2"] [--cases ID,ID|seeded|real|all] [--jobs N]
#
# Rounds (the same cases, models and checkouts each time):
#   1  the tools below: equal inputs, the diff and the checkout
#   2  vizzini-lint: round 1's vizzini plus --lint-json, from
#      uat/bench-lint.sh (run it first). PR-Agent has no lint input.
#   3  vizzini-lint-kb: round 2 plus --knowledge, the project's OKF wiki
#      (bench/knowledge/<owner>__<repo>/.okfw for real cases, written blind
#      from the project's docs at its earliest base; the fixture's own .okfw
#      for seeded ones). pa-review-kb / pa-improve-kb: PR-Agent with the same
#      wiki's text as its extra_instructions.
#   A case with no lint (round 2) or no wiki (round 3) keeps the previous
#   round's output, copied, with a .carried marker.
#
# Cases:
#   seeded   fixtures/{csharp,ts,ctx}-seeded: base/ then change/, as one diff
#            (ctx-seeded holds defects visible only outside the diff)
#   real     bench/cases.json: pinned commits from permissively licensed
#            projects, a real bug-introducing change (or a clean one) each,
#            fetched from their public repositories at the pinned SHAs
#
# Tools, per case and model, all from the head checkout:
#   vizzini          pr-review --mode review --repo . (definitions and callers)
#   vizzini-norepo   pr-review --mode review, the diff only
#   pa-review        PR-Agent review   (its local git provider, default config)
#   pa-improve       PR-Agent improve  (same)
# PR-Agent runs in its published image, pinned by digest (versions.env), with
# the case's checkout mounted, so it reads the changed files in full, as it
# does on a forge. Neither tool gets lint output or a knowledge base: the
# inputs are the same for both.
#
# The repositories are untrusted data: nothing from them is built or run;
# the tools only read them.
#
# Writes .cache/runs/<UTC>-bench/<case>/<model>/<tool>.{json,log,time}.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
bin="$root/.cache/bin"
repos="$root/.cache/bench-repos"

say() { printf '\n== %s\n' "$*"; }
die() { printf 'bench: %s\n' "$*" >&2; exit 1; }

models="claude-sonnet-5-5 claude-opus-5-5" sel=all jobs=3 round=1
while (($#)); do
	case $1 in
	--round) round=${2:?}; shift 2 ;;
	--models) models=${2:?}; shift 2 ;;
	--cases) sel=${2:?}; shift 2 ;;
	--jobs) jobs=${2:?}; shift 2 ;;
	*) die "unknown argument $1" ;;
	esac
done
[[ -x $bin/pr-review ]] || die "$bin/pr-review missing; run uat/build.sh"
[[ -n ${PR_AGENT_IMAGE:-} ]] || die "PR_AGENT_IMAGE is not set in versions.env"
"$root/litellm/litellm.sh" status >/dev/null || die "LiteLLM is not running: litellm/litellm.sh up"
podman image exists "$PR_AGENT_IMAGE" || podman pull -q "$PR_AGENT_IMAGE" >/dev/null

run="${BENCH_RUN:-$root/.cache/runs/$(date -u +%Y%m%dT%H%M%SZ)-bench}"
mkdir -p "$run" "$repos"
# Never fetch LFS objects from the cases' repositories.
export GIT_LFS_SKIP_SMUDGE=1
cp "$bin/build-manifest.json" "$run/"
echo "run: $run"
printf '%s\n' "$PR_AGENT_IMAGE" >"$run/pr-agent-image"

# The case list: id, kind (seeded|real).
python3 -I - "$root" "$sel" >"$run/cases.tsv" <<'EOF'
import json, os, sys
root, sel = sys.argv[1:]
seeded = ["csharp-seeded", "ts-seeded", "ctx-seeded"]
real = [c["id"] for c in json.load(open(os.path.join(root, "bench", "cases.json")))["cases"]] \
    if os.path.exists(os.path.join(root, "bench", "cases.json")) else []
want = seeded + real if sel == "all" else seeded if sel == "seeded" else real if sel == "real" else sel.split(",")
for c in want:
    if c not in seeded + real:
        sys.exit(f"bench: unknown case {c}")
    print(f"{c}\t{'seeded' if c in seeded else 'real'}")
EOF
# A run directory given again (BENCH_RUN) keeps its earlier cases.
if [[ -s $run/cases.all.tsv ]]; then sort -u "$run/cases.all.tsv" "$run/cases.tsv" -o "$run/cases.all.tsv"; else cp "$run/cases.tsv" "$run/cases.all.tsv"; fi
echo "   $(wc -l <"$run/cases.tsv") cases; models: $models; PR-Agent: $PR_AGENT_IMAGE"

# checkout ID KIND: the case's repository at head, with the branch "base" at
# the reviewed change's base, and its diff in $run/ID/change.patch.
checkout() {
	local id=$1 kind=$2 dir="$repos/$1"
	if [[ $kind == seeded ]]; then
		rm -rf "$dir"
		git init -q -b base "$dir"
		cp -r "$root/fixtures/$id/base/." "$dir/"
		git -C "$dir" add -A
		git -C "$dir" -c user.name=vizzini-lab -c user.email=uat@example.invalid commit -qm base
		git -C "$dir" checkout -qb head
		cp -r "$root/fixtures/$id/change/." "$dir/"
		git -C "$dir" add -A
		git -C "$dir" -c user.name=vizzini-lab -c user.email=uat@example.invalid commit -qm change
	else
		local url base head
		read -r url base head < <(python3 -I -c '
import json, sys
c = next(c for c in json.load(open(sys.argv[1]))["cases"] if c["id"] == sys.argv[2])
print(c["repo"], c["base"], c["head"])' "$root/bench/cases.json" "$id")
		if [[ $(git -C "$dir" rev-parse -q --verify head 2>/dev/null) != "$head" ]]; then
			rm -rf "$dir"
			git init -q -b head "$dir"
			# No hooks, no filters, no submodules: only the two commits' trees.
			git -C "$dir" -c protocol.version=2 fetch -q --no-tags --depth 2 "$url" "$head" ||
				git -C "$dir" fetch -q --no-tags "$url" "$head"
			git -C "$dir" -c advice.detachedHead=false checkout -q -B head "$head"
			git -C "$dir" cat-file -e "$base^{commit}" 2>/dev/null || git -C "$dir" fetch -q --no-tags --depth 1 "$url" "$base"
			git -C "$dir" branch -f base "$base"
		fi
	fi
	git -C "$dir" checkout -q head
	git -C "$dir" clean -fdq
	mkdir -p "$run/$id"
	git -C "$dir" diff base head >"$run/$id/change.patch"
	git -C "$dir" diff --shortstat base head >"$run/$id/diffstat"
}

# timed OUT CMD...: run CMD, its stdout to OUT.json, stderr to OUT.log, and
# its exit code and wall time to OUT.time.
timed() {
	local out=$1 start rc=0
	shift
	start=$(date +%s.%N)
	"$@" >"$out.json" 2>"$out.log" || rc=$?
	python3 -I -c 'import sys,time; print(sys.argv[1], round(time.time() - float(sys.argv[2]), 1))' "$rc" "$start" >"$out.time"
}

key="$(cat "$root/.cache/litellm/master.key")"
proxy="http://127.0.0.1:${LITELLM_PORT:-4000}/v1"

# pa DIR MODEL CMD OUT [KNOWLEDGE_TEXT_FILE]: PR-Agent CMD on the checkout
# DIR. Its JSON report goes to OUT.json (the CLI's stdout to OUT.log). With a
# knowledge file, its text becomes both commands' extra_instructions.
pa() {
	local dir=$1 model=$2 cmd=$3 out=$4 kb=${5:-} start rc=0
	start=$(date +%s.%N)
	mkdir -p "$(dirname "$out")/pa-out"
	local extra=()
	if [[ -n $kb ]]; then
		PR_REVIEWER__EXTRA_INSTRUCTIONS="$(<"$kb")"
		PR_CODE_SUGGESTIONS__EXTRA_INSTRUCTIONS="$PR_REVIEWER__EXTRA_INSTRUCTIONS"
		export PR_REVIEWER__EXTRA_INSTRUCTIONS PR_CODE_SUGGESTIONS__EXTRA_INSTRUCTIONS
		extra=(-e PR_REVIEWER__EXTRA_INSTRUCTIONS -e PR_CODE_SUGGESTIONS__EXTRA_INSTRUCTIONS)
	fi
	# --init forwards signals (PR-Agent runs as PID 1 otherwise and ignores
	# SIGTERM). A run that hangs past the limit is retried once: a hang is
	# infrastructure, not a review result. Both attempts stay in the log.
	local attempt
	: >"$out.log"
	for attempt in 1 2; do
		rc=0
		OPENAI__KEY="$key" timeout -k 30 600 podman run --rm --init --network host "${extra[@]}" \
			-e OPENAI__KEY -e OPENAI__API_BASE="$proxy" -e CONFIG__GIT_PROVIDER=local \
			-e CONFIG__MODEL="openai/$model" -e "CONFIG__FALLBACK_MODELS=[\"openai/$model\"]" -e CONFIG__CUSTOM_MODEL_MAX_TOKENS=200000 \
			-v "$dir:/work:Z" -v "$(dirname "$out")/pa-out:/out:Z" -w /work --entrypoint python "$PR_AGENT_IMAGE" \
			/app/pr_agent/cli.py --pr_url base --json-output "/out/$cmd.json" "$cmd" >>"$out.log" 2>&1 || rc=$?
		[[ $rc == 124 || $rc == 137 ]] || break
		printf '\n== bench: attempt %s timed out (exit %s)\n' "$attempt" "$rc" >>"$out.log"
		git -C "$dir" checkout -q -- . && git -C "$dir" clean -fdq
	done
	mv -f "$(dirname "$out")/pa-out/$cmd.json" "$out.json" 2>/dev/null || : >"$out.json"
	python3 -I -c 'import sys,time; print(sys.argv[1], round(time.time() - float(sys.argv[2]), 1))' "$rc" "$start" >"$out.time"
	git -C "$dir" checkout -q -- . && git -C "$dir" clean -fdq
}

# knowledge ID KIND DIR: the case's OKF bundle, or nothing.
knowledge() {
	if [[ $2 == seeded ]]; then
		[[ -f $3/.okfw/index.md ]] && echo "$3/.okfw"
		return 0
	fi
	local slug
	slug="$(python3 -I -c '
import json, sys
c = next(c for c in json.load(open(sys.argv[1]))["cases"] if c["id"] == sys.argv[2])
print(c["repo"].split("github.com/")[1].replace("/", "__"))' "$root/bench/cases.json" "$1")"
	[[ -f $root/bench/knowledge/$slug/.okfw/index.md ]] && echo "$root/bench/knowledge/$slug/.okfw"
	return 0
}

# carry FROM TO: TO keeps FROM's output (no new input this round).
carry() {
	local x
	for x in json log time; do cp "$1.$x" "$2.$x"; done
	: >"$2.carried"
}

# later ID KIND: round 2 or 3 on one case.
later() {
	local id=$1 kind=$2 dir="$repos/$1" model d lint kb kbtext x
	checkout "$id" "$kind" >"$run/$id.checkout.log" 2>&1 || { echo "   $id: checkout failed (see $run/$id.checkout.log)"; return 0; }
	lint=""
	for x in "$run/$id/lint.json" "$run/$id/lint.sarif"; do [[ -s $x ]] && lint=$x && break; done
	[[ -n $lint ]] && [[ $(cat "$run/$id/lint.status" 2>/dev/null) == ok* || $(cat "$run/$id/lint.status" 2>/dev/null) == failed:*issues* ]] || lint=""
	kb="$(knowledge "$id" "$kind" "$dir")"
	if [[ -n $kb ]]; then
		kbtext="$run/$id/knowledge.txt"
		python3 -I - "$kb" >"$kbtext" <<'EOF'
import os, re, sys
root = sys.argv[1]
out = ["Project knowledge (the project's documented conventions). Use it to judge the change:"]
for d, _, fs in sorted(os.walk(root)):
    for f in sorted(fs):
        if not f.endswith(".md") or f in ("index.md", "log.md"):
            continue
        t = open(os.path.join(d, f)).read()
        t = re.sub(r"\A---\n.*?\n---\n", "", t, flags=re.S).strip()
        out.append(t)
print("\n\n".join(out))
EOF
	fi
	for model in $models; do
		d="$run/$id/$model"
		mkdir -p "$d"
		[[ -s $d/vizzini.time ]] || { echo "   $id / $model: no round 1; skipped"; continue; }
		(
			cd "$dir"
			VIZZINI_ITERATION="$(git rev-parse HEAD)"
			export VIZZINI_LITELLM_URL="$proxy" VIZZINI_API_KEY="$key" VIZZINI_MODEL="$model" \
				VIZZINI_PR="bench:$id" VIZZINI_ITERATION VIZZINI_REQUESTER=vizzini-lab-bench \
				TIKTOKEN_CACHE_DIR="$root/.cache/tiktoken"
			if ((round == 2)); then
				if [[ -n $lint ]]; then
					timed "$d/vizzini-lint" "$bin/pr-review" --mode review --patch-file "$run/$id/change.patch" --repo . --lint-json "$lint" --format json
				else
					carry "$d/vizzini" "$d/vizzini-lint"
				fi
			else
				[[ -s $d/vizzini-lint.time ]] || { echo "   $id / $model: no round 2; skipped"; exit 0; }
				if [[ -n $kb ]]; then
					timed "$d/vizzini-lint-kb" "$bin/pr-review" --mode review --patch-file "$run/$id/change.patch" --repo . \
						${lint:+--lint-json "$lint"} --knowledge "$kb" --format json
				else
					carry "$d/vizzini-lint" "$d/vizzini-lint-kb"
				fi
			fi
		)
		if ((round == 3)); then
			if [[ -n $kb ]]; then
				pa "$dir" "$model" review "$d/pa-review-kb" "$kbtext"
				pa "$dir" "$model" improve "$d/pa-improve-kb" "$kbtext"
			else
				carry "$d/pa-review" "$d/pa-review-kb"
				carry "$d/pa-improve" "$d/pa-improve-kb"
			fi
		fi
		echo "   $id / $model: round $round$( ((round == 2)) && printf ', lint %s' "${lint:+yes}" )$( ((round == 3)) && printf ', knowledge %s' "${kb:+yes}" ) $(for t in vizzini-lint vizzini-lint-kb pa-review-kb pa-improve-kb; do [[ -s $d/$t.time ]] && printf '%s %s%s  ' "$t" "$(cat "$d/$t.time")" "$([[ -e $d/$t.carried ]] && echo ' (carried)')"; done)"
	done
}

# one ID KIND: every round-1 tool and model on one case.
one() {
	local id=$1 kind=$2 dir="$repos/$1" model d
	if ((round > 1)); then later "$id" "$kind"; return 0; fi
	checkout "$id" "$kind" >"$run/$id.checkout.log" 2>&1 || { echo "   $id: checkout failed (see $run/$id.checkout.log)"; return 0; }
	for model in $models; do
		d="$run/$id/$model"
		mkdir -p "$d"
		(
			cd "$dir"
			VIZZINI_ITERATION="$(git rev-parse HEAD)"
			export VIZZINI_LITELLM_URL="$proxy" VIZZINI_API_KEY="$key" VIZZINI_MODEL="$model" \
				VIZZINI_PR="bench:$id" VIZZINI_ITERATION VIZZINI_REQUESTER=vizzini-lab-bench \
				TIKTOKEN_CACHE_DIR="$root/.cache/tiktoken"
			timed "$d/vizzini" "$bin/pr-review" --mode review --patch-file "$run/$id/change.patch" --repo . --format json
			timed "$d/vizzini-norepo" "$bin/pr-review" --mode review --patch-file "$run/$id/change.patch" --format json
		)
		pa "$dir" "$model" review "$d/pa-review"
		pa "$dir" "$model" improve "$d/pa-improve"
		echo "   $id / $model: $(for t in vizzini vizzini-norepo pa-review pa-improve; do printf '%s %s  ' "$t" "$(cat "$d/$t.time")"; done)"
	done
}

"$root/.cache/src/vizzini/scripts/tiktoken-cache.sh" "$root/.cache/tiktoken" >/dev/null
say "round $round: running ($jobs at a time)"
export -f one later knowledge carry checkout timed pa
export run repos root bin models key proxy round PR_AGENT_IMAGE
# shellcheck disable=SC2016 # the child bash expands $0 and $1
while IFS=$'\t' read -r id kind; do printf '%s\0%s\0' "$id" "$kind"; done <"$run/cases.tsv" |
	xargs -0 -n 2 -P "$jobs" bash -c 'one "$0" "$1"'

say "scoring"
python3 -I "$root/uat/bench.py" "$run" "$run/cases.all.tsv"
