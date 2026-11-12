#!/usr/bin/env bash
# workflow.sh: the full review workflow, live on Azure DevOps: Vizzini
# reviews; the developer (a person or an agent) fixes, defends or disputes;
# a person settles what stays in dispute (Vizzini ISSUE-027/028/029,
# ADR-0023). The wiki's suite TS-WF lists the cases.
#
#   uat/workflow.sh
#
# The fixture is a small Go module, wf/, with one planted defect per variant:
#
#   person.go    a person fixes it            -> the bot resolves its thread
#   agent.go     the agent fixes it, located   -> the bot resolves its thread
#                through the findings view
#   nofix.go     a change that does not fix   -> the thread stays, no duplicate
#   defend.go    the agent argues, then        -> the finding stands, open;
#                /vizzini reconsider           a person settles it by design;
#                                              the suggested rule, merged to
#                                              the base, suppresses it
#   withdraw.go  /vizzini reconsider with a    -> withdrawn: the bot resolves
#                winning argument              its own thread, never reposts
#   regress.go   a new defect in round 2      -> a new thread
#
# stubllm is the model: one finding per linter diagnostic on a changed line
# (each round writes its golangci-lint JSON), and a /reconsider withdraws
# only when the argument holds "[stub:withdraw]". So every outcome is
# deterministic, and the test checks the workflow, not a model.
#
# The developer agent acts only through mrman, as an agent would:
# `review threads --findings`, `review reply`, under its own policy (reply
# only). It also tries what it must not do: resolve the bot's thread,
# approve, and grant itself.
#
# With a second ADO account's PAT in ~/.config/vizzini-lab/ado-dev.pat (the
# developer's own identity), two more cases run: the agent cannot resolve the
# bot's threads even with resolve allowed (mrman's own-thread rule), and
# --command-authors can exclude it. Without that file they are BLOCKED.
#
# Writes .cache/runs/<UTC>-workflow/; the PR is abandoned and its branch
# deleted at the end. Exits non-zero when a check fails.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
bin="$root/.cache/bin"
src="$root/.cache/src"
committed="$src/mrman/policies/garmr/mrman"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/vizzini-lab"

say() { printf '\n== %s\n' "$*"; }
die() { printf 'workflow: %s\n' "$*" >&2; exit 1; }
for b in vizzini-bot mrman garmr stubllm; do [[ -x $bin/$b ]] || die "$bin/$b missing; run uat/build.sh"; done
"$bin/mrman" review threads --help 2>&1 | grep -q -- --findings || die "the pinned mrman has no review threads --findings (ISSUE-027)"

ADO_REPO_URL="${ADO_REPO_URL:-$(sed -n 's/^ADO_REPO_URL=//p' "$cfg/ado.env" | tail -1)}"
[[ $ADO_REPO_URL =~ ^https://dev\.azure\.com/([^/]+)/([^/]+)/_git/([^/]+)$ ]] || die "set ADO_REPO_URL"
ORG="${BASH_REMATCH[1]}" PROJECT="${BASH_REMATCH[2]}" REPO="${BASH_REMATCH[3]}"
repo_key="dev.azure.com/$ORG/$PROJECT/$REPO"
api_base="https://dev.azure.com/$ORG/$PROJECT/_apis/git/repositories/$REPO"
pat_file="${ADO_PAT_FILE:-$cfg/ado.pat}"
dev_pat_file="$cfg/ado-dev.pat"

# api METHOD URL [JSON], retried as uat/ado.sh retries (ADR-0011): only what
# cannot have been applied, or an idempotent method.
api() {
	local try rc out
	for try in 1 2 3; do
		rc=0
		out="$(printf 'header = "Authorization: Basic %s"\n' "$(printf ':%s' "$(<"$pat_file")" | base64 -w0)" |
			curl -fsS -K - -X "$1" -H 'Content-Type: application/json' ${3:+--data "$3"} "$2")" || rc=$?
		case "$rc:$1" in
		6:* | 7:* | 35:* | 52:GET | 52:PATCH | 56:GET | 56:PATCH) sleep $((try * 5)) ;;
		*) break ;;
		esac
	done
	[[ $rc == 0 ]] && printf '%s' "$out"
	return "$rc"
}
jq_() { python3 -I -c "import json,sys; d=json.load(sys.stdin); print($1)"; }

