#!/usr/bin/env bash
# reconsider.sh: /vizzini reconsider with a live model, on Azure DevOps
# (Vizzini ISSUE-029, ADR-0023). TS-WF proves the mechanics with stubllm,
# whose verdict is scripted; here a real model reads a real argument.
#
#   uat/reconsider.sh [--model MODEL]    (default claude-sonnet-5-5)
#
# The fixture is a small Go module, wf/, with two disputed findings:
#
#   form.go   gosec G101 on a form field's *name* ("password"), a known
#             false positive. The developer's argument shows it.
#             Expected verdict: withdrawn.
#   login.go  gosec G401: MD5 hashes stored passwords. The developer's
#             argument only asserts that it is fine.
#             Expected verdict: stands.
#
# Round 0: stubllm reviews (deterministic findings, no tokens) and the bot
# posts two threads. The developer agent writes /vizzini reconsider in each,
# through mrman under its own policy (reply only). Round 1: the bot, as CI
# runs it, answers the commands with the live model through LiteLLM. Round 2:
# the bot runs again and must answer nothing.
#
# Hard checks cover what Vizzini promises whatever the model says: both
# answered once, through the CUE schema, and each verdict acted on (withdrawn:
# the bot resolves its own thread; stands: it stays open for a person), and
# the model calls attributed. Whether the model reached the expected verdicts
# is model quality: a metric, reported, never a failure (CLAUDE.md rule 4).
#
# Writes .cache/runs/<UTC>-reconsider-<model>/; the PR is abandoned and its
# branch deleted at the end. Exits non-zero when a hard check fails.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
bin="$root/.cache/bin"
src="$root/.cache/src"
committed="$src/mrman/policies/garmr/mrman"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/vizzini-lab"

say() { printf '\n== %s\n' "$*"; }
die() { printf 'reconsider: %s\n' "$*" >&2; exit 1; }

model=claude-sonnet-5-5
while (($#)); do
	case $1 in
	--model) model=${2:?--model needs a value}; shift 2 ;;
	*) die "unknown argument $1" ;;
	esac
done
grep -q "model_name: $model\$" "$root/litellm/config.yaml" || die "$model is not in litellm/config.yaml"
for b in vizzini-bot mrman garmr stubllm; do [[ -x $bin/$b ]] || die "$bin/$b missing; run uat/build.sh"; done
"$root/litellm/litellm.sh" status >/dev/null || die "LiteLLM is not running: litellm/litellm.sh up"

