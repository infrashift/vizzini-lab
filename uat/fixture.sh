#!/usr/bin/env bash
# fixture.sh: materialize the seeded C# fixture as a git repository.
#
#   uat/fixture.sh DIR
#
# DIR becomes a repository with two branches:
#   uat-base   fixtures/csharp-seeded/base (one commit)
#   uat-head   uat-base plus fixtures/csharp-seeded/change (one more commit)
# and uat-head checked out. It also writes, next to the repository:
#   DIR.patch    git diff uat-base..uat-head (what Vizzini reviews)
#   DIR.sarif    Roslyn SARIF from `dotnet build` on uat-head, run in
#                $DOTNET_IMAGE with the repo mounted at its own absolute path
#                so Roslyn's file:// URIs resolve on the host
#   DIR.build.log
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
fx="$root/fixtures/csharp-seeded"
container="${CONTAINER:-podman}"

die() { printf 'fixture: %s\n' "$*" >&2; exit 1; }
[[ $# -eq 1 ]] || die "usage: $0 DIR"
dir="$(realpath -m "$1")"
[[ ! -e $dir ]] || die "$dir already exists"

g() { git -C "$dir" -c user.name="vizzini-uat" -c user.email="uat@example.invalid" "$@"; }

mkdir -p "$dir"
git -C "$dir" init -q -b uat-base
cp -a "$fx/base/." "$dir/"
g add -A
g commit -q -m "Shop: orders, repositories and password hashing"
g checkout -q -b uat-head
cp -a "$fx/change/." "$dir/"
g add -A
g commit -q -m "Order search, CSV import, currency totals and password reset tokens"
g diff uat-base..uat-head >"$dir.patch"
echo "fixture: $dir ($(grep -c '^+[^+]' "$dir.patch") added lines, $(grep -c '^diff --git' "$dir.patch") files)"

"$container" image exists "$DOTNET_IMAGE" 2>/dev/null || "$container" pull -q "$DOTNET_IMAGE" >/dev/null
# The build writes bin/, obj/ and roslyn.sarif into the (gitignored) tree.
"$container" run --rm -v "$dir:$dir:Z" -w "$dir" "$DOTNET_IMAGE" dotnet build -nologo >"$dir.build.log" 2>&1 ||
	{ tail -20 "$dir.build.log" >&2; die "dotnet build failed"; }
mv "$dir/roslyn.sarif" "$dir.sarif"
python3 -I - "$dir.sarif" "$dir" <<'EOF'
import json, sys
run = json.load(open(sys.argv[1]))["runs"][0]
prefix = "file://" + sys.argv[2] + "/"
drv = run["tool"]["driver"]
print(f'fixture: {drv["name"]} {drv.get("semanticVersion", "")}, {len(run["results"])} result(s)')
for r in run["results"]:
    if not r.get("locations"):
        continue
    loc = r["locations"][0]["physicalLocation"]
    print(f'  {loc["artifactLocation"]["uri"].replace(prefix, "")}:{loc["region"]["startLine"]} {r["ruleId"]}: {r["message"]["text"][:80]}')
EOF