export TIKTOKEN_CACHE_DIR="$root/.cache/tiktoken"
"$src/vizzini/scripts/tiktoken-cache.sh" "$TIKTOKEN_CACHE_DIR" >/dev/null
run="$root/.cache/runs/$(date -u +%Y%m%dT%H%M%SZ)-workflow"
mkdir -p "$run"
cp "$bin/build-manifest.json" "$run/"
echo "run: $run"
results="$run/results.txt"
: >"$results"
rec() { printf '%s\t%s\n' "$1" "$2" >>"$results"; echo "   $1: $2"; }

pids=() pr="" head_branch=""
cleanup() {
	say "cleanup"
	local p
	for p in "${pids[@]}"; do kill "$p" 2>/dev/null || true; done
	[[ -n $pr ]] && api PATCH "$api_base/pullrequests/${pr##*/}?api-version=7.1" '{"status":"abandoned"}' >/dev/null && echo "   PR ${pr##*/} abandoned"
	if [[ -n $head_branch ]]; then
		git -C "$repo" -c credential.helper= -c "credential.helper=!f() { echo username=pat; echo \"password=\$(cat '$pat_file')\"; }; f" \
			push -q "$ADO_REPO_URL" --delete "$head_branch" 2>/dev/null && echo "   branch $head_branch deleted"
	fi
	return 0
}
trap cleanup EXIT

say "model: stubllm"
addr="127.0.0.1:${STUB_PORT:-18775}"
"$bin/stubllm" -addr "$addr" -log "$run/stub-prompts.log" 2>"$run/stubllm.err" &
pids+=($!)
for _ in $(seq 50); do curl -s -o /dev/null "http://$addr/" && break; sleep 0.1; done
export VIZZINI_LITELLM_URL="http://$addr/v1" VIZZINI_MODEL=stub
unset VIZZINI_API_KEY

# --- the fixture ------------------------------------------------------------
repo="$run/repo"
g() { git -C "$repo" -c user.name=vizzini-lab -c user.email=uat@example.invalid "$@"; }
git init -q -b uat-base "$repo"
mkdir -p "$repo/wf"
printf 'module example.com/wf\n\ngo 1.23\n' >"$repo/go.mod"
cat >"$repo/wf/helpers.go" <<'EOF'
package wf

import (
	"crypto/md5"  //nolint:gosec // the planted defect's helper
	"crypto/sha256"
	"encoding/hex"
)

func weakHash(s string) string   { h := md5.Sum([]byte(s)); return hex.EncodeToString(h[:]) }
func strongHash(s string) string { h := sha256.Sum256([]byte(s)); return hex.EncodeToString(h[:]) }
EOF
g add -A
g commit -qm "workflow base: helpers"
g checkout -qb uat-head
# defect FILE NAME: wf/FILE with the planted defect on line 5.
defect() {
	printf 'package wf\n\n// %s hashes a token.\nfunc %s(s string) string {\n\treturn weakHash(s)\n}\n' "$2" "$2" >"$repo/wf/$1"
}
defect person.go Person
defect agent.go Agent
defect nofix.go NoFix
defect defend.go Defend
defect withdraw.go Withdraw
g add -A
g commit -qm "workflow: five token hashes"

# lint ROUND FILE:LINE...: the round's golangci-lint JSON, one gosec G401 each.
lint() {
	local out="$run/lint-$1.json"
	shift
	python3 -I - "$out" "$@" <<'EOF'
import json, sys
out, *locs = sys.argv[1:]
issues = [{"FromLinter": "gosec", "Text": "G401: Use of weak cryptographic primitive",
           "Pos": {"Filename": l.split(":")[0], "Line": int(l.split(":")[1]), "Column": 9}} for l in locs]
json.dump({"Issues": issues}, open(out, "w"))
EOF
	echo "$out"
}