ADO_REPO_URL="${ADO_REPO_URL:-$(sed -n 's/^ADO_REPO_URL=//p' "$cfg/ado.env" | tail -1)}"
[[ $ADO_REPO_URL =~ ^https://dev\.azure\.com/([^/]+)/([^/]+)/_git/([^/]+)$ ]] || die "set ADO_REPO_URL"
ORG="${BASH_REMATCH[1]}" PROJECT="${BASH_REMATCH[2]}" REPO="${BASH_REMATCH[3]}"
repo_key="dev.azure.com/$ORG/$PROJECT/$REPO"
api_base="https://dev.azure.com/$ORG/$PROJECT/_apis/git/repositories/$REPO"
pat_file="${ADO_PAT_FILE:-$cfg/ado.pat}"

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
run="$root/.cache/runs/$(date -u +%Y%m%dT%H%M%SZ)-reconsider-$model"
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

say "models: stubllm reviews, $model reconsiders"
stub_addr="127.0.0.1:${STUB_PORT:-18776}"
"$bin/stubllm" -addr "$stub_addr" -log "$run/stub-prompts.log" 2>"$run/stubllm.err" &
pids+=($!)
for _ in $(seq 50); do curl -s -o /dev/null "http://$stub_addr/" && break; sleep 0.1; done
eval "$("$root/litellm/litellm.sh" env)"
live_url=$VIZZINI_LITELLM_URL live_key=$VIZZINI_API_KEY
unset VIZZINI_LITELLM_URL VIZZINI_API_KEY

# --- the fixture ------------------------------------------------------------
repo="$run/repo"
g() { git -C "$repo" -c user.name=vizzini-lab -c user.email=uat@example.invalid "$@"; }
git init -q -b uat-base "$repo"
mkdir -p "$repo/wf"
printf 'module example.com/wf\n\ngo 1.23\n' >"$repo/go.mod"
cat >"$repo/wf/helpers.go" <<'EOF'
package wf

import (
	"crypto/md5" //nolint:gosec // the planted defect's helper
	"encoding/hex"
)

func weakHash(s string) string { h := md5.Sum([]byte(s)); return hex.EncodeToString(h[:]) }
EOF
g add -A
g commit -qm "reconsider base: helpers"
g checkout -qb uat-head
# form.go line 4: G101 matches the identifier, but the value is a field name.
cat >"$repo/wf/form.go" <<'EOF'
package wf

// passwordField is the name attribute of the login form's password input.
const passwordField = "password"

// PasswordValue reads the submitted password from a parsed form.
func PasswordValue(form map[string][]string) string {
	if v := form[passwordField]; len(v) > 0 {
		return v[0]
	}
	return ""
}
EOF
# login.go line 5: MD5 for stored passwords, a real defect.
cat >"$repo/wf/login.go" <<'EOF'
package wf

// HashPassword returns the hash stored for a user's password.
func HashPassword(p string) string {
	return weakHash(p)
}

// CheckPassword reports whether p matches the stored hash.
func CheckPassword(p, stored string) bool {
	return HashPassword(p) == stored
}
EOF
g add -A
g commit -qm "reconsider: login form and password storage"
lint0="$run/lint-0.json"
python3 -I - "$lint0" <<'EOF'
import json, sys
issue = lambda f, l, t: {"FromLinter": "gosec", "Text": t, "Pos": {"Filename": f, "Line": l, "Column": 7}}
json.dump({"Issues": [issue("wf/form.go", 4, "G101: Potential hardcoded credentials"),
                      issue("wf/login.go", 5, "G401: Use of weak cryptographic primitive")]}, open(sys.argv[1], "w"))
EOF

say "the PR"
"$root/uat/ado.sh" check
VIZZINI_REQUESTER="$("$root/uat/ado.sh" whoami)"
"$root/uat/ado.sh" base "$repo" reconsider
pr="$("$root/uat/ado.sh" up "$repo" "rc" reconsider)"
pr_id="${pr##*/}"
echo "$pr" >"$run/pr-url"
head_branch="$(api GET "$api_base/pullrequests/$pr_id?api-version=7.1" | jq_ 'd["sourceRefName"][len("refs/heads/"):]')"
echo "   PR $pr_id ($head_branch)"

# bot NAME URL KEY MODEL [ARGS...]: one vizzini-bot run from the checkout,
# against the model endpoint given.
bot() {
	local d="$run/bot-$1" url=$2 key=$3 mdl=$4
	shift 4
	mkdir -p "$d/mrman-data"
	set +e
	(cd "$repo" && AZURE_DEVOPS_EXT_PAT="$(<"$pat_file")" XDG_DATA_HOME="$d/mrman-data" VIZZINI_REQUESTER="$VIZZINI_REQUESTER" \
		VIZZINI_LITELLM_URL="$url" VIZZINI_API_KEY="$key" VIZZINI_MODEL="$mdl" \
		"$bin/vizzini-bot" --repo . --base uat-base --head uat-head --pr-url "$pr" --mrman "$bin/mrman" --garmr "$bin/garmr" \
		--pr "ado:$repo_key#$pr_id" --lint-json "$lint0" "$@") >"$d/bot.json" 2>"$d/bot.err"
	echo $? >"$d/bot.code"
	set -e
	find "$d/mrman-data" -name '*.audit.jsonl' -exec cat {} + >"$d/audit.jsonl" 2>/dev/null || true
	sed -n 's/^vizzini-bot: /   bot: /p' "$d/bot.err"
}
stub_bot() { bot "$1" "http://$stub_addr/v1" "" stub "${@:2}"; }
live_bot() { bot "$1" "$live_url" "$live_key" "$model" "${@:2}"; }

say "round 0: the review (stubllm)"
stub_bot deny --grant-policy "$committed"
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
stub_bot r0 --grant-policy "$run/policy-bot/mrman"

# --- the developer agent: mrman only -----------------------------------------
agent_data="$run/agent-mrman"
mkdir -p "$agent_data"
agent() { AZURE_DEVOPS_EXT_PAT="$(<"$pat_file")" XDG_DATA_HOME="$agent_data" "$bin/mrman" "$@"; }
# aread ARGS...: a read-only agent call, retried on a network error.
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
	# A network error with no comment id means nothing was posted (ADR-0011).
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

say "round 1: the agent disputes both findings"
view r0
t_form="$(fthread r0 form.go)" t_login="$(fthread r0 login.go)"
echo "   threads: form $t_form, login $t_login"
[[ -n $t_form && -n $t_login ]] || die "the review did not post both threads; see $run/findings-r0.json"
# shellcheck disable=SC2016 # literal Markdown backticks
rec form_cmd_exit "$(areply "$t_form" '/vizzini reconsider `passwordField` is not a credential. It holds the *name* of the login form'\''s password input, the key the browser sends (`password=...`), and `PasswordValue` uses it only to look up the submitted value. No secret is stored anywhere in this file; renaming the constant would only hide it from G101, which matches on the identifier.')"
rec login_cmd_exit "$(areply "$t_login" '/vizzini reconsider MD5 is fine here. Our users choose long passwords and the database is not reachable from the internet.')"

say "round 1: the bot answers ($model)"
live_bot r1 --grant-policy "$run/policy-bot/mrman"
view r1

say "round 2: the bot runs again"
live_bot r2 --grant-policy "$run/policy-bot/mrman"
view r2

say "attribution"
sleep 3 # LiteLLM writes spend logs asynchronously
r1_run="$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1])).get("run_id",""))' "$run/bot-r1/bot.json")"
"$root/litellm/litellm.sh" psql "SELECT count(*), coalesce(sum(prompt_tokens),0), coalesce(sum(completion_tokens),0), coalesce(round(sum(spend)::numeric, 4),0)
	FROM \"LiteLLM_SpendLogs\" WHERE metadata->'spend_logs_metadata'->>'vizzini.run_id' = '$r1_run'
	AND metadata->'spend_logs_metadata'->>'vizzini.mode' = 'command'" 2>/dev/null |
	sed -n 's/^ *\([0-9]*\) *| *\([0-9]*\) *| *\([0-9]*\) *| *\([0-9.]*\) *$/\1 \2 \3 \4/p' >"$run/command-attribution"
echo "   command-mode requests, tokens in/out, spend: $(cat "$run/command-attribution")"

say "checks"
python3 -I - "$run" "$t_form" "$t_login" "$model" <<'EOF' | tee "$run/summary.md"
import json, os, re, sys
run, t_form, t_login, model = sys.argv[1:]
r = dict(l.rstrip("\n").split("\t", 1) for l in open(os.path.join(run, "results.txt")))
def view(n): return {f["thread"]: f for f in json.load(open(os.path.join(run, f"findings-{n}.json")))["findings"]}
def botres(n): return json.load(open(os.path.join(run, f"bot-{n}", "bot.json")))
def code(n): return open(os.path.join(run, f"bot-{n}", "bot.code")).read().strip()
v0, v1, v2 = view("r0"), view("r1"), view("r2")
b0, b1, b2 = botres("r0"), botres("r1"), botres("r2")
ok = True
def check(cond, what):
    global ok
    ok &= bool(cond)
    print(("- [x] " if cond else "- [ ] ") + what)
def answers(v, t): return [x for x in v[t]["replies"] if x["from_vizzini"] and x["reply_to"]]
def verdict(v, t):
    a = answers(v, t)
    if len(a) != 1:
        return None
    w, s = "Withdrawn" in a[0]["body"], "The finding stands" in a[0]["body"]
    return "withdrawn" if w and not s else "stands" if s and not w else None
print(f"# /vizzini reconsider with a live model ({model}), on Azure DevOps\n")
print("## Hard checks\n")
check(code("r0") == "0" and b0.get("posted") == 2 and len(v0) == 2 and v0[t_form]["status"] == v0[t_login]["status"] == "open",
      f"the review posts two open threads ({b0.get('posted')})")
check(r["form_cmd_exit"] == "0" and r["login_cmd_exit"] == "0", "the agent writes both /vizzini reconsider through mrman (reply only)")
check(code("r1") == "0" and len(b1.get("answered") or []) == 2 and not b1.get("command_failures"),
      f"the bot answers both with the live model, through the schema ({len(b1.get('answered') or [])} answered, "
      f"failures {b1.get('command_failures')})")
check(b1.get("posted", 0) == 0, "no new finding is posted")
for name, t in (("form.go", t_form), ("login.go", t_login)):
    vd = verdict(v1, t)
    acted = (vd == "withdrawn" and v1[t]["status"] == "resolved" and t in (b1.get("withdrawn") or [])) or \
            (vd == "stands" and v1[t]["status"] == "open" and t not in (b1.get("withdrawn") or []))
    check(acted, f"{name}: one answer, and its verdict ({vd}) is acted on: thread {v1[t]['status']}")
check(code("r2") == "0" and not b2.get("answered") and all(len(answers(v2, t)) == 1 for t in (t_form, t_login)),
      "a later run answers nothing: each command is answered once")
attr = open(os.path.join(run, "command-attribution")).read().split()
check(attr and int(attr[0]) >= 2, f"the model calls are attributed: command mode, this run ({attr[0] if attr else 'none'} requests)")
print("\n## Model quality (metrics, never a failure)\n")
expected = {"form.go": ("withdrawn", t_form), "login.go": ("stands", t_login)}
hits = 0
for name, (want, t) in expected.items():
    got = verdict(v1, t)
    hits += got == want
    print(f"- {name}: expected {want}, got {got} {'(as expected)' if got == want else '(MISS)'}")
print(f"- verdicts as expected: {hits}/2")
login_ans = " ".join(x["body"] for x in answers(v1, t_login))
print(f"- the stands answer names a password hash (bcrypt, scrypt, Argon2, PBKDF2): "
      f"{'yes' if re.search(r'bcrypt|scrypt|argon2|pbkdf2', login_ans, re.I) else 'no'}")
if attr:
    print(f"- tokens in/out {attr[1]}/{attr[2]}, spend ${attr[3]}")
print("\n## The answers\n")
for name, t in (("form.go", t_form), ("login.go", t_login)):
    for x in answers(v1, t):
        body = re.sub(r"<!--.*?-->", "", x["body"], flags=re.S).strip()
        print(f"### {name}\n\n" + "\n".join("> " + l for l in body.splitlines()) + "\n")
print("result: " + ("PASS" if ok else "FAIL"))
sys.exit(0 if ok else 1)
EOF
