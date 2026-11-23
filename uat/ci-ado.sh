#!/usr/bin/env bash
# ci-ado.sh: run Vizzini's Azure Pipelines template for real.
#
#   uat/ci-ado.sh
#
# The ADO organization has no hosted parallelism for private projects, so the
# job runs on a throwaway self-hosted agent: a podman container
# (ci/ado-agent, the agent package checked against its published SHA-256),
# registered in the Default pool for the run and removed after it. The test
# changes the template (deploy/ci/azure-pipelines/vizzini-bot.yml, from the
# pinned Vizzini commit) in two ways only: the pool is Default, and the
# Review step starts Vizzini's stubllm (-finding-per-file) as the model.
#
#   1. base branch ci/base-<stamp>: a Go file, the template's grant policy
#      (no identity) and the test pipeline; a pipeline created from it; a
#      build-validation policy on the base branch; and the template's setup
#      step: "<Project> Build Service (<org>)" granted Contribute to pull
#      requests on this repository only (removed or restored at the end)
#   2. PR from ci/pr-<stamp>
#      -> the build must fail with exit 3, nothing posted; its log names the
#         identity System.AccessToken posts as
#   3. that identity committed to the base's policy; a new commit on the PR
#      -> the build posts the stub's findings as threads with markers
#   4. a "/vizzini explain" comment in a bot thread and another commit
#      -> an incremental review of the changed file; the command answered in
#         its thread (ADO supports replies)
#   5. PR abandoned; policy, pipeline, branches, permission and agent
#      removed
#
# Uses the ADO settings of uat/ado.sh. The PAT goes to git through a
# credential helper, to curl through a config on stdin, and to the agent as
# VSTS_AGENT_INPUT_TOKEN in its environment, never on a command line. Writes
# .cache/runs/<UTC>-ci-ado/; exits non-zero when a check fails.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
vz="$root/.cache/src/vizzini"
template="$vz/deploy/ci/azure-pipelines/vizzini-bot.yml"
image="localhost/vizzini-lab-ado-agent:5.281.1"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/vizzini-lab"

say() { printf '\n== %s\n' "$*"; }
die() { printf 'ci-ado: %s\n' "$*" >&2; exit 1; }
[[ -f $template ]] || die "no $template: pin a Vizzini commit with deploy/ci (uat/build.sh vizzini)"

ADO_REPO_URL="${ADO_REPO_URL:-$(sed -n 's/^ADO_REPO_URL=//p' "$cfg/ado.env" | tail -1)}"
# shellcheck source=uat/ado-url.sh
source "$root/uat/ado-url.sh"
ado_parse_url "$ADO_REPO_URL" || die "set ADO_REPO_URL ($ado_url_shapes)"
# Identities: a separate host on Azure DevOps Services, the collection on
# Azure DevOps Server. The build service is named after the organization or
# the collection (the last segment of the collection path).
identities="$ADO_COLLECTION_URL/_apis/identities"
((ADO_SERVER)) || identities="https://vssps.dev.azure.com/$ORG/_apis/identities"
build_service="$PROJECT Build Service (${ORG##*/})"
VSTS_AGENT_INPUT_TOKEN="$(<"${ADO_PAT_FILE:-$cfg/ado.pat}")"
export VSTS_AGENT_INPUT_TOKEN
api_base="$ADO_COLLECTION_URL/$PROJECT/_apis"