say "the PR"
"$root/uat/ado.sh" check
VIZZINI_REQUESTER="$("$root/uat/ado.sh" whoami)"
"$root/uat/ado.sh" base "$repo" workflow
pr="$("$root/uat/ado.sh" up "$repo" "wf" workflow)"
pr_id="${pr##*/}"
echo "$pr" >"$run/pr-url"
head_branch="$(api GET "$api_base/pullrequests/$pr_id?api-version=7.1" | jq_ 'd["sourceRefName"][len("refs/heads/"):]')"
echo "   PR $pr_id ($head_branch)"

# --- the bot, as CI runs it ---------------------------------------------------
# bot NAME LINT [ARGS...]: one vizzini-bot run from the checkout.
bot() {
	local d="$run/bot-$1" lintf=$2
	shift 2
	mkdir -p "$d/mrman-data"
	set +e
	(cd "$repo" && AZURE_DEVOPS_EXT_PAT="$(<"$pat_file")" XDG_DATA_HOME="$d/mrman-data" VIZZINI_REQUESTER="$VIZZINI_REQUESTER" \
		"$bin/vizzini-bot" --repo . --base uat-base --head uat-head --pr-url "$pr" --mrman "$bin/mrman" --garmr "$bin/garmr" \
		--pr "ado:$repo_key#$pr_id" --lint-json "$lintf" "$@") >"$d/bot.json" 2>"$d/bot.err"
	echo $? >"$d/bot.code"
	set -e
	find "$d/mrman-data" -name '*.audit.jsonl' -exec cat {} + >"$d/audit.jsonl" 2>/dev/null || true
	sed -n 's/^vizzini-bot: /   bot: /p' "$d/bot.err"
}

say "round 0: the review"
lint0="$(lint 0 wf/person.go:5 wf/agent.go:5 wf/nofix.go:5 wf/defend.go:5 wf/withdraw.go:5)"
bot deny "$lint0" --grant-policy "$committed"
identity="$(python3 -I -c '
import json, sys
recs = [json.loads(l) for l in open(sys.argv[1]) if l.strip()]
print(recs[-1]["input"]["identity"] if recs else "")' "$run/bot-deny/audit.jsonl")"
[[ -n $identity ]] || die "no identity from the deny run; see $run/bot-deny/bot.err"
# policy DIR EVENTS IDENTITIES: mrman's committed pack with these lists.
policy() {
	mkdir -p "$1"
	python3 -I - "$committed/agent-submit.cue" "$1/agent-submit.cue" "$2" "$3" <<'EOF'
import json, sys
src, dst, events, idents = sys.argv[1:]
t = open(src).read()
for old, new in (('_allowedIdentities: ["vizzini-bot"]', "_allowedIdentities: " + idents),
                 ('_allowedEvents: ["comment", "resolve", "reply"]', "_allowedEvents: " + events)):
    assert t.count(old) == 1, old
    t = t.replace(old, new)
open(dst, "w").write(t)
EOF
	"$bin/garmr" validate "$1" >/dev/null || die "garmr validate $1"
}
ident_json="$(python3 -I -c 'import json,sys; print(json.dumps([sys.argv[1]]))' "$identity")"
policy "$run/policy-bot/mrman" '["comment", "resolve", "reply"]' "$ident_json"
policy "$run/policy-agent/mrman" '["reply"]' "$ident_json"
bot r0 "$lint0" --grant-policy "$run/policy-bot/mrman"

