#!/usr/bin/env bash
# webhook.sh: Vizzini's webhook receiver (EXPERIMENTAL), live on Azure DevOps.
#
#   uat/webhook.sh [--live]
#
# vizzini-webhook answers /vizzini commands as they are written, by running
# vizzini-bot --commands-only (Vizzini ADR-0022, ISSUE-026). Azure DevOps can
# only deliver service hooks to public HTTPS endpoints, so this test runs the
# receiver on 127.0.0.1 and delivers to it itself: each event is built in the
# exact shape of ADO's "Pull request commented on" event (resource version
# 2.0, resource details All) from the REAL comment and pull request, fetched
# over REST. Everything after the delivery is real: the receiver's clone of
# the ADO repository, vizzini-bot, mrman, garmr and the reply on the PR.
#
#   setup   the seeded fixture's PR (uat/ado.sh up); vizzini-bot posts its
#           findings under a run-local policy listing the PAT's identity,
#           as bot.sh's allow leg does
#   cases   UAT-HOOK-001..009 (the wiki's TS-HOOK suite): health, auth,
#           filtering, an immediate answer with no push, coalescing and
#           answer-once, commands only, a policy denial naming the identity,
#           secret hygiene, and a clean shutdown
#
# The model is stubllm (no tokens) unless --live (LiteLLM must be up).
# Writes .cache/runs/<UTC>-webhook/; exits non-zero when a check fails. The
# PR is abandoned and its branch deleted at the end.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
bin="$root/.cache/bin"
src="$root/.cache/src"
committed="$src/mrman/policies/garmr/mrman"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/vizzini-lab"
fixture=csharp-seeded live=0
[[ ${1:-} == --live ]] && live=1

say() { printf '\n== %s\n' "$*"; }
die() { printf 'webhook: %s\n' "$*" >&2; exit 1; }
for b in vizzini-bot vizzini-webhook mrman garmr stubllm; do [[ -x $bin/$b ]] || die "$bin/$b missing; run uat/build.sh"; done

