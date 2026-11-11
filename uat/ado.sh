#!/usr/bin/env bash
# ado.sh: the UAT's pull requests on Azure DevOps.
#
#   ado.sh check                 verify the PAT and repository are reachable
#   ado.sh base REPO_DIR         force-push REPO_DIR's uat-base branch
#   ado.sh up REPO_DIR LABEL     push uat-head as uat/LABEL-<stamp>, open a PR
#                                into uat-base, print its web URL
#   ado.sh threads PR_URL        print the PR's comment threads as JSON
#   ado.sh down                  abandon open "vizzini-uat" PRs, delete uat/* branches
#
# Configuration (nothing secret is ever passed on a command line):
#   ADO_REPO_URL   https://dev.azure.com/ORG/PROJECT/_git/REPO
#                  (or a line ADO_REPO_URL=... in ~/.config/vizzini-uat/ado.env)
#   ADO_PAT_FILE   file holding a PAT with Code (Read & Write)
#                  (default ~/.config/vizzini-uat/ado.pat, must be mode 0600)
# The PAT is exported as AZURE_DEVOPS_EXT_PAT, the variable mrman reads, and
# reaches git through a credential helper and curl through a config on stdin.
#
# Commits say [skip ci], so pipelines on the repository build nothing.
set -euo pipefail

TITLE_PREFIX="vizzini-uat"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/vizzini-uat"

die() { printf 'ado: %s\n' "$*" >&2; exit 1; }

load_config() {
	if [[ -z ${ADO_REPO_URL:-} && -f $cfg/ado.env ]]; then
		ADO_REPO_URL="$(sed -n 's/^ADO_REPO_URL=//p' "$cfg/ado.env" | tail -1)"
	fi
	[[ -n ${ADO_REPO_URL:-} ]] || die "set ADO_REPO_URL (or put ADO_REPO_URL=... in $cfg/ado.env)"
	ADO_REPO_URL="${ADO_REPO_URL%/}"
	[[ $ADO_REPO_URL =~ ^https://dev\.azure\.com/[^/]+/[^/]+/_git/[^/]+$ ]] ||
		die "ADO_REPO_URL must look like https://dev.azure.com/ORG/PROJECT/_git/REPO"
	if [[ -z ${AZURE_DEVOPS_EXT_PAT:-} ]]; then
		local f="${ADO_PAT_FILE:-$cfg/ado.pat}"
		[[ -s $f ]] || die "no PAT: create $f (mode 0600) in your own terminal:
  mkdir -p $cfg && read -rs P && install -m600 /dev/null $f && printf %s \"\$P\" > $f && unset P"
		[[ $(stat -c %a "$f") == 600 ]] || die "$f must be mode 0600"
		AZURE_DEVOPS_EXT_PAT="$(<"$f")"
	fi
	export AZURE_DEVOPS_EXT_PAT ADO_REPO_URL
	local rest="${ADO_REPO_URL#https://dev.azure.com/}"
	ORG="${rest%%/*}"
	rest="${rest#*/}"
	PROJECT="${rest%%/_git/*}"
	REPO="${rest#*/_git/}"
	ADO_API="https://dev.azure.com/$ORG/$(quote "$PROJECT")/_apis/git/repositories/$(quote "$REPO")"
}

quote() { python3 -I -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1],safe=""))' "$1"; }
json() { python3 -I -c "import json,sys; d=json.load(sys.stdin); print($1)"; }

# api METHOD URL [JSON]: prints the body; fails on a non-2xx status.
api() {
	local method=$1 url=$2 data=${3:-} out code
	out="$(mktemp)"
	code="$(printf 'header = "Authorization: Basic %s"\n' "$(printf ':%s' "$AZURE_DEVOPS_EXT_PAT" | base64 -w0)" |
		curl -sS -K - -o "$out" -w '%{http_code}' -X "$method" -H 'Content-Type: application/json' \
			${data:+--data "$data"} "$url")"
	if [[ $code != 2* ]]; then
		echo "ado: $method $url -> HTTP $code: $(head -c 400 "$out")" >&2
		rm -f "$out"
		return 1
	fi
	cat "$out"
	rm -f "$out"
}