# api METHOD URL [JSON]: the body; fails on a non-2xx status. A failure to
# connect (dev.azure.com resets the odd TLS handshake) is retried: the request
# never reached the server, so repeating it is safe.
api() {
	local out code="" try
	out="$(mktemp)"
	local rc
	for try in 1 2 3; do
		rc=0
		code="$(printf 'header = "Authorization: Basic %s"\n' "$(printf ':%s' "$VSTS_AGENT_INPUT_TOKEN" | base64 -w0)" |
			curl -sS -K - -o "$out" -w '%{http_code}' -X "$1" -H 'Content-Type: application/json' ${3:+--data "$3"} "$2")" || rc=$?
		# Retry only failures before the request was sent: DNS (6), connect
		# (7), TLS handshake (35).
		[[ $rc == 6 || $rc == 7 || $rc == 35 ]] || break
		code=""
		sleep $((try * 5))
	done
	if [[ $code != 2* ]]; then
		echo "ci-ado: $1 $2 -> HTTP $code: $(head -c 400 "$out")" >&2
		rm -f "$out"
		return 1
	fi
	cat "$out"
	rm -f "$out"
}
jq_() { python3 -I -c "import json,sys; d=json.load(sys.stdin); print($1)"; }
urlq() { python3 -I -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"; }

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
run="$root/.cache/runs/$stamp-ci-ado"
base="ci/base-$stamp" head="ci/pr-$stamp" agent="vizzini-lab-$stamp"
mkdir -p "$run"
echo "run: $run"

pipeline_id="" policy_id="" pr_id="" ace_token="" ace_desc="" ace_before=""
git_ns=2e9eb7ed-3c0a-47d4-87c1-0ffdd275fd87 # the Git Repositories security namespace
cleanup() {
	say "cleanup"
	# A build still running holds the agent: ADO refuses to deregister an
	# agent with a job. Cancel what is left first.
	if [[ -n $pipeline_id ]]; then
		local b
		for b in $(api GET "$api_base/build/builds?definitions=$pipeline_id&statusFilter=inProgress,notStarted&api-version=7.1" |
			jq_ '" ".join(str(x["id"]) for x in d["value"])' 2>/dev/null); do
			api PATCH "$api_base/build/builds/$b?api-version=7.1" '{"status":"cancelling"}' >/dev/null && echo "   build $b cancelled"
		done
	fi
	if [[ -n $ace_token ]]; then
		if [[ -n $ace_before ]]; then
			api POST "$ADO_COLLECTION_URL/_apis/AccessControlEntries/$git_ns?api-version=7.1" "$ace_before" >/dev/null &&
				echo "   build service permission restored"
		else
			api DELETE "$ADO_COLLECTION_URL/_apis/AccessControlEntries/$git_ns?token=$(urlq "$ace_token")&descriptors=$(urlq "$ace_desc")&api-version=7.1" \
				>/dev/null && echo "   build service permission removed"
		fi
	fi
	[[ -n $pr_id ]] && api PATCH "$api_base/git/repositories/$REPO/pullrequests/$pr_id?api-version=7.1" '{"status":"abandoned"}' >/dev/null && echo "   PR $pr_id abandoned"
	[[ -n $policy_id ]] && api DELETE "$api_base/policy/configurations/$policy_id?api-version=7.1" >/dev/null && echo "   policy $policy_id deleted"
	[[ -n $pipeline_id ]] && api DELETE "$api_base/build/definitions/$pipeline_id?api-version=7.1" >/dev/null && echo "   pipeline $pipeline_id deleted"
	for b in "$base" "$head"; do
		g push -q origin --delete "$b" 2>/dev/null && echo "   branch $b deleted" || true
	done
	if podman container exists "$agent" 2>/dev/null; then
		podman stop -t 60 "$agent" >/dev/null && echo "   agent container $agent stopped"
		podman logs "$agent" >"$run/agent.log" 2>&1 || true
		podman rm "$agent" >/dev/null
		agent_gone
	fi
}

# agent_gone: make sure the agent's registration left the Default pool. The
# container deregisters itself when stopped, but not while ADO still holds a
# job for it (the lease of a cancelled job can outlive the container by
# minutes), so delete it through the API, retrying, and say if it stays.
agent_gone() {
	local pool id try
	pool="$(api GET "$ADO_COLLECTION_URL/_apis/distributedtask/pools?poolName=Default&api-version=7.1" | jq_ 'd["value"][0]["id"]')" || return 0
	for try in $(seq 30); do
		id="$(api GET "$ADO_COLLECTION_URL/_apis/distributedtask/pools/$pool/agents?agentName=$(urlq "$agent")&api-version=7.1" |
			jq_ 'd["value"][0]["id"] if d["value"] else ""')" || id="?"
		if [[ -z $id ]]; then
			echo "   agent $agent deregistered"
			return 0
		fi
		[[ $id != "?" ]] && api DELETE "$ADO_COLLECTION_URL/_apis/distributedtask/pools/$pool/agents/$id?api-version=7.1" >/dev/null 2>&1 && continue
		sleep 30
	done
	echo "   AGENT $agent IS STILL REGISTERED in the Default pool: remove it in Organization settings > Agent pools" >&2
}
trap cleanup EXIT