ADO_REPO_URL="${ADO_REPO_URL:-$(sed -n 's/^ADO_REPO_URL=//p' "$cfg/ado.env" | tail -1)}"
[[ $ADO_REPO_URL =~ ^https://dev\.azure\.com/([^/]+)/([^/]+)/_git/([^/]+)$ ]] || die "set ADO_REPO_URL"
ORG="${BASH_REMATCH[1]}" PROJECT="${BASH_REMATCH[2]}" REPO="${BASH_REMATCH[3]}"
repo_key="dev.azure.com/$ORG/$PROJECT/$REPO"
api_base="https://dev.azure.com/$ORG/$PROJECT/_apis/git/repositories/$REPO"
pat_file="${ADO_PAT_FILE:-$cfg/ado.pat}"

# api METHOD URL [JSON]: the PAT goes to curl in a config on stdin.
api() {
	printf 'header = "Authorization: Basic %s"\n' "$(printf ':%s' "$(<"$pat_file")" | base64 -w0)" |
		curl -fsS -K - -X "$1" -H 'Content-Type: application/json' ${3:+--data "$3"} "$2"
}
jq_() { python3 -I -c "import json,sys; d=json.load(sys.stdin); print($1)"; }

export TIKTOKEN_CACHE_DIR="$root/.cache/tiktoken"
"$src/vizzini/scripts/tiktoken-cache.sh" "$TIKTOKEN_CACHE_DIR" >/dev/null
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
run="$root/.cache/runs/$stamp-webhook"
mkdir -p "$run"
cp "$bin/build-manifest.json" "$run/"
echo "run: $run"

pids=() pr="" head_branch=""
cleanup() {
	say "cleanup"
	local p
	for p in "${pids[@]}"; do kill "$p" 2>/dev/null || true; done
	if [[ -n $pr ]]; then
		api PATCH "$api_base/pullrequests/${pr##*/}?api-version=7.1" '{"status":"abandoned"}' >/dev/null && echo "   PR ${pr##*/} abandoned"
	fi
	if [[ -n $head_branch ]]; then
		git -C "$run/repo" -c credential.helper= \
			-c "credential.helper=!f() { echo username=pat; echo \"password=\$(cat '$pat_file')\"; }; f" \
			push -q "$ADO_REPO_URL" --delete "$head_branch" 2>/dev/null && echo "   branch $head_branch deleted"
	fi
	return 0
}
trap cleanup EXIT

say "model endpoint"
if ((live)); then
	"$root/litellm/litellm.sh" status >/dev/null || die "LiteLLM is not running: litellm/litellm.sh up"
	eval "$("$root/litellm/litellm.sh" env)"
	export VIZZINI_MODEL=claude-sonnet-5-5
else
	addr="127.0.0.1:${STUB_PORT:-18774}"
	"$bin/stubllm" -addr "$addr" -log "$run/stub-prompts.log" 2>"$run/stubllm.err" &
	pids+=($!)
	for _ in $(seq 50); do curl -s -o /dev/null "http://$addr/" && break; sleep 0.1; done
	export VIZZINI_LITELLM_URL="http://$addr/v1" VIZZINI_MODEL=stub
	unset VIZZINI_API_KEY
fi
echo "   $VIZZINI_LITELLM_URL, model $VIZZINI_MODEL"

say "setup: the fixture's PR, and the bot's findings on it"
"$root/uat/ado.sh" check
VIZZINI_REQUESTER="$("$root/uat/ado.sh" whoami)"
"$root/uat/fixture.sh" "$fixture" "$run/repo" >"$run/fixture.log" 2>&1 || { tail -20 "$run/fixture.log"; die "fixture"; }
"$root/uat/ado.sh" base "$run/repo" "$fixture"
pr="$("$root/uat/ado.sh" up "$run/repo" "webhook" "$fixture")"
pr_id="${pr##*/}"
echo "$pr" >"$run/pr-url"
head_branch="$(api GET "$api_base/pullrequests/$pr_id?api-version=7.1" | jq_ 'd["sourceRefName"][len("refs/heads/"):]')"
echo "   PR $pr_id ($head_branch)"

# bot DIR ARGS...: one vizzini-bot run from the fixture's checkout, as CI makes
# it. stubllm reports one finding per linter diagnostic, so the SARIF goes in.
bot() {
	local d=$1
	shift
	mkdir -p "$d/mrman-data"
	set +e
	(cd "$run/repo" && AZURE_DEVOPS_EXT_PAT="$(<"$pat_file")" XDG_DATA_HOME="$d/mrman-data" VIZZINI_REQUESTER="$VIZZINI_REQUESTER" \
		"$bin/vizzini-bot" --repo . --base uat-base --head uat-head --pr-url "$pr" --mrman "$bin/mrman" --garmr "$bin/garmr" \
		--pr "ado:$repo_key#$pr_id" --lint-json "$run/repo.sarif" "$@") >"$d/bot.json" 2>"$d/bot.err"
	echo $? >"$d/bot.code"
	set -e
	find "$d/mrman-data" -name '*.audit.jsonl' -exec cat {} + >"$d/audit.jsonl" 2>/dev/null || true
}
bot "$run/setup-deny" --grant-policy "$committed"
identity="$(python3 -I -c '
import json, sys
recs = [json.loads(l) for l in open(sys.argv[1]) if l.strip()]
print(recs[-1]["input"]["identity"] if recs else "")' "$run/setup-deny/audit.jsonl")"
[[ -n $identity ]] || die "no identity from the deny run; see $run/setup-deny/bot.err"
allow="$run/policy-allow/mrman"
mkdir -p "$allow"
python3 -I - "$committed/agent-submit.cue" "$allow/agent-submit.cue" "$identity" <<'EOF'
import json, sys
src, dst, ident = sys.argv[1:]
text = open(src).read()
old = '_allowedIdentities: ["vizzini-bot"]'
assert text.count(old) == 1, "committed policy changed shape"
open(dst, "w").write(text.replace(old, "_allowedIdentities: [" + json.dumps(ident) + "]"))
EOF
bot "$run/setup-allow" --grant-policy "$allow"
[[ $(<"$run/setup-allow/bot.code") == 0 ]] || { cat "$run/setup-allow/bot.err"; die "the setup bot run failed"; }
sleep 2
"$root/uat/ado.sh" threads "$pr" >"$run/threads-setup.json"
read -r thread findings < <(python3 -I -c '
import json, sys
ts = [t for t in json.load(open(sys.argv[1]))["value"]
      if t.get("threadContext") and "<!-- vizzini:fp=" in ((t.get("comments") or [{}])[0].get("content") or "")]
print(ts[0]["id"] if ts else "", len(ts))' "$run/threads-setup.json")
[[ -n $thread ]] || die "the bot posted no thread"
echo "   identity ${identity:0:3}… (redacted); $findings bot thread(s); commands go in thread $thread"

say "start the receivers"
umask 077
python3 -I -c 'import secrets; print(secrets.token_urlsafe(32))' >"$run/webhook.secret"
work="$run/webhook-work"
# receiver PORT POLICY LOG: one vizzini-webhook, its tokens in its environment only.
receiver() {
	AZURE_DEVOPS_EXT_PAT="$(<"$pat_file")" VIZZINI_WEBHOOK_SECRET_FILE="$run/webhook.secret" \
		"$bin/vizzini-webhook" --listen "127.0.0.1:$1" --repo "$ADO_REPO_URL" --work "$work-$1" \
		--bot "$bin/vizzini-bot" --grant-policy "$2" --max-jobs 2 \
		--bot-arg="--mrman=$bin/mrman" --bot-arg="--garmr=$bin/garmr" 2>"$3" &
	pids+=($!)
	for _ in $(seq 50); do curl -fs -o /dev/null "http://127.0.0.1:$1/healthz" && return 0; sleep 0.1; done
	die "the receiver on $1 did not start; see $3"
}
port=${WEBHOOK_PORT:-18484} port_deny=$((${WEBHOOK_PORT:-18484} + 1))
receiver "$port" "$allow" "$run/webhook.log"
main_pid=${pids[-1]}
receiver "$port_deny" "$committed" "$run/webhook-deny.log"
echo "   allow policy on :$port, committed policy on :$port_deny"

# deliver PORT EVENT_FILE [USER PASSWORD]: POST like ADO's Web Hooks consumer;
# prints "<status> <body>".
deliver() {
	local auth=() out
	out="$(mktemp)"
	if [[ $# -ge 4 ]]; then
		printf 'user = "%s:%s"\n' "$3" "$4" >"$out.cfg"
	else
		printf 'user = "vizzini:%s"\n' "$(<"$run/webhook.secret")" >"$out.cfg"
	fi
	[[ ${3:-x} == none ]] && : >"$out.cfg"
	auth=(-K "$out.cfg")
	code="$(curl -sS "${auth[@]}" -o "$out" -w '%{http_code}' -X POST -H 'Content-Type: application/json' \
		--data-binary "@$2" "http://127.0.0.1:$1/hooks/azure-devops")"
	echo "$code $(tr -d '\n' <"$out")"
	rm -f "$out" "$out.cfg"
}
# event COMMENT_ID OUT: the service hook event for a real comment in $thread.
event() {
	api GET "$api_base/pullRequests/$pr_id/threads/$thread/comments/$1?api-version=7.1" >"$2.comment"
	api GET "$api_base/pullrequests/$pr_id?api-version=7.1" >"$2.pr"
	python3 -I - "$2.comment" "$2.pr" "$2" "$ADO_REPO_URL" <<'EOF'
import json, sys, uuid
comment, pr, out, remote = sys.argv[1:]
c, p = json.load(open(comment)), json.load(open(pr))
# The REST pull request is the event's resource; ADO's event carries the
# repository's remoteUrl (with the org as user-info), which REST may omit.
p.setdefault("repository", {}).setdefault("remoteUrl", remote.replace("https://", "https://" + remote.split("/")[3] + "@", 1))
json.dump({"id": str(uuid.uuid4()), "eventType": "ms.vss-code.git-pullrequest-comment-event", "publisherId": "tfs",
           "resource": {"comment": c, "pullRequest": p}, "resourceVersion": "2.0"}, open(out, "w"))
EOF
	rm -f "$2.comment" "$2.pr"
}
comment() { "$root/uat/ado.sh" comment "$pr" "$thread" "$1"; }
replies_to() { # replies_to COMMENT_ID: the number of bot replies to it
	"$root/uat/ado.sh" threads "$pr" | python3 -I -c '
import json, sys
n = sum(1 for t in json.load(sys.stdin)["value"] for c in t.get("comments") or []
        if "vizzini:reply-to=" + sys.argv[1] + " " in (c.get("content") or ""))
print(n)' "$1"
}
wait_reply() { # wait_reply COMMENT_ID SECONDS: seconds until a reply, or "timeout"
	local t0=$SECONDS
	while ((SECONDS - t0 < $2)); do
		[[ $(replies_to "$1") -ge 1 ]] && { echo $((SECONDS - t0)); return; }
		sleep 3
	done
	echo timeout
}
results="$run/results.txt"
: >"$results"
rec() { printf '%s\t%s\n' "$1" "$2" >>"$results"; echo "   $1: $2"; }

say "UAT-HOOK-001 health"
rec health "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/healthz")"

say "UAT-HOOK-002 authentication"
c1="$(comment "/vizzini explain What does this line do?")"
event "$c1" "$run/event1.json"
rec auth_none "$(deliver "$port" "$run/event1.json" none none | cut -d' ' -f1)"
rec auth_wrong "$(deliver "$port" "$run/event1.json" vizzini wrong-password-0123456789 | cut -d' ' -f1)"
rec auth_get "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/hooks/azure-devops")"

say "UAT-HOOK-003 filtering"
python3 -I - "$run/event1.json" "$run" <<'EOF'
import copy, json, sys
ev, run = json.load(open(sys.argv[1])), sys.argv[2]
def write(name, edit):
    e = copy.deepcopy(ev); edit(e); json.dump(e, open(f"{run}/{name}.json", "w"))
write("ev-plain", lambda e: e["resource"]["comment"].update(content="Looks good to me."))
write("ev-bot", lambda e: e["resource"]["comment"].update(content="/vizzini explain x\n<!-- vizzini:reply-to=1 run=r -->"))
write("ev-other-repo", lambda e: e["resource"]["pullRequest"]["repository"].update(remoteUrl="https://dev.azure.com/o/p/_git/not-allowlisted"))
write("ev-inactive", lambda e: e["resource"]["pullRequest"].update(status="completed"))
write("ev-push", lambda e: e.update(eventType="git.push"))
EOF
for n in plain bot other-repo inactive push; do rec "ignore_$n" "$(deliver "$port" "$run/ev-$n.json")"; done
cp "$src/vizzini/cmd/vizzini-webhook/testdata/ado-pr-comment-event.json" "$run/ev-ado-sample.json"
rec ignore_ado_sample "$(deliver "$port" "$run/ev-ado-sample.json" | cut -d' ' -f1)"

say "UAT-HOOK-004 an immediate answer, with no push"
head_before="$(api GET "$api_base/pullrequests/$pr_id?api-version=7.1" | jq_ 'd["lastMergeSourceCommit"]["commitId"]')"
rec deliver1 "$(deliver "$port" "$run/event1.json")"
rec reply1_seconds "$(wait_reply "$c1" 180)"
rec head_unchanged "$([[ $(api GET "$api_base/pullrequests/$pr_id?api-version=7.1" | jq_ 'd["lastMergeSourceCommit"]["commitId"]') == "$head_before" ]] && echo yes || echo no)"

say "UAT-HOOK-005 coalescing, and each command answered once"
c2="$(comment "/vizzini explain Is this input validated?")"
event "$c2" "$run/event2.json"
for i in 1 2 3; do rec "deliver2_$i" "$(deliver "$port" "$run/event2.json" | grep -o '"queue":"[a-z]*"')"; done
rec reply2_seconds "$(wait_reply "$c2" 180)"
sleep 20 # any follow-up run ends
rec replies_c1 "$(replies_to "$c1")"
rec replies_c2 "$(replies_to "$c2")"

say "UAT-HOOK-006 commands only: nothing reviewed, posted or resolved"
"$root/uat/ado.sh" threads "$pr" >"$run/threads-after.json"
rec bot_threads_after "$(python3 -I -c '
import json, sys
ts = [t for t in json.load(open(sys.argv[1]))["value"]
      if t.get("threadContext") and "<!-- vizzini:fp=" in ((t.get("comments") or [{}])[0].get("content") or "")]
resolved = sum(1 for t in ts for c in t.get("comments") or [] if "<!-- vizzini:reviewed " in (c.get("content") or ""))
print(len(ts), resolved)' "$run/threads-after.json")"

say "UAT-HOOK-007 a denied reply names the identity to allow"
c3="$(comment "/vizzini explain Why this name?")"
event "$c3" "$run/event3.json"
rec deliver3_deny "$(deliver "$port_deny" "$run/event3.json" | cut -d' ' -f1)"
for _ in $(seq 60); do grep -q '"job failed"' "$run/webhook-deny.log" && break; sleep 3; done
rec deny_logged "$(grep -c 'grant policy denied the reply' "$run/webhook-deny.log" || true)"
rec deny_names_identity "$(python3 -I -c '
import sys
log, ident = open(sys.argv[1]).read(), sys.argv[2]
print("yes" if "add \\\"" + ident + "\\\" to _allowedIdentities" in log else "no")' "$run/webhook-deny.log" "$identity")"
rec replies_c3_denied "$(replies_to "$c3")"
rec deliver3_allow "$(deliver "$port" "$run/event3.json" | cut -d' ' -f1)"
rec reply3_seconds "$(wait_reply "$c3" 180)"

say "UAT-HOOK-008 no secret or identity in the logs"
# The values are read from files (-f), never put on grep's command line.
count() { grep -cFf "$1" "$run/webhook.log" "$run/webhook-deny.log" | awk -F: '{s+=$2} END {print s}'; }
rec log_has_pat "$(count "$pat_file")"
rec log_has_secret "$(count "$run/webhook.secret")"
printf '%s\n' "$VIZZINI_REQUESTER" >"$run/.requester"
rec log_has_requester "$(count "$run/.requester")"
rm -f "$run/.requester"

say "UAT-HOOK-009 a clean shutdown"
kill -TERM "$main_pid"
set +e
wait "$main_pid"
rec shutdown_exit "$?"
set -e
rec shutdown_logged "$(grep -c '"shutting down' "$run/webhook.log" || true)"
rec experimental_warning "$(grep -c 'EXPERIMENTAL' "$run/webhook.log" || true)"

say "checks"
python3 -I - "$run" "$c1" "$c2" "$c3" "$findings" <<'EOF' | tee "$run/summary.md"
import json, os, re, sys
run, c1, c2, c3, findings = sys.argv[1:]
r = dict(l.rstrip("\n").split("\t", 1) for l in open(os.path.join(run, "results.txt")))
log = open(os.path.join(run, "webhook.log")).read()
ok = True
def check(cond, what):
    global ok
    ok &= bool(cond)
    print(("- [x] " if cond else "- [ ] ") + what)
def secs(k):
    return int(r[k]) if r.get(k, "").isdigit() else None
print("# vizzini-webhook (experimental), live on Azure DevOps\n")
print("## UAT-HOOK-001 health\n")
check(r["health"] == "200", "GET /healthz answers 200")
print("\n## UAT-HOOK-002 authentication\n")
check(r["auth_none"] == "401", "a delivery without credentials is refused with 401")
check(r["auth_wrong"] == "401", "a delivery with a wrong password is refused with 401")
check(r["auth_get"] == "405", "GET on the hook is refused with 405")
print("\n## UAT-HOOK-003 filtering\n")
for k, reason in [("plain", "no /vizzini command"), ("bot", "written by the bot"), ("other-repo", "repository not allowlisted"),
                  ("inactive", "pull request not active"), ("push", "not a pull request comment event")]:
    v = r["ignore_" + k]
    check(v.startswith("200 ") and '"accepted":false' in v and reason in v, f"{k}: ignored with 200 ({reason})")
check(r["ignore_ado_sample"] == "400", "ADO's own sample event (legacy visualstudio.com host) is refused with 400")
print("\n## UAT-HOOK-004 an immediate answer, with no push\n")
check(r["deliver1"].startswith("202 ") and '"queue":"queued"' in r["deliver1"], "the command's delivery is accepted with 202, queued")
s1 = secs("reply1_seconds")
check(s1 is not None and s1 <= 120, f"the reply appears in the thread in {r['reply1_seconds']} s (at most 120)")
check(r["head_unchanged"] == "yes", "the PR's head did not move: no push was needed")
check(re.search(r'"msg":"job done".*"answered":\["' + c1 + r'"\]', log), "the receiver logged the job done, with the comment answered")
print("\n## UAT-HOOK-005 coalescing, and each command answered once\n")
states = [r[f"deliver2_{i}"] for i in (1, 2, 3)]
check(states[0] == '"queue":"queued"' and all(s in ('"queue":"coalesced"', '"queue":"again"') for s in states[1:]),
      f"three deliveries of one comment: {', '.join(states)}")
check(secs("reply2_seconds") is not None, f"the second command is answered ({r['reply2_seconds']} s)")
check(r["replies_c2"] == "1", f"it has exactly one reply ({r['replies_c2']})")
check(r["replies_c1"] == "1", f"the first command still has exactly one reply ({r['replies_c1']})")
print("\n## UAT-HOOK-006 commands only\n")
n, resolved = r["bot_threads_after"].split()
check(n == findings and resolved == "0", f"the bot's finding threads are unchanged ({n} of {findings}) and none was resolved")
print("\n## UAT-HOOK-007 a denied reply names the identity to allow\n")
check(r["deliver3_deny"] == "202", "the receiver with the committed policy accepts the delivery")
check(r["deny_logged"] != "0", "its job is denied by the grant policy")
check(r["deny_names_identity"] == "yes", "the log names the identity to add to _allowedIdentities")
check(r["replies_c3_denied"] == "0", "nothing was posted for the denied command")
check(r["deliver3_allow"] == "202" and secs("reply3_seconds") is not None,
      f"the receiver with the allow policy then answers it ({r['reply3_seconds']} s)")
print("\n## UAT-HOOK-008 no secret or identity in the logs\n")
check(r["log_has_pat"] == "0", "the PAT is in no log")
check(r["log_has_secret"] == "0", "the webhook password is in no log")
check(r["log_has_requester"] == "0", "the requester's identity is in no log (redacted)")
print("\n## UAT-HOOK-009 a clean shutdown\n")
check(r["shutdown_exit"] == "0", "SIGTERM: the receiver exits 0")
check(r["shutdown_logged"] != "0", "it logs the shutdown")
check(r["experimental_warning"] != "0", "it warns at start that it is experimental")
print("\nresult: " + ("PASS" if ok else "FAIL"))
sys.exit(0 if ok else 1)
EOF