# --- the developer agent: mrman only -----------------------------------------
agent_data="$run/agent-mrman"
mkdir -p "$agent_data"
# agent ARGS...: mrman as the developer agent, with its own data directory.
agent() { AZURE_DEVOPS_EXT_PAT="$(<"${AGENT_PAT_FILE:-$pat_file}")" XDG_DATA_HOME="$agent_data" "$bin/mrman" "$@"; }
# aread ARGS...: a read-only agent call, retried on a network error (a read
# is always safe to repeat).
aread() {
	local try out code
	for try in 1 2 3 4; do
		code=0
		out="$(agent "$@" 2>"$run/.aread.err")" || code=$?
		[[ $code != 0 ]] && grep -q "network error" "$run/.aread.err" && { sleep $((try * 5)); continue; }
		break
	done
	cat "$run/.aread.err" >&2
	printf '%s\n' "$out"
	return "$code"
}
# A traceable agent gives every unattended action a run id (policy MRM-004).
agent_run="dev-agent-$(python3 -I -c 'import uuid; print(uuid.uuid4())')"
slug="$(aread pr "$pr" --json | jq_ 'd["slug"]')"
view() { aread review threads --session "$slug" --findings >"$run/findings-$1.json"; }
fthread() { # fthread VIEW FILE: the finding thread on wf/FILE
	python3 -I -c '
import json, sys
for f in json.load(open(sys.argv[1]))["findings"]:
    if f["path"] == "wf/" + sys.argv[2]:
        print(f["thread"]); break' "$run/findings-$1.json" "$2"
}
areply() { # areply THREAD BODY: the agent replies; prints mrman's exit code
	local f="$run/.reply.md" code try out
	printf '%s' "$2" >"$f"
	# A network error with no comment id means nothing was posted, so a retry
	# cannot post twice (ADR-0011).
	for try in 1 2 3; do
		code=0
		out="$(agent review reply --session "$slug" --thread "$1" --input "@$f" --grant-policy "$run/policy-agent/mrman" \
			--garmr "$bin/garmr" --agent dev-agent --run-id "$agent_run" 2>&1)" || code=$?
		printf '%s\n' "$out" >>"$run/agent-replies.log"
		[[ $code != 0 && $out == *"network error"* && $out != *'"comment_id"'* ]] || break
		sleep $((try * 5))
	done
	rm -f "$f"
	echo "$code"
}

say "round 1: the agent reads the findings"
view r0
python3 -I - "$run/findings-r0.json" "$results" <<'EOF'
import json, sys
v = json.load(open(sys.argv[1]))
fs = v["findings"]
ok_fields = all(f["category"] == "Security" and f["severity"] == "Major" and f["fingerprint"].startswith("v1:")
                and f["posted_start_line"] == 5 and f["status"] == "open" and f["agent"] == "vizzini-bot" and f["title"] for f in fs)
open(sys.argv[2], "a").write(f"view_r0_count\t{len(fs)}\nview_r0_fields\t{'yes' if ok_fields else 'no'}\n"
                             f"view_r0_paths\t{','.join(sorted(f['path'] for f in fs))}\nview_r0_malformed\t{len(v['malformed'])}\n")
EOF
tail -4 "$results" | sed 's/\t/: /; s/^/   /'
for f in person agent nofix defend withdraw; do eval "t_$f=\$(fthread r0 $f.go)"; done
# shellcheck disable=SC2154 # set by the eval above
echo "   threads: person $t_person, agent $t_agent, nofix $t_nofix, defend $t_defend, withdraw $t_withdraw"

say "round 1: guardrails: what the agent must not do"
# attempt NAME ARGS...: an agent action that must be refused, retried only
# when a network error stopped it before any authorization decision (so it
# did nothing); its exit code goes to NAME.
attempt() {
	local name=$1 try code
	shift
	for try in 1 2 3; do
		code=0
		agent "$@" >"$run/$name.json" 2>"$run/$name.err" || code=$?
		if ! grep -q "network error" "$run/$name.err" || grep -q '"decision"' "$run/$name.json" "$run/$name.err"; then
			break
		fi
		sleep $((try * 5))
	done
	rec "${name//-/_}_exit" "$code"
}
attempt guard-resolve review resolve --session "$slug" --thread "$t_agent" --grant-policy "$run/policy-agent/mrman" \
	--garmr "$bin/garmr" --agent dev-agent --run-id "$agent_run"
agent review add --session "$slug" --target-file wf/agent.go --line 5 "Looks good to me." >/dev/null 2>&1 || true
attempt guard-approve review submit --session "$slug" --event approve --grant-policy "$run/policy-agent/mrman" \
	--garmr "$bin/garmr" --agent dev-agent --run-id "$agent_run"
set +e
agent pr "$pr" --auto --json >"$run/guard-auto.out" 2>&1
rec guard_auto_exit "$?"
set -e
# denied_by FILE: the rules a deny decision in FILE failed ("" if none).
denied_by() {
	python3 -I -c '
import json, sys
for line in open(sys.argv[1], errors="replace"):
    line = line.strip()
    if line.startswith("{"):
        try:
            d = json.loads(line)
        except ValueError:
            continue
        a = d.get("authorization", d)
        if a.get("decision") == "deny":
            print(",".join(a.get("failed") or [])); break' "$1"
}
rec guard_resolve_denied_by "$(denied_by "$run/guard-resolve.json")"
rec guard_approve_denied_by "$(denied_by "$run/guard-approve.json")"
rec guard_approval_votes "$(api GET "$api_base/pullrequests/$pr_id/reviewers?api-version=7.1" | jq_ 'sum(1 for r in d["value"] if r.get("vote", 0) > 0)')"