# The test pipeline: the template, with the Default pool and stubllm.
python3 -I - "$template" "$run/vizzini-bot.yml" <<'EOF'
import sys, yaml
p = yaml.safe_load(open(sys.argv[1]))
p["pool"] = {"name": "Default"}
review = next(s for s in p["steps"] if s.get("displayName") == "Review")
# From Vizzini v0.1.3 on, the template sets up no Go; stubllm needs it.
p["steps"].insert(p["steps"].index(review), {"task": "GoTool@0", "inputs": {"version": "1.25.4"},
                                             "displayName": "Set up Go for stubllm (vizzini-lab test only)"})
review["bash"] = ("# vizzini-lab test only: stubllm, built from the pinned Vizzini clone, is the model.\n"
                  "(cd \"$AGENT_TEMPDIRECTORY/vizzini-src\" && go build -o \"$AGENT_TEMPDIRECTORY/stubllm\" ./scripts/e2e/stubllm)\n"
                  "\"$AGENT_TEMPDIRECTORY/stubllm\" -addr 127.0.0.1:18765 -finding-per-file >\"$AGENT_TEMPDIRECTORY/stubllm.log\" 2>&1 &\n"
                  "for _ in $(seq 50); do curl -s -o /dev/null http://127.0.0.1:18765/ && break; sleep 0.2; done\n"
                  + review["bash"])
review["env"].update({"VIZZINI_LITELLM_URL": "http://127.0.0.1:18765/v1", "VIZZINI_MODEL": "stub", "VIZZINI_API_KEY": ""})
open(sys.argv[2], "w").write("# Generated by vizzini-lab uat/ci-ado.sh from Vizzini's deploy/ci/azure-pipelines/vizzini-bot.yml;\n"
                             "# the only changes: the Default pool, and stubllm as the model.\n" + yaml.safe_dump(p, sort_keys=False))
EOF

say "branches $base and $head"
repo="$run/repo"
git init -q -b "$base" "$repo"
# shellcheck disable=SC2016 # the PAT is expanded by git's helper, at run time
g() {
	git -C "$repo" -c credential.helper= \
		-c 'credential.helper=!f() { echo username=pat; echo "password=$VSTS_AGENT_INPUT_TOKEN"; }; f' \
		-c user.name=vizzini-lab -c user.email=uat@example.invalid "$@"
}
mkdir -p "$repo/calc" "$repo/.vizzini/grant-policy" "$repo/.azure-pipelines"
printf 'package calc\n\n// Add returns a + b.\nfunc Add(a, b int) int { return a + b }\n' >"$repo/calc/calc.go"
cp "$vz/deploy/ci/grant-policy/agent-submit.cue" "$repo/.vizzini/grant-policy/"
cp "$run/vizzini-bot.yml" "$repo/.azure-pipelines/vizzini-bot.yml"
g add -A
g commit -qm "ci test base: calc, the grant policy (no identity), the test pipeline"
g checkout -qb "$head"
printf '\n// Div returns a / b.\nfunc Div(a, b int) int { return a / b }\n' >>"$repo/calc/calc.go"
g commit -qam "ci test: Div"
g remote add origin "$ADO_REPO_URL"
g push -q origin "$base" "$head"

