#!/usr/bin/env bash
# bot.sh: the unattended leg (Vizzini ISSUE-024 slices 1-4, ADR-0016).
#
#   uat/bot.sh [--stub] [--fixture NAME] [--model MODEL]
#
# vizzini-bot reviews a seeded fixture's PR on Azure DevOps the way a CI step
# would (from the checkout: git diff uat-base...uat-head) and posts through
# mrman, which submits only when garmr allows it. No person is involved.
# One PR, up to seven legs, each with its own mrman data directory (as each
# CI run has):
#
#   deny   the committed default policy (mrman's policies/garmr/mrman). It
#          allows only the identity "vizzini-bot"; the PAT is yours, so it
#          must deny (MRM-002): bot exit 3, nothing posted on the PR.
#   allow  the same pack with _allowedIdentities set to the identity mrman
#          verified with the forge in the deny leg (read from its audit log,
#          never from configuration). Stands in for a repository that lists
#          its bot account. Bot exit 0, one thread per finding, each carrying
#          the hidden marker <!-- vizzini:fp=… -->.
#   idle   (slice 3) the same head, incrementally: nothing changed since the
#          last reviewed head, so no review is made at all.
#   rerun  (slice 2) the same head again with --full: the bot reviews
#          everything, reads its threads back and duplicates none of them,
#          and resolves nothing (no code changed).
#   fix    (slices 2-3, fixtures with a fix/ overlay) a commit fixing one
#          defect is pushed to the PR and the bot runs incrementally on the
#          new head: only the changed file is reviewed; the threads it raised
#          on the changed lines whose finding is gone are resolved, with a
#          reply; threads on other files are carried untouched.
#   command  (slice 4) as the PAT's user, the harness writes
#          "/vizzini explain …" and a malformed "/vizzini …" in one of the
#          bot's threads; the bot (head unchanged: no review) answers both in
#          the thread, the second with usage.
#   command-again  the same: both are answered already, nothing is posted.
#
# The generated allow policy holds your forge display name; it stays in the
# run directory under .cache (never committed), and logs show only its first
# three characters.
#
#   --stub      Vizzini's stubllm instead of LiteLLM (no tokens)
#   --fixture   a seeded fixture (default csharp-seeded)
#   --model     a model from litellm/config.yaml (default claude-sonnet-5-5)
#
# Writes .cache/runs/<UTC>-bot/; exits non-zero when a check fails.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
bin="$root/.cache/bin"
src="$root/.cache/src"
committed="$src/mrman/policies/garmr/mrman"

stub=0 fixture=csharp-seeded model=claude-sonnet-5-5
while [[ $# -gt 0 ]]; do
	case $1 in
	--stub) stub=1 ;;
	--fixture) fixture=$2; shift ;;
	--model) model=$2; shift ;;
	*) sed -n '2,28p' "$0" >&2; exit 2 ;;
	esac
	shift
done

say() { printf '\n== %s\n' "$*"; }
die() { printf 'bot: %s\n' "$*" >&2; exit 1; }

for b in vizzini-bot mrman garmr; do [[ -x $bin/$b ]] || die "$bin/$b missing; run uat/build.sh"; done
[[ -f $committed/agent-submit.cue ]] || die "the pinned mrman has no $committed (needs --grant-policy)"

export TIKTOKEN_CACHE_DIR="$root/.cache/tiktoken"
"$src/vizzini/scripts/tiktoken-cache.sh" "$TIKTOKEN_CACHE_DIR" >/dev/null

run="$root/.cache/runs/$(date -u +%Y%m%dT%H%M%SZ)-bot"
mkdir -p "$run"
cp "$bin/build-manifest.json" "$run/"
echo "run: $run"

stub_pid=""
cleanup() { [[ -n $stub_pid ]] && kill "$stub_pid" 2>/dev/null || true; }
trap cleanup EXIT

say "model endpoint"
if ((stub)); then
	addr="127.0.0.1:${STUB_PORT:-18773}"
	(cd "$src/vizzini" && go build -o "$bin/stubllm" ./scripts/e2e/stubllm)
	"$bin/stubllm" -addr "$addr" -log "$run/stub-prompts.log" 2>"$run/stubllm.err" &
	stub_pid=$!
	for _ in $(seq 50); do curl -s -o /dev/null "http://$addr/" && break; sleep 0.1; done
	export VIZZINI_LITELLM_URL="http://$addr/v1"
	unset VIZZINI_API_KEY
	model=stub