say "round 1: the agent defends and disputes"
rec defend_reply_exit "$(areply "$t_defend" "This is intentional: the value is a cache key, not a secret.")"
rec defend_cmd_exit "$(areply "$t_defend" "/vizzini reconsider The value is a cache key, never a credential.")"
rec withdraw_cmd_exit "$(areply "$t_withdraw" "/vizzini reconsider [stub:withdraw] This path only runs in tests, behind a build tag.")"

say "round 1: fixes and changes, pushed"
sed -i 's/weakHash(s)/strongHash(s)/' "$repo/wf/person.go"
# The agent fixes by the findings view: the file and line it names.
python3 -I - "$run/findings-r0.json" "$repo" <<'EOF'
import json, sys
view, repo = sys.argv[1:]
f = next(f for f in json.load(open(view))["findings"] if f["path"] == "wf/agent.go")
p = f"{repo}/{f['path']}"
lines = open(p).read().split("\n")
i = f["posted_start_line"] - 1
assert "weakHash" in lines[i], lines[i]
lines[i] = lines[i].replace("weakHash", "strongHash")
open(p, "w").write("\n".join(lines))
EOF
sed -i 's|^\treturn weakHash(s)|\t// still the weak hash, only moved\n\treturn weakHash(s)|' "$repo/wf/nofix.go"
defect regress.go Regress
g add -A
g commit -qm "round 1: fix person and agent, touch nofix, add regress"
"$root/uat/ado.sh" push "$repo" "$pr"
lint1="$(lint 1 wf/nofix.go:6 wf/regress.go:5 wf/defend.go:5 wf/withdraw.go:5)"
bot r1 "$lint1" --grant-policy "$run/policy-bot/mrman"
view r1

say "round 2: a person settles the dispute (by design)"
"$root/uat/ado.sh" status "$pr" "$t_defend" byDesign >/dev/null
bot r2 "$lint1" --grant-policy "$run/policy-bot/mrman"
view r2
python3 -I - "$run/findings-r2.json" "$t_defend" "$run/suggested-rule.yaml" <<'EOF'
import json, re, sys
view, thread, out = sys.argv[1:]
f = next(f for f in json.load(open(view))["findings"] if f["thread"] == thread)
for r in f["replies"]:
    if "vizzini:suggested-suppression" in r["body"]:
        m = re.search(r"```ya?ml\n(.*?)```", r["body"], re.S)
        if m:
            open(out, "w").write(m.group(1))
EOF
[[ -s $run/suggested-rule.yaml ]] || die "no suggested rule in the defend thread; see $run/findings-r2.json"

say "round 3: the rule merged to the base; a full review"
g checkout -q uat-base
mkdir -p "$repo/.vizzini"
cp "$run/suggested-rule.yaml" "$repo/.vizzini/suppressions.yaml"
g add -A
g commit -qm "suppress the cache-key hash (settled by design)"
"$root/uat/ado.sh" base "$repo" workflow
g checkout -q uat-head
bot r3 "$lint1" --grant-policy "$run/policy-bot/mrman" --full
view r3

say "identity separation (needs $dev_pat_file)"
if [[ -r $dev_pat_file ]]; then
	AGENT_PAT_FILE="$dev_pat_file"
	agent_data="$run/agent-dev-mrman"
	mkdir -p "$agent_data"
	slug="$(aread pr "$pr" --json | jq_ 'd["slug"]')"
	# The developer's identity, as mrman verifies it: from the denial of a
	# reply under the policy that lists only the bot's identity.
	areply "$t_nofix" "probe" >/dev/null
	dev_identity="$(find "$agent_data" -name '*.audit.jsonl' -exec cat {} + | python3 -I -c '
