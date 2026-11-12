#!/usr/bin/env bash
# build.sh: clone the four tools at their pinned revisions and build them.
#
#   uat/build.sh            build all of vizzini, mrman, garmr, okfw
#   uat/build.sh mrman ...  build only the named tools
#
# Each <TOOL>_SRC (versions.env) is cloned into .cache/src/<tool> and checked
# out at <TOOL>_SHA (any revision git understands; the manifest records the
# resolved commit). The working checkouts next to this repo are only read,
# never modified, so agents working in them are not disturbed.
#
# mrman is built against the pinned Vizzini clone through go.work, so it gets
# Vizzini changes that are not yet released as a module version.
#
# Binaries land in .cache/bin; .cache/bin/build-manifest.json records exactly
# what was built.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
src="$root/.cache/src"
bin="$root/.cache/bin"
mkdir -p "$src" "$bin"
export CGO_ENABLED=0

say() { printf '== %s\n' "$*"; }
die() { printf 'build: %s\n' "$*" >&2; exit 1; }

# checkout TOOL SRC REV: clone or refresh .cache/src/TOOL at REV.
checkout() {
	local tool=$1 from=$2 rev=$3 dir="$src/$1"
	[[ $from == /* || $from == *://* || $from == git@* ]] || from="$root/$from"
	if [[ ! -d $dir/.git ]]; then
		git clone -q --no-checkout "$from" "$dir"
	else
		git -C "$dir" remote set-url origin "$from"
	fi
	# --force: the cache mirrors the source, so a tag moved there (as v0.1.3
	# was, before its release published) moves here too instead of failing.
	git -C "$dir" fetch -q --tags --force origin '+refs/heads/*:refs/remotes/origin/*'
	# Prefer the source's own branch of that name; then any commit-ish.
	local commit
	commit="$(git -C "$dir" rev-parse -q --verify "origin/$rev^{commit}" 2>/dev/null ||
		git -C "$dir" rev-parse -q --verify "$rev^{commit}")" || die "$tool: unknown revision $rev in $from"
	git -C "$dir" checkout -q --force --detach "$commit"
	git -C "$dir" clean -qfdx
	say "$tool $(git -C "$dir" describe --tags --always) ($commit)"
}

build_vizzini() {
	checkout vizzini "$VIZZINI_SRC" "$VIZZINI_SHA"
	(
		cd "$src/vizzini"
		go build -trimpath -o "$bin/pr-review" ./cmd/pr-review
		# vizzini-bot exists from ISSUE-024 slice 1 on.
		if [[ -d cmd/vizzini-bot ]]; then go build -trimpath -o "$bin/vizzini-bot" ./cmd/vizzini-bot; fi
		# vizzini-webhook (experimental) exists from ISSUE-026 on.
		if [[ -d cmd/vizzini-webhook ]]; then go build -trimpath -o "$bin/vizzini-webhook" ./cmd/vizzini-webhook; fi
		# stubllm, the token-free model, from the same pinned commit: a stale one
		# would not know newer commands.
		go build -trimpath -o "$bin/stubllm" ./scripts/e2e/stubllm
	)
}

build_mrman() {
	[[ -d $src/vizzini/.git ]] || build_vizzini
	checkout mrman "$MRMAN_SRC" "$MRMAN_SHA"
	(
		cd "$src/mrman"
		# Workspace-only override: the clone's go.mod is left as pinned.
		[[ -f go.work ]] || go work init .
		go work use "$src/vizzini"
		local m v c
		m="$(awk '$1 == "module" {print $2; exit}' go.mod)" v="$(git describe --tags --match 'v[0-9]*' --always)" c="$(git rev-parse --short HEAD)"
		go build -trimpath -ldflags "-s -w -X $m/internal/version.Version=$v -X $m/internal/version.Commit=$c" \
			-o "$bin/mrman" .
	)
}

build_garmr() {
	checkout garmr "$GARMR_SRC" "$GARMR_SHA"
	(
		cd "$src/garmr"
		local v c
		v="$(git describe --tags --always)" c="$(git rev-parse --short HEAD)"
		go build -trimpath -ldflags "-X main.version=$v -X main.commit=$c" -o "$bin/garmr" ./cmd/garmr
	)
}

build_okfw() {
	checkout okfw "$OKFW_SRC" "$OKFW_SHA"
	(
		cd "$src/okfw"
		go build -trimpath -ldflags "-X okfw/cli/internal/config.version=$(git describe --tags --always)" \
			-o "$bin/okfw" ./cli/cmd/okfw
	)
}

tools=("$@")
[[ ${#tools[@]} -gt 0 ]] || tools=(vizzini mrman garmr okfw)
for t in "${tools[@]}"; do
	case $t in
	vizzini | mrman | garmr | okfw) "build_$t" ;;
	*) die "unknown tool $t (want vizzini, mrman, garmr or okfw)" ;;
	esac
done

python3 -I - "$src" "$bin/build-manifest.json" "$(go version)" <<'EOF'
import json, os, subprocess, sys
src, out, gover = sys.argv[1:]
m = {"go": gover, "tools": {}}
for tool in ("vizzini", "mrman", "garmr", "okfw"):
    d = os.path.join(src, tool)
    if not os.path.isdir(os.path.join(d, ".git")):
        continue
    git = lambda *a: subprocess.check_output(["git", "-C", d, *a], text=True).strip()
    m["tools"][tool] = {
        "commit": git("rev-parse", "HEAD"),
        "describe": git("describe", "--tags", "--match", "v[0-9]*", "--always"),
        "source": git("remote", "get-url", "origin"),
    }
json.dump(m, open(out, "w"), indent=2)
EOF
built=()
for b in "$bin"/*; do [[ $b == *.json ]] || built+=("$(basename "$b")"); done
say "binaries in $bin: ${built[*]}"