else
	"$root/litellm/litellm.sh" status >/dev/null || die "LiteLLM is not running: litellm/litellm.sh up"
	eval "$("$root/litellm/litellm.sh" env)"
fi
export VIZZINI_MODEL=$model
echo "   $VIZZINI_LITELLM_URL, model $model"

say "Azure DevOps"
"$root/uat/ado.sh" check
VIZZINI_REQUESTER="$("$root/uat/ado.sh" whoami)"
export VIZZINI_REQUESTER
echo "   requester: ${VIZZINI_REQUESTER:0:3}… (redacted)"

say "fixture $fixture"
"$root/uat/fixture.sh" "$fixture" "$run/repo"
"$root/uat/ado.sh" base "$run/repo" "$fixture"
pr="$("$root/uat/ado.sh" up "$run/repo" "bot-$model" "$fixture")"
echo "$pr" >"$run/pr-url"
rest="${pr#https://}"
VIZZINI_PR="ado:${rest%%/_git/*}/$(basename "${rest%%/pullrequest/*}")#${pr##*/}"
export VIZZINI_PR
echo "   PR: $pr ($VIZZINI_PR)"

# The PAT, as mrman reads it, for the bot's mrman calls only.
pat_file="${ADO_PAT_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/vizzini-uat/ado.pat}"

# The linter report the bot explains, built at the head under review.
lint=(--lint-json "$run/repo.sarif")

# leg NAME POLICY_DIR [BOT_ARGS...]: one vizzini-bot run, as a CI step
# would make it.
leg() {
	local name=$1 policy=$2 d="$run/$1" t0 code
	shift 2
	mkdir -p "$d/mrman-data"
	say "leg $name: vizzini-bot --grant-policy $(basename "$(dirname "$policy")")/$(basename "$policy")"
	t0=$(date +%s)
	set +e
	(
		cd "$run/repo"
		AZURE_DEVOPS_EXT_PAT="$(<"$pat_file")" XDG_DATA_HOME="$d/mrman-data" \
			"$bin/vizzini-bot" --repo . --base uat-base --head uat-head --pr-url "$pr" \
			--grant-policy "$policy" --mrman "$bin/mrman" --garmr "$bin/garmr" \
			--knowledge .okfw "${lint[@]}" --out "$d/review.json" "$@"
	) >"$d/bot.json" 2>"$d/bot.err"
	code=$?
	set -e
	echo "$code" >"$d/bot.code"
	echo "   exit $code in $(($(date +%s) - t0))s"
	sed -n 's/^vizzini-bot: /   bot: /p' "$d/bot.err"
	# The audit log mrman wrote beside the session.
	find "$d/mrman-data" -name '*.audit.jsonl' -exec cat {} + >"$d/audit.jsonl" 2>/dev/null || true
	sleep 2
	"$root/uat/ado.sh" threads "$pr" >"$d/threads.json"
}

leg deny "$committed"

# The identity mrman verified with the forge, from the deny decision.
identity="$(python3 -I -c '
import json, sys
recs = [json.loads(l) for l in open(sys.argv[1]) if l.strip()]
print(recs[-1]["input"]["identity"] if recs else "")' "$run/deny/audit.jsonl")"
[[ -n $identity ]] || die "the deny leg left no authorization record; see $run/deny/bot.err"
echo "   forge-verified identity: ${identity:0:3}… (redacted)"

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
"$bin/garmr" validate "$allow" >"$run/policy-allow.validate.log" 2>&1 || { cat "$run/policy-allow.validate.log"; die "garmr validate (allow policy)"; }

leg allow "$allow"