import json, sys
recs = [json.loads(l) for l in sys.stdin if l.strip()]
print(recs[-1]["input"]["identity"] if recs else "")')"
	[[ -n $dev_identity && $dev_identity != "$identity" ]] || die "the second account's identity is missing or the same as the bot's"
	both="$(python3 -I -c 'import json,sys; print(json.dumps(sys.argv[1:]))' "$identity" "$dev_identity")"
	policy "$run/policy-dev/mrman" '["comment", "resolve", "reply"]' "$both"
	set +e
	agent review resolve --session "$slug" --thread "$t_nofix" --grant-policy "$run/policy-dev/mrman" --garmr "$bin/garmr" \
		--agent dev-agent --run-id "$agent_run" >"$run/id-resolve.json" 2>"$run/id-resolve.err"
	rec id_resolve_exit "$?"
	set -e
	rec id_resolve_refused "$(grep -c "not own thread\|did not start\|forbidden\|Forbidden" "$run/id-resolve.json" "$run/id-resolve.err" | awk -F: '{s+=$2} END {print s}')"
	f="$run/.cmd.md"
	printf '/vizzini explain What does this line do?' >"$f"
	agent review reply --session "$slug" --thread "$t_nofix" --input "@$f" --grant-policy "$run/policy-dev/mrman" --garmr "$bin/garmr" \
		--agent dev-agent --run-id "$agent_run" >/dev/null 2>&1
	rm -f "$f"
	bot r4 "$lint1" --grant-policy "$run/policy-bot/mrman" --command-authors "$identity"
	rec id_command_answered "$(python3 -I -c 'import json,sys; print(len(json.load(open(sys.argv[1])).get("answered") or []))' "$run/bot-r4/bot.json")"
else
	rec identity BLOCKED
	echo "   BLOCKED: no second account; UAT-WF-014 and UAT-WF-015 are not run"
fi

say "checks"
python3 -I - "$run" "$t_person" "$t_agent" "$t_nofix" "$t_defend" "$t_withdraw" <<'EOF' | tee "$run/summary.md"
import json, os, sys
run, t_person, t_agent, t_nofix, t_defend, t_withdraw = sys.argv[1:]
r = dict(l.rstrip("\n").split("\t", 1) for l in open(os.path.join(run, "results.txt")))
def view(n): return {f["thread"]: f for f in json.load(open(os.path.join(run, f"findings-{n}.json")))["findings"]}
def botres(n): return json.load(open(os.path.join(run, f"bot-{n}", "bot.json")))
def code(n): return open(os.path.join(run, f"bot-{n}", "bot.code")).read().strip()
v0, v1, v2, v3 = view("r0"), view("r1"), view("r2"), view("r3")
b0, b1, b2, b3 = botres("r0"), botres("r1"), botres("r2"), botres("r3")
ok = True
def check(cond, what):
    global ok
    ok &= bool(cond)
    print(("- [x] " if cond else "- [ ] ") + what)
def replies(v, t, pred): return [x for x in v[t]["replies"] if pred(x)]
print("# The full review workflow, live on Azure DevOps (stubllm)\n")
print("## UAT-WF-001 the review\n")
check(code("r0") == "0" and b0["posted"] == 5, f"the bot posts one thread per finding ({b0.get('posted')})")
print("\n## UAT-WF-002 the agent reads the findings view\n")
check(r["view_r0_count"] == "5" and r["view_r0_malformed"] == "0", f"five findings, none malformed ({r['view_r0_count']})")
check(r["view_r0_fields"] == "yes", "each is decoded: Security, Major, a v1 fingerprint, posted at line 5, open, by vizzini-bot")
check(r["view_r0_paths"] == "wf/agent.go,wf/defend.go,wf/nofix.go,wf/person.go,wf/withdraw.go", "with the right files")
print("\n## UAT-WF-003 a person fixes\n")
check(v1[t_person]["status"] == "resolved" and replies(v1, t_person, lambda x: x["from_vizzini"] and "Resolved by vizzini-bot" in x["body"]),
      "the bot resolves the thread, with a reply")