say "pipeline, policy, agent"
repo_id="$(api GET "$api_base/git/repositories/$REPO?api-version=7.1" | jq_ 'd["id"]')"
pipeline_id="$(api POST "$api_base/pipelines?api-version=7.1" "$(python3 -I -c '
import json,sys
print(json.dumps({"name": "vizzini-bot-test-"+sys.argv[1], "folder": "\\vizzini-lab",
  "configuration": {"type": "yaml", "path": "/.azure-pipelines/vizzini-bot.yml",
                    "repository": {"id": sys.argv[2], "type": "azureReposGit"}}}))' "$stamp" "$repo_id")" | jq_ 'd["id"]')"
echo "   pipeline $pipeline_id"
queue_id="$(api GET "$api_base/distributedtask/queues?queueName=Default&api-version=7.1-preview.1" | jq_ 'd["value"][0]["id"]')"
api PATCH "$api_base/pipelines/pipelinePermissions/queue/$queue_id?api-version=7.1-preview.1" \
	"{\"pipelines\":[{\"id\":$pipeline_id,\"authorized\":true}]}" >/dev/null
policy_id="$(api POST "$api_base/policy/configurations?api-version=7.1" "$(python3 -I -c '
import json,sys
print(json.dumps({"isEnabled": True, "isBlocking": False, "type": {"id": "0609b952-1397-4640-95ec-e00a01b2c241"},
  "settings": {"buildDefinitionId": int(sys.argv[1]), "queueOnSourceUpdateOnly": True, "manualQueueOnly": False,
               "displayName": "vizzini-bot (vizzini-lab test)", "validDuration": 0,
               "scope": [{"repositoryId": sys.argv[2], "refName": "refs/heads/"+sys.argv[3], "matchKind": "Exact"}]}}))' \
	"$pipeline_id" "$repo_id" "$base")" | jq_ 'd["id"]')"
echo "   build validation policy $policy_id on $base"
# The template's documented setup: the build service may contribute to pull
# requests in this repository (PullRequestContribute, 16384).
project_id="$(api GET "$ADO_COLLECTION_URL/_apis/projects/$PROJECT?api-version=7.1" | jq_ 'd["id"]')"
ace_desc="$(api GET "$identities?searchFilter=General&filterValue=$(urlq "$build_service")&api-version=7.1" |
	jq_ 'd["value"][0]["descriptor"]')"
ace_before="$(api GET "$ADO_COLLECTION_URL/_apis/accesscontrollists/$git_ns?token=repoV2/$project_id/$repo_id&api-version=7.1" |
	python3 -I -c '
import json, sys
token, desc = sys.argv[1:]
for acl in json.load(sys.stdin)["value"]:
    ace = acl.get("acesDictionary", {}).get(desc)
    if ace:
        print(json.dumps({"token": token, "merge": False, "accessControlEntries": [ace]}))' "repoV2/$project_id/$repo_id" "$ace_desc")"
ace_token="repoV2/$project_id/$repo_id"
api POST "$ADO_COLLECTION_URL/_apis/AccessControlEntries/$git_ns?api-version=7.1" "$(python3 -I -c '
import json, sys
print(json.dumps({"token": sys.argv[1], "merge": True,
  "accessControlEntries": [{"descriptor": sys.argv[2], "allow": 16384, "deny": 0}]}))' "$ace_token" "$ace_desc")" >/dev/null
echo "   $build_service: Contribute to pull requests on $REPO"
podman image exists "$image" || {
	echo "   building $image (ci/ado-agent)"
	podman build -q -t "$image" "$root/ci/ado-agent" >/dev/null
}
podman run -d --name "$agent" -e AZP_URL="$ADO_COLLECTION_URL" -e AZP_POOL=Default -e AZP_AGENT="$agent" \
	-e VSTS_AGENT_INPUT_TOKEN "$image" >/dev/null
for _ in $(seq 60); do podman logs "$agent" 2>&1 | grep -q 'Listening for Jobs' && break; sleep 3; done
podman logs "$agent" 2>&1 | grep -q 'Listening for Jobs' || { podman logs "$agent" 2>&1 | tail -20; die "the agent did not come up"; }
echo "   agent $agent listening"

# wait_build N NAME: wait for the PR's Nth build (by its refs/pull/<id>/merge
# source branch) to complete; save its log and result as $run/NAME.{log,result}.
wait_build() {
	local n=$1 name=$2 id="" status="" waited=0
	while ((waited < 1500)); do
		api GET "$api_base/build/builds?definitions=$pipeline_id&branchName=refs/pull/$pr_id/merge&queryOrder=queueTimeAscending&api-version=7.1" \
			>"$run/builds.json" || true
		read -r id status < <(python3 -I -c '
import json, sys
bs = json.load(open(sys.argv[1]))["value"]
n = int(sys.argv[2])
print(bs[n-1]["id"], bs[n-1]["status"]) if len(bs) >= n else print("", "")' "$run/builds.json" "$n") || true
		[[ -n $id && $status == completed ]] && break
		sleep 15
		waited=$((waited + 15))
	done
	[[ -n $id && $status == completed ]] || die "build $n of PR $pr_id did not complete in 1500s (see builds.json)"
	api GET "$api_base/build/builds/$id?api-version=7.1" | jq_ 'd["result"]' >"$run/$name.result"
	: >"$run/$name.log"
	for l in $(api GET "$api_base/build/builds/$id/logs?api-version=7.1" | jq_ '" ".join(str(x["id"]) for x in d["value"])'); do
		api GET "$api_base/build/builds/$id/logs/$l?api-version=7.1" >>"$run/$name.log" || true
	done
	echo "   build $id: $(<"$run/$name.result")"
}

say "PR: the policy lists no identity"
pr_id="$(api POST "$api_base/git/repositories/$REPO/pullrequests?api-version=7.1" "$(python3 -I -c '
import json,sys
print(json.dumps({"sourceRefName": "refs/heads/"+sys.argv[1], "targetRefName": "refs/heads/"+sys.argv[2],
  "title": "vizzini-lab CI template test "+sys.argv[3], "description": "Throwaway PR: runs Vizzini'"'"'s Azure Pipelines template (uat/ci-ado.sh)."}))' \
	"$head" "$base" "$stamp")" | jq_ 'd["pullRequestId"]')"
echo "$ADO_REPO_URL/pullrequest/$pr_id" >"$run/pr-url"
echo "   PR $pr_id"
wait_build 1 build1
identity="$(python3 -I - "$run/build1.log" <<'EOF'
import json, re, sys
for line in open(sys.argv[1], errors="replace"):
    m = re.search(r"mrman: authorization: (\{.*\})\s*$", line)
    if m:
        print(json.loads(m.group(1))["input"]["identity"])
        break
EOF
)"
[[ -n $identity ]] || die "build 1 printed no authorization; see $run/build1.log"
echo "   System.AccessToken posts as: $identity"

say "allow the identity on the base branch; a new commit on the PR"
g checkout -q "$base"
python3 -I - "$repo/.vizzini/grant-policy/agent-submit.cue" "$identity" <<'EOF'
import json, sys
p, ident = sys.argv[1:]
s = open(p).read()
assert s.count("_allowedIdentities: []") == 1
open(p, "w").write(s.replace("_allowedIdentities: []", "_allowedIdentities: [" + json.dumps(ident) + "]"))
EOF
g commit -qam "ci test base: allow the build service"
g push -q origin "$base"
g checkout -q "$head"
g merge -q --no-edit "$base"
g push -q origin "$head"
wait_build 2 build2
api GET "$api_base/git/repositories/$REPO/pullRequests/$pr_id/threads?api-version=7.1" >"$run/threads2.json"

say "a /vizzini command and a second commit"
thread="$(python3 -I -c '
import json, sys
for t in json.load(open(sys.argv[1]))["value"]:
    c = (t.get("comments") or [{}])[0].get("content") or ""
    if "<!-- vizzini:fp=" in c and (t.get("threadContext") or {}).get("filePath") == "/calc/calc.go":
        print(t["id"]); break' "$run/threads2.json")"
[[ -n $thread ]] || die "no bot thread on calc/calc.go after build 2"
api POST "$api_base/git/repositories/$REPO/pullRequests/$pr_id/threads/$thread/comments?api-version=7.1" \
	'{"parentCommentId":1,"content":"/vizzini explain What does this do?","commentType":"text"}' | jq_ 'd["id"]' >"$run/command-id"
printf '\n// Mod returns a %% b.\nfunc Mod(a, b int) int { return a %% b }\n' >>"$repo/calc/calc.go"
g commit -qam "ci test: Mod"
g push -q origin "$head"
wait_build 3 build3
api GET "$api_base/git/repositories/$REPO/pullRequests/$pr_id/threads?api-version=7.1" >"$run/threads3.json"
echo "$thread" >"$run/command-thread"

say "checks"
TEMPLATE="$template" python3 -I - "$run" "$identity" <<'EOF' | tee "$run/summary.md"
import json, os, re, sys
run, identity = sys.argv[1:]
ok = True
def check(cond, what):
    global ok
    ok &= bool(cond)
    print(("- [x] " if cond else "- [ ] ") + what)
read = lambda n: open(os.path.join(run, n), errors="replace").read()
marker = re.compile(r"<!-- vizzini:fp=(\S+) run=(\S+)")
def bot(name):
    out = []
    for t in json.load(open(os.path.join(run, name)))["value"]:
        cs = [c for c in t.get("comments", []) if c.get("commentType") != "system"]
        if cs and marker.search(cs[0].get("content") or ""):
            out.append((t, cs))
    return out

print("# vizzini-bot Azure Pipelines template, live (self-hosted agent)\n")
print("## build 1: the policy lists no identity\n")
log1 = read("build1.log")
check(read("build1.result").strip() == "failed", "the build failed")
check("exited with code '3'" in log1 and "the grant policy denied posting" in log1,
      "vizzini-bot exited 3 (the grant policy denied posting)")
check('"decision":"deny"' in log1 and "MRM-002" in log1, "denied by MRM-002 (identity not listed)")
check(identity, f"the log names the identity System.AccessToken posts as ({identity})")
tpl = open(os.environ["TEMPLATE"]).read()
mver = re.search(r"^\s*MRMAN_VERSION: (\S+)", tpl, re.M).group(1)
check("install: done" in log1 and f"mrman version {mver} (" in log1, f"install.sh installed and verified the tools on the agent (mrman {mver}, the template's pin)")
# The template pins VIZZINI_REF and, from Vizzini v0.1.1 on, VIZZINI_VERSION:
# install.sh then installs the released vizzini-bot instead of building it.
vref = re.search(r"VIZZINI_REF: ([0-9a-f]{40})", tpl).group(1)
vver = re.search(r"^\s*VIZZINI_VERSION: (\S+)", tpl, re.M)
if vver:
    vver = vver.group(1)
    check(f"install: vizzini-bot {vver} (vizzini_{vver[1:]}_linux_" in log1 and f"vizzini-bot {vver} (commit {vref}," in log1,
          f"install.sh installed the vizzini-bot {vver} release, checked against its SHA256SUMS and the pinned commit")
else:
    check(f"install: vizzini-bot from {vref[:7]}" in log1, "install.sh built vizzini-bot from the pinned commit")
# From Vizzini v0.1.3 on, the template pins GARMR_VERSION: install.sh then
# downloads the garmr release instead of building it with Go.
gver = re.search(r"^\s*GARMR_VERSION: (\S+)", tpl, re.M)
if gver:
    gver = gver.group(1)
    check(f"install: garmr {gver} (garmr_{gver[1:]}_linux_" in log1 and re.search(rf"(^|\s)garmr {re.escape(gver)}\s*$", log1, re.M),
          f"install.sh installed the garmr {gver} release, checked against its SHA256SUMS and its version")

print("\n## build 2: the identity allowed on the base branch\n")
log2 = read("build2.log")
t2 = bot("threads2.json")
check(read("build2.result").strip() == "succeeded", "the build succeeded")
check('"decision":"allow"' in log2, "the base branch's policy allowed it")
# From Vizzini v0.1.3 on, the template keeps the tools in the agent's tools
# directory (VIZZINI_TOOLS_CACHE). Build 1 runs on a new agent, so it fills
# the cache; builds 2 and 3 run on the same agent and must use it.
from_cache = lambda log: [t for t in ("vizzini-bot", "garmr", "mrman") if re.search(rf"install: {t} \S+ from the cache \(", log)]
caching = "VIZZINI_TOOLS_CACHE=" in tpl
if caching:
    check(not from_cache(log1) and from_cache(log2) == ["vizzini-bot", "garmr", "mrman"],
          "build 1 filled the agent's tools cache; build 2 installed all three tools from it")
check(t2, f"the findings were posted as threads with markers ({len(t2)})")
check(all(cs[0]["author"]["displayName"] == identity for _, cs in t2), f"posted as {identity}")

print("\n## build 3: a /vizzini command and a second commit\n")
log3 = read("build3.log")
t3 = bot("threads3.json")
fps = [marker.search(cs[0]["content"]).group(1) for _, cs in t3]
cid = read("command-id").strip()
thread = read("command-thread").strip()
replies = [c for t, cs in t3 if str(t["id"]) == thread for c in cs if f"vizzini:reply-to={cid} " in (c.get("content") or "")]
check(read("build3.result").strip() == "succeeded", "the build succeeded")
check("reviewing 1 file(s) changed since" in log3, "an incremental review of the changed file only")
if caching:
    check(from_cache(log3) == ["vizzini-bot", "garmr", "mrman"], "build 3 installed all three tools from the agent's tools cache")
check(len(fps) == len(set(fps)), f"no thread duplicated ({len(fps)} threads, {len(set(fps))} distinct)")
check(len(replies) == 1 and replies[0]["author"]["displayName"] == identity,
      f"the /vizzini command was answered once in its thread, by {identity}")
print("\nresult: " + ("PASS" if ok else "FAIL"))
sys.exit(0 if ok else 1)
EOF