if [[ -d $root/fixtures/$fixture/fix ]]; then
	leg idle "$allow"
	leg rerun "$allow" --full

	say "push a fix to the PR"
	cp -a "$root/fixtures/$fixture/fix/." "$run/repo/"
	git -C "$run/repo" -c user.name=vizzini-uat -c user.email=uat@example.invalid commit -qam "$fixture: fix"
	git -C "$run/repo" diff --stat HEAD~1 | sed 's/^/   /'
	"$root/uat/ado.sh" push "$run/repo" "$pr"
	# The linter report must describe the new head, or its diagnostics would
	# point at lines that no longer hold what they describe.
	LINT=""
	# shellcheck source=/dev/null
	source "$root/fixtures/$fixture/fixture.env"
	if [[ $LINT == roslyn ]]; then
		"${CONTAINER:-podman}" run --rm -v "$run/repo:$run/repo:Z" -w "$run/repo" "$DOTNET_IMAGE" dotnet build -nologo \
			>"$run/fix.build.log" 2>&1 || { tail -20 "$run/fix.build.log"; die "dotnet build (fix) failed"; }
		mv "$run/repo/roslyn.sarif" "$run/repo.fix.sarif"
		lint=(--lint-json "$run/repo.fix.sarif")
	else
		lint=()
	fi
	leg fix "$allow"
fi

# Commands people write in the PR (slice 4): one real, one malformed, in
# the bot's thread on the SQL injection (or its first open thread).
for last in "$run"/fix "$run"/rerun "$run"/allow; do [[ -d $last ]] && break; done
thread="$(python3 -I - "$last/threads.json" <<'EOF'
import json, sys
ts = [t for t in json.load(open(sys.argv[1]))["value"]
      if t.get("status") == "active" and t.get("threadContext")
      and any("<!-- vizzini:fp=" in (c.get("content") or "") for c in t.get("comments", []))]
sql = [t for t in ts if "SQL" in t["comments"][0].get("content", "")]
print((sql or ts)[0]["id"] if ts else "")
EOF
)"
[[ -n $thread ]] || die "no open bot thread to write a command in"
say "commands in thread $thread"
ask="$("$root/uat/ado.sh" comment "$pr" "$thread" "/vizzini explain Why is this dangerous, and what would an attacker send?")"
bad="$("$root/uat/ado.sh" comment "$pr" "$thread" "/vizzini dance")"
printf '%s\n%s\n' "$ask" "$bad" >"$run/command-ids"
echo "   comments $ask (explain) and $bad (malformed)"
leg command "$allow"
leg command-again "$allow"

# The command's model calls must be attributed like the review's (ADR-0015):
# every command-mode request since the command leg started names its run
# and this pull request.
if ((!stub)); then
	sleep 3 # LiteLLM writes spend logs asynchronously
	cmd_run="$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["run_id"])' "$run/command/bot.json")"
	"$root/litellm/litellm.sh" psql "SELECT count(*) FILTER (WHERE metadata->'spend_logs_metadata'->>'vizzini.run_id' = '$cmd_run'
		AND metadata->'spend_logs_metadata'->>'vizzini.pr_key' = '$VIZZINI_PR'), count(*)
		FROM \"LiteLLM_SpendLogs\" WHERE metadata->'spend_logs_metadata'->>'vizzini.mode' = 'command'
		AND \"startTime\" >= (SELECT min(\"startTime\") FROM \"LiteLLM_SpendLogs\"
		WHERE metadata->'spend_logs_metadata'->>'vizzini.run_id' = '$cmd_run')" 2>/dev/null |
		sed -n 's/^ *\([0-9]*\) *| *\([0-9]*\) *$/\1 \2/p' >"$run/command-attribution"
fi

say "checks"
python3 -I - "$run" <<'EOF' | tee "$run/summary.md"
import json, os, re, sys
run = sys.argv[1]
ok = True
def check(cond, what):
    global ok
    ok &= bool(cond)
    print(("- [x] " if cond else "- [ ] ") + what)

MARK = re.compile(r"<!-- vizzini:fp=(\S+) run=(\S+)(?: head=\S+)?(?: lines=(\d+)-(\d+))?(?: cat=(\S+))? -->")

def marked_threads(threads):
    """The bot's threads: id, path, status, run, lines, category, body, replies."""
    out = []
    for t in threads:
        cs = [c for c in t.get("comments", []) if c.get("commentType") != "system"]
        if not cs:
            continue
        m = MARK.search(cs[0].get("content") or "")
        if not m:
            continue
        out.append({"id": str(t["id"]), "path": ((t.get("threadContext") or {}).get("filePath") or "").lstrip("/"),
                    "status": t.get("status", "active"), "run": m.group(2),
                    "start": int(m.group(3) or 0), "end": int(m.group(4) or 0), "cat": m.group(5),
                    "body": cs[0].get("content") or "", "replies": [c.get("content") or "" for c in cs[1:]]})
    return out