print("\n## UAT-WF-004 the agent fixes, located by the findings view\n")
check(v1[t_agent]["status"] == "resolved", "the bot resolves the agent-fixed thread")
check(not any(x["author"] and not x["from_vizzini"] for x in v1[t_agent]["replies"]), "the agent did not reply or resolve there")
print("\n## UAT-WF-005 a change that does not fix\n")
check(v1[t_nofix]["status"] == "open", "the thread stays open")
check(sum(1 for f in v1.values() if f["path"] == "wf/nofix.go") == 1, "no duplicate thread on wf/nofix.go")
print("\n## UAT-WF-006 a new defect\n")
check(sum(1 for f in v1.values() if f["path"] == "wf/regress.go" and f["status"] == "open") == 1, "one new thread on wf/regress.go")
print("\n## UAT-WF-007 defend: the argument, and a finding that stands\n")
check(r["defend_reply_exit"] == "0" and r["defend_cmd_exit"] == "0", "the agent replies through mrman under its own policy (reply)")
stands = replies(v1, t_defend, lambda x: x["from_vizzini"] and "The finding stands" in x["body"])
check(len(stands) == 1 and stands[0]["reply_to"], "the bot answers the reconsider once: the finding stands")
check(v1[t_defend]["status"] == "open", "the thread stays open for a person")
print("\n## UAT-WF-008 a withdrawn finding\n")
check(r["withdraw_cmd_exit"] == "0", "the agent writes /vizzini reconsider through mrman")
check(v1[t_withdraw]["status"] == "resolved" and replies(v1, t_withdraw, lambda x: x["from_vizzini"] and "Withdrawn" in x["body"]),
      "the bot withdraws: it resolves its own thread, with its reasons")
check(t_withdraw in b1.get("withdrawn", []), "the bot's result lists the withdrawal")
check(b3.get("posted", 0) == 0 and sum(1 for f in v3.values() if f["path"] == "wf/withdraw.go") == 1,
      "a later full review does not post it again")
print("\n## UAT-WF-009 a person settles: by design\n")
sugg = replies(v2, t_defend, lambda x: "vizzini:suggested-suppression" in x["body"])
check(len(sugg) == 1 and t_defend in b2.get("suggested", []), "the bot suggests one suppression rule")
check(v2[t_defend]["disposition"] == "by design", "the thread is resolved as by design")
print("\n## UAT-WF-010 the rule, merged to the base\n")
check(any("wf/defend.go" in s for s in b3.get("suppressed", [])), f"a full review suppresses the finding ({b3.get('suppressed')})")
check(sum(1 for f in v3.values() if f["path"] == "wf/defend.go") == 1 and not b3.get("suggested"), "no new thread, no second suggestion")
check(v3[t_defend]["disposition"] == "by design", "the settled thread is left as it was")
print("\n## UAT-WF-011 the agent cannot resolve (its policy has no resolve)\n")
check(r["guard_resolve_exit"] != "0" and r["guard_resolve_denied_by"] == "MRM-001",
      f"mrman refuses: the policy denies event resolve, by MRM-001 only ({r['guard_resolve_denied_by']})")
print("\n## UAT-WF-012 the agent cannot approve\n")
# MRM-001 (the event) must deny it. MRM-002 may join when the forge did not
# say who the token is: mrman then fails closed with an empty identity.
check(r["guard_approve_exit"] != "0" and "MRM-001" in r["guard_approve_denied_by"].split(","),
      f"mrman refuses: the policy denies event approve, by MRM-001 ({r['guard_approve_denied_by']})")
check(r["guard_approval_votes"] == "0", "the PR has no approval vote")
print("\n## UAT-WF-013 the agent cannot grant itself\n")
check(r["guard_auto_exit"] != "0", "mrman refuses --auto without a terminal")
print("\n## UAT-WF-014 / 015 identity separation\n")
if r.get("identity") == "BLOCKED":
    print("- BLOCKED: no second ADO account (~/.config/vizzini-lab/ado-dev.pat); not run")
else:
    check(r["id_resolve_exit"] != "0" and r["id_resolve_refused"] != "0",
          "the agent's own account cannot resolve the bot's thread, even with resolve allowed")
    check(r["id_command_answered"] == "0", "--command-authors excludes the agent: its command is not answered")
print("\nresult: " + ("PASS" if ok else "FAIL"))
sys.exit(0 if ok else 1)
EOF
