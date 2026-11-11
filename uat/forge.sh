#!/usr/bin/env bash
# forge.sh: the Azure DevOps + mrman leg of the UAT, sourced by run.sh.
#
# forge_leg MODEL DIR FIXTURE FDIR, for one model whose review of FIXTURE
# (materialized at FDIR/repo) is DIR/review.json:
#   1. open a PR for the fixture on Azure DevOps (uat/ado.sh up)
#   2. mrman pr <url> --json --vizzini-report: headless session that must
#      carry every finding (DIR/mrman.json)
#   3. wait for a person to open the same PR in the mrman TUI with --auto
#      (ADR-0002: the grant is never faked; we poll `mrman review list`
#      until the session shows it, up to $GRANT_TIMEOUT seconds)
#   4. post every finding with `mrman review add`, then
#      `mrman review submit --event comment`
#   5. read the PR's threads back over REST (DIR/threads.json)
#
# mrman keeps its sessions under $run/mrman-data (XDG_DATA_HOME), so the UAT
# never touches your own review sessions; the command printed in step 3 sets
# the same variable.

# shellcheck disable=SC2154 # root, bin, run and timed come from run.sh

GRANT_TIMEOUT="${GRANT_TIMEOUT:-1200}"

forge_env() {
	export XDG_DATA_HOME="$run/mrman-data"
	mkdir -p "$XDG_DATA_HOME"
	if [[ -z ${AZURE_DEVOPS_EXT_PAT:-} ]]; then
		local f="${ADO_PAT_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/vizzini-uat/ado.pat}"
		AZURE_DEVOPS_EXT_PAT="$(<"$f")"
		export AZURE_DEVOPS_EXT_PAT
	fi
}

# granted SLUG: true once SLUG's session carries a comment grant.
granted() {
	"$bin/mrman" review list --all 2>/dev/null | python3 -I -c '
import json, sys
slug = sys.argv[1]
for s in json.load(sys.stdin) or []:
    if s.get("slug") == slug and "comment" in (s.get("granted_events") or []):
        sys.exit(0)
sys.exit(1)' "$1"
}

forge_leg() {
	local model=$1 d=$2 fixture=$3 f=$4 pr slug
	forge_env
	echo "   -- forge: $fixture / $model"
	pr="$("$root/uat/ado.sh" up "$f/repo" "$model" "$fixture")"
	echo "$pr" >"$d/pr-url"
	echo "   PR: $pr"

	timed "$d/mrman" "$bin/mrman" pr "$pr" --json --vizzini-report "$d/review.json"
	slug="$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["slug"])' "$d/mrman.json" 2>/dev/null)" || {
		echo "   mrman headless open failed: $(head -c 300 "$d/mrman.err")"
		return 0
	}
	echo "   mrman session: $slug"

	cat <<EOF

   ┌─ YOUR TURN ($fixture / $model) ──────────────────────────────────────────
   │ In another terminal, open the PR in mrman with the submit grant:
   │
   │   XDG_DATA_HOME='$XDG_DATA_HOME' \\
   │   AZURE_DEVOPS_EXT_PAT="\$(cat ~/.config/vizzini-uat/ado.pat)" \\
   │   '$bin/mrman' pr '$pr' --vizzini-report '$d/review.json' --auto
   │
   │ Check the header (vizzini score, finding count), press F / f to read the
   │ findings, and p to promote one into a draft (Enter saves it). Leave
   │ mrman open: this run continues once it sees the grant, posts every
   │ finding as a comment, and submits a comment review. Quit mrman after.
   └─ waiting up to ${GRANT_TIMEOUT}s ──────────────────────────────────────────
EOF
	local waited=0
	until granted "$slug"; do
		if ((waited >= GRANT_TIMEOUT)); then
			echo "   no grant after ${GRANT_TIMEOUT}s; skipping the post for $model"
			return 0
		fi
		sleep 3
		waited=$((waited + 3))
	done
	echo "   grant seen after ${waited}s; posting findings"

	python3 -I - "$d/review.json" >"$d/post-plan.jsonl" <<'PY'
import json, sys
r = json.load(open(sys.argv[1]))
for f in r["findings"]:
    body = f"**{f['severity']} ({f['category']}): {f['title']}**\n\n{f['body'].strip()}"
    if f.get("suggestion"):
        body += f"\n\nSuggestion:\n```\n{f['suggestion'].strip()}\n```"
    if f.get("citations"):
        body += "\n\nSee: " + ", ".join(f["citations"])
    body += "\n\n_(from a Vizzini review, posted by the vizzini-uat harness)_"
    print(json.dumps({"file": f["file"], "start": f["start_line"], "end": f["end_line"], "body": body}))
PY
	local posted=0 failed=0 file start end body
	while IFS= read -r line; do
		file="$(jq -r .file <<<"$line")" start="$(jq -r .start <<<"$line")" end="$(jq -r .end <<<"$line")"
		body="$(jq -r .body <<<"$line")"
		local range=()
		((end > start)) && range=(--end-line "$end")
		if "$bin/mrman" review add --session "$slug" --target-file "$file" --line "$start" "${range[@]}" \
			--side new "$body" >>"$d/review-add.log" 2>&1; then
			posted=$((posted + 1))
		else
			failed=$((failed + 1))
		fi
	done <"$d/post-plan.jsonl"
	echo "   review add: $posted added, $failed failed"
	# A transient network failure (seen: a TLS reset from dev.azure.com on
	# submit's first request) leaves the drafts unposted; retrying is safe
	# because nothing reached the forge. Only mrman's "network error" retries.
	local try
	for try in 1 2 3; do
		timed "$d/submit" "$bin/mrman" review submit --session "$slug" --event comment
		if [[ $(<"$d/submit.code") == 0 ]] || ! grep -q 'network error' "$d/submit.err" || ((try == 3)); then
			break
		fi
		cp "$d/submit.err" "$d/submit.attempt$try.err"
		echo "   submit attempt $try hit a network error; retrying"
		sleep $((try * 5))
	done
	sleep 2
	for try in 1 2 3; do
		"$root/uat/ado.sh" threads "$pr" >"$d/threads.json" && break
		sleep $((try * 5))
	done
	echo "   ADO threads: $(jq '[.value[] | select(.threadContext.filePath != null)] | length' "$d/threads.json" 2>/dev/null) inline"
}