# g DIR ARGS: git in DIR with the PAT supplied by a helper at run time (the
# single quotes are deliberate: the PAT never appears in git's argv).
g() {
	local dir=$1
	shift
	# shellcheck disable=SC2016
	git -C "$dir" -c credential.helper= \
		-c 'credential.helper=!f() { echo username=pat; echo "password=$AZURE_DEVOPS_EXT_PAT"; }; f' \
		-c user.name=vizzini-uat -c user.email=uat@example.invalid "$@"
}

cmd_check() {
	local r
	r="$(api GET "$ADO_API?api-version=7.1")" || die "cannot read $ADO_REPO_URL with this PAT"
	echo "ado: $(json '"%s/%s (default branch %s)" % (d["project"]["name"], d["name"], d.get("defaultBranch", "none: empty repository"))' <<<"$r")"
}

cmd_base() {
	local dir=$1
	g "$dir" push -q -f "$ADO_REPO_URL" "uat-base:refs/heads/uat-base"
	echo "ado: pushed uat-base"
}

cmd_up() {
	local dir=$1 label=$2 stamp head title body id
	stamp="$(date -u +%Y%m%dT%H%M%SZ)"
	head="uat/$label-$stamp"
	g "$dir" push -q "$ADO_REPO_URL" "uat-head:refs/heads/$head"
	title="$TITLE_PREFIX $label $stamp"
	body="Seeded C# fixture for the Vizzini + mrman + garmr + okf-wiki UAT ($label). Safe to abandon."
	id="$(api POST "$ADO_API/pullrequests?api-version=7.1" "$(python3 -I -c '
import json,sys
print(json.dumps({"sourceRefName": "refs/heads/"+sys.argv[1], "targetRefName": "refs/heads/uat-base",
                  "title": sys.argv[2], "description": sys.argv[3]}))' "$head" "$title" "$body")" | json 'd["pullRequestId"]')"
	echo "$ADO_REPO_URL/pullrequest/$id"
}

pr_id() { [[ $1 =~ /pullrequest/([0-9]+)$ ]] || die "not a PR URL: $1"; echo "${BASH_REMATCH[1]}"; }

cmd_threads() {
	api GET "$ADO_API/pullRequests/$(pr_id "$1")/threads?api-version=7.1"
}

cmd_down() {
	local id ref oid
	for id in $(api GET "$ADO_API/pullrequests?searchCriteria.status=active&api-version=7.1" |
		json '" ".join(str(p["pullRequestId"]) for p in d["value"] if p["title"].startswith("'"$TITLE_PREFIX"'"))'); do
		api PATCH "$ADO_API/pullrequests/$id?api-version=7.1" '{"status":"abandoned"}' >/dev/null
		echo "ado: abandoned PR $id"
	done
	api GET "$ADO_API/refs?filter=heads/uat/&api-version=7.1" |
		json '"\n".join(r["name"] + " " + r["objectId"] for r in d["value"])' |
		while read -r ref oid; do
			[[ -n $ref ]] || continue
			api POST "$ADO_API/refs?api-version=7.1" "$(python3 -I -c '
import json,sys
print(json.dumps([{"name": sys.argv[1], "oldObjectId": sys.argv[2], "newObjectId": "0"*40}]))' "$ref" "$oid")" >/dev/null
			echo "ado: deleted $ref"
		done
}

load_config
case "${1:-}" in
check) cmd_check ;;
base) [[ $# -eq 2 ]] || die "usage: $0 base REPO_DIR"; cmd_base "$2" ;;
up) [[ $# -eq 3 ]] || die "usage: $0 up REPO_DIR LABEL"; cmd_up "$2" "$3" ;;
threads) [[ $# -eq 2 ]] || die "usage: $0 threads PR_URL"; cmd_threads "$2" ;;
down) cmd_down ;;
*) sed -n '2,20p' "$0" >&2; exit 2 ;;
esac