def leg(name):
    d = os.path.join(run, name)
    if not os.path.isdir(d):
        return None
    code = int(open(os.path.join(d, "bot.code")).read())
    audit = [json.loads(l) for l in open(os.path.join(d, "audit.jsonl")) if l.strip()]
    threads = marked_threads(json.load(open(os.path.join(d, "threads.json")))["value"])
    try:
        findings = json.load(open(os.path.join(d, "review.json")))["findings"]
    except (OSError, ValueError, KeyError):
        findings = None
    try:
        result = json.loads(open(os.path.join(d, "bot.json")).read())
    except ValueError:
        result = {}
    return code, audit, threads, findings, result

def duplicates(new, old):
    """New threads raising what an older open thread on unchanged code raises."""
    return [n for n in new for o in old
            if o["status"] == "active" and n["id"] != o["id"] and n["path"] == o["path"] and n["cat"] == o["cat"]
            and n["start"] <= o["end"] and n["end"] >= o["start"]]

print("# vizzini-bot UAT (ISSUE-024 slices 1-4)\n")
code, audit, marked, findings, _ = leg("deny")
print("## deny: committed default policy\n")
check(code == 3, f"bot exit 3 (policy denied), got {code}")
check(len(audit) == 1 and audit[0]["decision"] == "deny" and not audit[0]["allowed"], "one audited deny decision")
check(audit and audit[0].get("failed") == ["MRM-002"], f"denied by MRM-002 only (identity), failed {audit[0].get('failed') if audit else None}")
check(audit and audit[0]["input"]["agent"] == "vizzini-bot" and audit[0]["input"]["run_id"], "the decision names the agent and run")
check(not marked, f"nothing posted on the PR ({len(marked)} marked threads)")

code, audit, marked, findings, result = leg("allow")
print("\n## allow: the pack listing the forge-verified identity\n")
check(code == 0, f"bot exit 0, got {code}")
# A submit retried after a network error is authorized (and audited) again.
check(audit and all(a["decision"] == "allow" and a["allowed"] for a in audit), f"audited allow decision(s) ({len(audit)})")
check(findings is not None and len(findings) > 0, f"the review found something ({len(findings or [])} findings)")
check(findings is not None and len(marked) == len(findings), f"one marked thread per finding ({len(marked)} threads, {len(findings or [])} findings)")
files = {f["file"].lstrip("/") for f in findings or []}
check(all(t["path"] in files for t in marked), "every thread is on a reviewed file")
if audit:
    print(f"\npolicy digest {audit[-1]['policy_digest'][:12]}…, {audit[-1]['input']['comments']} comments, run {audit[-1]['input']['run_id']}")
allow_threads = marked
rerun_threads = marked

r = leg("idle")
if r:
    code, audit, marked, findings, result = r
    print("\n## idle: same head, incremental\n")
    check(code == 0, f"bot exit 0, got {code}")
    check(result.get("mode") == "unchanged", f"nothing changed since the last reviewed head: no review (mode {result.get('mode')})")
    check(findings is None, "no review report was written")
    check(not audit, "nothing was submitted or resolved")

r = leg("rerun")
if r:
    code, audit, marked, findings, result = r
    print("\n## rerun: same head with --full, the bot reads its threads back\n")
    check(code == 0, f"bot exit 0, got {code}")
    new = [t for t in marked if t["run"] == result.get("run_id")]
    dup = duplicates(new, allow_threads)
    check(not dup, f"no duplicated thread ({len(dup)} duplicates)")
    check(len(result.get("already_posted", [])) > 0,
          f"findings recognized as already posted: {len(result.get('already_posted', []))} of {result.get('findings')}")
    check(not result.get("resolved"), f"nothing resolved without a code change ({result.get('resolved')})")
    print(f"\nmetrics: {len(new)} new thread(s) from model variance, "
          f"{len(result.get('kept_open', []))} kept open (unreported this run, code unchanged)")
    rerun_threads = marked

