#!/usr/bin/env bash
# fixture.sh: materialize a seeded fixture as a git repository.
#
#   uat/fixture.sh NAME DIR
#
# NAME is a directory under fixtures/ with base/, change/, expected.json and
# fixture.env (LINT=roslyn|eslint, LANGUAGE=...). DIR becomes a repository
# with two branches:
#   uat-base   fixtures/NAME/base (one commit)
#   uat-head   uat-base plus fixtures/NAME/change (one more commit)
# and uat-head checked out. It also writes, next to the repository:
#   DIR.patch      git diff uat-base..uat-head (what Vizzini reviews)
#   DIR.sarif      the linter's SARIF on uat-head, produced in a container
#                  with the repo mounted at its own absolute path, so the
#                  absolute file:// URIs it writes resolve on the host
#   DIR.build.log
#
# roslyn: `dotnet build` in $DOTNET_IMAGE (MSBuild ErrorLog)
# eslint: `npm install` + ESLint with @microsoft/eslint-formatter-sarif in
#         $NODE_IMAGE (npm cache in .cache/npm)
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
container="${CONTAINER:-podman}"

die() { printf 'fixture: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 2 ]] || die "usage: $0 NAME DIR"
fx="$root/fixtures/$1"
[[ -f $fx/fixture.env ]] || die "no fixture $1 (want fixtures/$1/fixture.env)"
LINT="" LANGUAGE=""
# shellcheck source=/dev/null
source "$fx/fixture.env"
dir="$(realpath -m "$2")"
[[ ! -e $dir ]] || die "$dir already exists"

g() { git -C "$dir" -c user.name="vizzini-uat" -c user.email="uat@example.invalid" "$@"; }

mkdir -p "$dir"
git -C "$dir" init -q -b uat-base
cp -a "$fx/base/." "$dir/"
g add -A
g commit -q -m "$1: base"
g checkout -q -b uat-head
cp -a "$fx/change/." "$dir/"
g add -A
g commit -q -m "$1: seeded change"
g diff uat-base..uat-head >"$dir.patch"
echo "fixture: $1 ($LANGUAGE) at $dir: $(grep -c '^+[^+]' "$dir.patch") added lines, $(grep -c '^diff --git' "$dir.patch") files"

image_ready() { "$container" image exists "$1" 2>/dev/null || "$container" pull -q "$1" >/dev/null; }

case $LINT in
roslyn)
	image_ready "$DOTNET_IMAGE"
	# The build writes bin/, obj/ and roslyn.sarif into the (gitignored) tree.
	"$container" run --rm -v "$dir:$dir:Z" -w "$dir" "$DOTNET_IMAGE" dotnet build -nologo >"$dir.build.log" 2>&1 ||
		{ tail -20 "$dir.build.log" >&2; die "dotnet build failed"; }
	mv "$dir/roslyn.sarif" "$dir.sarif"
	;;
eslint)
	image_ready "$NODE_IMAGE"
	mkdir -p "$root/.cache/npm"
	node() {
		"$container" run --rm -v "$dir:$dir:Z" -v "$root/.cache/npm:/npm-cache:Z" -w "$dir" \
			-e npm_config_cache=/npm-cache -e npm_config_update_notifier=false "$NODE_IMAGE" "$@"
	}
	node npm install --no-audit --no-fund --loglevel=error >"$dir.build.log" 2>&1 ||
		{ tail -20 "$dir.build.log" >&2; die "npm install failed"; }
	# ESLint exits 1 when it reports errors; 2 means it could not run.
	code=0
	node npx --no-install eslint -f @microsoft/eslint-formatter-sarif -o eslint.sarif . >>"$dir.build.log" 2>&1 || code=$?
	((code <= 1)) && [[ -s $dir/eslint.sarif ]] || { tail -20 "$dir.build.log" >&2; die "eslint exited $code"; }
	mv "$dir/eslint.sarif" "$dir.sarif"
	;;
*) die "fixtures/$1/fixture.env: unknown LINT=$LINT" ;;
esac

python3 -I - "$dir.sarif" "$dir" <<'EOF'
import json, sys
prefix = "file://" + sys.argv[2] + "/"
for run in json.load(open(sys.argv[1]))["runs"]:
    drv = run["tool"]["driver"]
    print(f'fixture: {drv["name"]} {drv.get("semanticVersion") or drv.get("version", "")}, {len(run.get("results", []))} result(s)')
    for r in run.get("results", []):
        if not r.get("locations"):
            continue
        loc = r["locations"][0]["physicalLocation"]
        sup = " (suppressed)" if r.get("suppressions") else ""
        print(f'  {loc["artifactLocation"]["uri"].replace(prefix, "")}:{loc["region"]["startLine"]} {r.get("ruleId")}{sup}: {r["message"]["text"][:80]}')
EOF