r = leg("fix")
if r:
    code, audit, marked, findings, result = r
    print("\n## fix: a commit fixes the MD5 reset token\n")
    fixed = "src/Services/PasswordHasher.cs"
    check(code == 0, f"bot exit 0, got {code}")
    check(result.get("mode") == "incremental" and result.get("reviewed_files") == [fixed],
          f"only the changed file was reviewed (mode {result.get('mode')}, files {result.get('reviewed_files')})")
    open_elsewhere = {t["id"] for t in rerun_threads if t["path"] != fixed and t["status"] == "active"}
    check(open_elsewhere and set(result.get("carried", [])) == open_elsewhere,
          f"every open thread on another file was carried ({len(result.get('carried', []))} of {len(open_elsewhere)})")
    resolved = [t for t in marked if t["status"] != "active" and any("Resolved by vizzini-bot" in x for x in t["replies"])]
    check(resolved, f"the bot resolved threads ({len(resolved)}: {sorted(t['id'] for t in resolved)})")
    check(sorted(t["id"] for t in resolved) == sorted(result.get("resolved", [])),
          "the forge shows exactly the threads the bot reported resolved")
    check(all(t["path"] == fixed for t in resolved), f"only threads on {fixed} were resolved")
    check(all(t["status"] == "fixed" for t in resolved), "resolved threads have status fixed (Resolved)")
    md5 = [t for t in rerun_threads if t["path"] == fixed and "MD5" in t["body"] and t["status"] == "active"]
    still = [t for t in marked if t["id"] in {m["id"] for m in md5} and t["status"] == "active"]
    check(md5 and not still, f"the MD5 thread(s) are resolved ({len(md5)} before, {len(still)} still open)")
    new = [t for t in marked if t["run"] == result.get("run_id")]
    dup = duplicates([t for t in new if t["path"] != fixed], [t for t in rerun_threads if t["path"] != fixed])
    check(not dup, f"no thread duplicated on unchanged files ({len(dup)} duplicates)")
    print(f"\nmetrics: {len(new)} new thread(s), {len(result.get('already_posted', []))} already posted, "
          f"{len(result.get('kept_open', []))} kept open")

r = leg("command")
if r:
    code, audit, marked, findings, result = r
    ask, bad = open(os.path.join(run, "command-ids")).read().split()
    print("\n## command: /vizzini in a PR thread\n")
    check(code == 0, f"bot exit 0, got {code}")
    check(result.get("mode") == "unchanged", f"no review was needed (mode {result.get('mode')})")
    check(sorted(result.get("answered", [])) == sorted([ask, bad]), f"both commands answered ({result.get('answered')})")
    raw = json.load(open(os.path.join(run, "command", "threads.json")))["value"]
    replies = {}
    for t in raw:
        for c in t.get("comments", []):
            m = re.search(r"<!-- vizzini:reply-to=(\S+) run=", c.get("content") or "")
            if m:
                replies.setdefault(m.group(1), []).append((t["id"], c.get("parentCommentId"), c.get("content") or ""))
    a = replies.get(ask, [])
    check(len(a) == 1 and "I could not run that" not in a[0][2] and len(a[0][2]) > 200,
          f"the explain command got one real answer ({len(a)} replies, {len(a[0][2]) if a else 0} chars)")
    check(a and a[0][1] == int(ask), "the answer is a reply to the command comment")
    b = replies.get(bad, [])
    check(len(b) == 1 and "I could not run that" in b[0][2], "the malformed command got one usage reply")
    check(audit and all(x["input"]["event"] == "reply" and x["allowed"] for x in audit), f"each reply was authorized as event reply ({len(audit)})")
    if a:
        print("\n> " + a[0][2].split("<!--")[0].strip().replace("\n", "\n> ")[:1200])

attr = os.path.join(run, "command-attribution")
if os.path.exists(attr):
    parts = open(attr).read().split()
    named, total = (int(parts[0]), int(parts[1])) if len(parts) == 2 else (0, 0)
    check(total > 0 and named == total, f"every command request is attributed to its run and PR ({named} of {total})")

r = leg("command-again")
if r:
    code, audit, marked, findings, result = r
    print("\n## command-again: nothing is answered twice\n")
    check(code == 0 and not result.get("answered"), f"no command answered again ({result.get('answered')})")
    check(not audit, "nothing was posted")

print("\nresult: " + ("PASS" if ok else "FAIL"))
sys.exit(0 if ok else 1)
EOF
