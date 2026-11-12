#!/usr/bin/env bash
# ci-gitlab.sh: run Vizzini's GitLab CI template for real.
#
#   uat/ci-gitlab.sh
#
# There is no GitLab account behind this test: it starts a throwaway GitLab CE
# and a gitlab-runner (docker executor, on this machine's rootless podman
# socket) in podman, both pinned by digest, on a private podman network. The
# instance is self-managed, http only, reachable from this machine on
# 127.0.0.1 only, and removed with everything in it at the end. Its data and
# the jobs' Go caches live on tmpfs (RAM, about 3 GB at peak), not on disk. The test
# changes the template (deploy/ci/gitlab/vizzini-bot.gitlab-ci.yml, from the
# pinned Vizzini commit) in one way only: the model is Vizzini's stubllm,
# started in the job (-finding-per-file). The template itself lists the
# self-managed instance in mrman's config.
#
#   1. a private project; a project access token, role Reporter, scope api,
#      saved as the masked CI/CD variable VIZZINI_GITLAB_TOKEN (the template's
#      setup); the default branch ci/base: a Go file, the template's grant
#      policy (no identity) and the test .gitlab-ci.yml
#   2. MR from ci/pr
#      -> the job must fail with exit 3, nothing posted; its log names the
#         identity the token posts as (the project's bot user)
#   3. that identity committed to the base's policy; a new commit on the MR
#      -> the job posts the stub's findings as discussions with markers
#   4. a "/vizzini explain" note in a bot discussion, and a commit that
#      changes calc.go and removes calc/extra.go
#      -> an incremental review of calc.go, nothing duplicated; the command
#         answered once in its discussion, and the extra.go discussion
#         resolved by the bot (mrman v0.1.6: reply and resolve on GitLab)
#   5. the containers, their volumes, the job containers and the network
#      removed
#
# The runner logs each job container's DNS server and whether github.com
# resolves, before the job (a pre-build script outside the template).
#
# Every token is made for the run and dies with the instance. The root token
# reaches GitLab through `podman exec -e NAME`, git through a credential
# helper and curl through a config on stdin, never a command line. Writes
# .cache/runs/<UTC>-ci-gitlab/; exits non-zero when a check fails.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
vz="$root/.cache/src/vizzini"
template="$vz/deploy/ci/gitlab/vizzini-bot.gitlab-ci.yml"
port="${CI_GITLAB_PORT:-18480}"
gl_host=gitlab.uat.test

say() { printf '\n== %s\n' "$*"; }
die() { printf 'ci-gitlab: %s\n' "$*" >&2; exit 1; }
[[ -f $template ]] || die "no $template: pin a Vizzini commit with deploy/ci (uat/build.sh vizzini)"
[[ -n ${GITLAB_CE_IMAGE:-} && -n ${GITLAB_RUNNER_IMAGE:-} ]] || die "set GITLAB_CE_IMAGE and GITLAB_RUNNER_IMAGE in versions.env"
sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
[[ -S $sock ]] || die "no podman socket at $sock: systemctl --user start podman.socket"

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
run="$root/.cache/runs/$stamp-ci-gitlab"
net="vizzini-lab-gl-$stamp" gl="vizzini-lab-gitlab-$stamp" runner="vizzini-lab-runner-$stamp"
base=ci/base head=ci/pr
mkdir -p "$run"
echo "run: $run"

GL_ROOT_TOKEN="glpat-$(python3 -I -c 'import secrets; print(secrets.token_urlsafe(24))')"
export GL_ROOT_TOKEN
api_base="http://127.0.0.1:$port/api/v4"

# api METHOD PATH [JSON]: the body; fails on a non-2xx status.
api() {
	local out code
	out="$(mktemp)"
	code="$(printf 'header = "PRIVATE-TOKEN: %s"\n' "$GL_ROOT_TOKEN" |
		curl -sS -K - -o "$out" -w '%{http_code}' -X "$1" -H 'Content-Type: application/json' ${3:+--data "$3"} "$api_base$2")" || true
	if [[ $code != 2* ]]; then
		echo "ci-gitlab: $1 $2 -> HTTP $code: $(head -c 400 "$out")" >&2
		rm -f "$out"
		return 1
	fi
	cat "$out"
	rm -f "$out"
}
jq_() { python3 -I -c "import json,sys; d=json.load(sys.stdin); print($1)"; }

runner_label=com.gitlab.gitlab-runner.type
before_ctrs="$(podman ps -aq --filter "label=$runner_label" | sort)"
before_vols="$(podman volume ls -q --filter "label=$runner_label" | sort)"
cleanup() {
	say "cleanup"
	if podman container exists "$runner" 2>/dev/null; then
		podman logs "$runner" >"$run/runner.log" 2>&1 || true
		podman rm -f -t 10 "$runner" >/dev/null && echo "   runner $runner removed"
	fi
	local c v
	for c in $(comm -13 <(echo "$before_ctrs") <(podman ps -aq --filter "label=$runner_label" | sort)); do
		podman rm -f "$c" >/dev/null && echo "   job container $c removed"
	done
	for v in $(comm -13 <(echo "$before_vols") <(podman volume ls -q --filter "label=$runner_label" | sort)); do
		podman volume rm -f "$v" >/dev/null && echo "   job volume $v removed"
	done
	if podman container exists "$gl" 2>/dev/null; then
		podman rm -f -v -t 30 "$gl" >/dev/null && echo "   GitLab $gl and its volumes removed"
	fi
	podman network exists "$net" 2>/dev/null && podman network rm "$net" >/dev/null && echo "   network $net removed"
	return 0
}
trap cleanup EXIT

# The test pipeline: the template, with stubllm and the mrman host entry.
python3 -I - "$template" "$run/gitlab-ci.yml" <<'EOF'
import sys, yaml
p = yaml.safe_load(open(sys.argv[1]))
job = p["vizzini-bot"]
s = job["script"]
i = next(n for n, l in enumerate(s) if l.startswith("export PATH="))
s[i + 1:i + 1] = [
    # vizzini-lab test only: stubllm, built from the pinned Vizzini clone, is the model.
    '(cd "$tools-src" && go build -o "$tools/stubllm" ./scripts/e2e/stubllm)',
    'nohup "$tools/stubllm" -addr 127.0.0.1:18765 -finding-per-file >"$tools-stubllm.log" 2>&1 &',
    "for _ in $(seq 50); do curl -s -o /dev/null http://127.0.0.1:18765/ && break; sleep 0.2; done",
]
job["variables"].update({"VIZZINI_LITELLM_URL": "http://127.0.0.1:18765/v1", "VIZZINI_MODEL": "stub", "VIZZINI_API_KEY": ""})
open(sys.argv[2], "w").write("# Generated by vizzini-lab uat/ci-gitlab.sh from Vizzini's deploy/ci/gitlab/vizzini-bot.gitlab-ci.yml;\n"
                             "# the only change: stubllm, started in the job, is the model.\n"
                             + yaml.safe_dump(p, sort_keys=False, width=1000))
EOF
diff <(python3 -I -c 'import sys,yaml,json; print(json.dumps(yaml.safe_load(open(sys.argv[1])),indent=1))' "$template") \
	<(python3 -I -c 'import sys,yaml,json; print(json.dumps(yaml.safe_load(open(sys.argv[1])),indent=1))' "$run/gitlab-ci.yml") \
	>"$run/pipeline.diff" || true
echo "   test pipeline: the template plus $(grep -c '^>' "$run/pipeline.diff") changed line(s) (pipeline.diff)"

say "GitLab CE and a runner in podman"
podman network create "$net" >/dev/null
podman run -d --name "$gl" --hostname "$gl_host" --network "$net" --network-alias "$gl_host" \
	-p "127.0.0.1:$port:80" --shm-size 256m \
	--tmpfs /var/opt/gitlab:rw,exec,size=8g,mode=755 --tmpfs /var/log/gitlab:rw,size=2g,mode=755 \
	-e GITLAB_OMNIBUS_CONFIG="external_url 'http://$gl_host'; puma['worker_processes'] = 0; sidekiq['concurrency'] = 10;
prometheus_monitoring['enable'] = false; registry['enable'] = false; gitlab_kas['enable'] = false;
gitlab_rails['usage_ping_enabled'] = false" \
	"$GITLAB_CE_IMAGE" >/dev/null
for _ in $(seq 120); do podman exec "$gl" curl -fs -o /dev/null http://localhost/-/readiness 2>/dev/null && break; sleep 5; done
podman exec "$gl" curl -fs -o /dev/null http://localhost/-/readiness || { podman logs --tail 30 "$gl"; die "GitLab did not come up in 10 min"; }
echo "   GitLab $(podman exec "$gl" cat /opt/gitlab/version-manifest.txt | head -1) ready"
podman exec -e GL_ROOT_TOKEN "$gl" gitlab-rails runner '
u = User.find_by_username("root")
t = u.personal_access_tokens.build(name: "vizzini-lab", scopes: [:api, :write_repository], expires_at: 2.days.from_now.to_date)
t.organization_id = Organizations::Organization.first.id if t.respond_to?(:organization_id=)
t.set_token(ENV.fetch("GL_ROOT_TOKEN"))
t.save!' >/dev/null
api GET /version | jq_ '"   API " + d["version"]'

runner_json="$(api POST /user/runners '{"runner_type":"instance_type","run_untagged":true,"description":"vizzini-lab"}')"
CI_SERVER_TOKEN="$(jq_ 'd["token"]' <<<"$runner_json")"
export CI_SERVER_TOKEN
# The jobs' Go module and build caches on tmpfs.
cat >"$run/runner-template.toml" <<'EOF2'
[[runners]]
  [runners.docker]
    [runners.docker.tmpfs]
      "/go/pkg" = "rw,exec,size=8g"
      "/root/.cache" = "rw,exec,size=8g"
EOF2
podman run -d --name "$runner" --network "$net" -v "$sock:/var/run/docker.sock" \
	-v "$run/runner-template.toml:/etc/vizzini-lab-runner.toml:ro" "$GITLAB_RUNNER_IMAGE" >/dev/null
podman exec -e CI_SERVER_TOKEN "$runner" gitlab-runner register --non-interactive --url "http://$gl_host" \
	--executor docker --docker-image docker.io/library/golang:1.25.4 --docker-network-mode "$net" \
	--docker-pull-policy if-not-present --description vizzini-lab \
	--template-config /etc/vizzini-lab-runner.toml \
	--pre-build-script 'echo "runner: job DNS: $(grep -m1 ^nameserver /etc/resolv.conf); github.com: $(getent hosts github.com || echo unresolved)"' \
	>"$run/register.log" 2>&1 ||
	{ cat "$run/register.log"; die "runner registration failed"; }
echo "   runner registered (docker executor on $sock, network $net)"

say "project, token, branches"
project_id="$(api POST /projects '{"name":"vizzini-ci","visibility":"private","initialize_with_readme":false}' | jq_ 'd["id"]')"
bot_json="$(api POST "/projects/$project_id/access_tokens" "$(python3 -I -c '
import datetime, json
print(json.dumps({"name": "vizzini-bot", "scopes": ["api"], "access_level": 20,
  "expires_at": (datetime.date.today() + datetime.timedelta(days=2)).isoformat()}))')")"
bot_user="$(jq_ 'd["user_id"]' <<<"$bot_json")"
python3 -I -c '
import json, sys
t = json.load(sys.stdin)["token"]
print(json.dumps({"key": "VIZZINI_GITLAB_TOKEN", "value": t, "masked": True, "protected": False}))' <<<"$bot_json" >"$run/.var.json"
api POST "/projects/$project_id/variables" "$(<"$run/.var.json")" >/dev/null
rm -f "$run/.var.json"
unset bot_json
echo "   project $project_id; access token (Reporter, api) for bot user $bot_user in VIZZINI_GITLAB_TOKEN (masked)"

repo="$run/repo"
git init -q -b "$base" "$repo"
# shellcheck disable=SC2016 # the token is expanded by git's helper, at run time
g() {
	git -C "$repo" -c credential.helper= \
		-c 'credential.helper=!f() { echo username=root; echo "password=$GL_ROOT_TOKEN"; }; f' \
		-c user.name=vizzini-lab -c user.email=uat@example.invalid "$@"
}
mkdir -p "$repo/calc" "$repo/.vizzini/grant-policy"
printf 'package calc\n\n// Add returns a + b.\nfunc Add(a, b int) int { return a + b }\n' >"$repo/calc/calc.go"
cp "$vz/deploy/ci/grant-policy/agent-submit.cue" "$repo/.vizzini/grant-policy/"
cp "$run/gitlab-ci.yml" "$repo/.gitlab-ci.yml"
g add -A
g commit -qm "ci test base: calc, the grant policy (no identity), the test pipeline"
g remote add origin "http://127.0.0.1:$port/root/vizzini-ci.git"
g push -q origin "$base"
g checkout -qb "$head"
printf '\n// Div returns a / b.\nfunc Div(a, b int) int { return a / b }\n' >>"$repo/calc/calc.go"
printf 'package calc\n\n// Neg returns -a.\nfunc Neg(a int) int { return -a }\n' >"$repo/calc/extra.go"
g add -A
g commit -qm "ci test: Div, and extra.go"
g push -q origin "$head"

# wait_pipeline NAME: wait for the newest MR pipeline of the commit just
# pushed (the head of ci/pr) to finish; save its job's log and status as
# $run/NAME.{log,result}. Pipelines are matched by commit, not counted:
# GitLab sometimes creates a second pipeline for one commit (seen live).
wait_pipeline() {
	local name=$1 sha id="" status="" waited=0 job
	sha="$(g rev-parse "$head")"
	while ((waited < 1500)); do
		read -r id status < <(api GET "/projects/$project_id/merge_requests/$mr/pipelines?per_page=100" | python3 -I -c '
import json, sys
ps = sorted((p for p in json.load(sys.stdin) if p["sha"] == sys.argv[1]), key=lambda p: p["id"])
print(ps[-1]["id"], ps[-1]["status"]) if ps else print("", "")' "$sha") || true
		[[ $status =~ ^(success|failed|canceled|skipped)$ ]] && break
		sleep 10
		waited=$((waited + 10))
	done
	[[ $status =~ ^(success|failed|canceled|skipped)$ ]] || die "no finished pipeline for ${sha:0:12} on MR !$mr after 1500s ($status)"
	job="$(api GET "/projects/$project_id/pipelines/$id/jobs" | jq_ 'd[0]["id"]')"
	echo "$status" >"$run/$name.result"
	api GET "/projects/$project_id/jobs/$job/trace" >"$run/$name.log" || true
	echo "   pipeline $id for ${sha:0:12} (job $job): $status"
}

say "MR: the policy lists no identity"
mr="$(api POST "/projects/$project_id/merge_requests" "{\"source_branch\":\"$head\",\"target_branch\":\"$base\",\"title\":\"vizzini-lab CI template test $stamp\"}" | jq_ 'd["iid"]')"
echo "   MR !$mr"
wait_pipeline job1
identity="$(python3 -I - "$run/job1.log" <<'EOF'
import json, re, sys
for line in open(sys.argv[1], errors="replace"):
    m = re.search(r"mrman: authorization: (\{.*\})\s*$", line)
    if m:
        print(json.loads(m.group(1))["input"]["identity"])
        break
EOF
)"
[[ -n $identity ]] || die "job 1 printed no authorization; see $run/job1.log"
echo "   VIZZINI_GITLAB_TOKEN posts as: $identity"
api GET "/users/$bot_user" | jq_ 'd["username"]' >"$run/bot-username"

say "allow the identity on the base branch; a new commit on the MR"
g checkout -q "$base"
python3 -I - "$repo/.vizzini/grant-policy/agent-submit.cue" "$identity" <<'EOF'
import json, sys
p, ident = sys.argv[1:]
s = open(p).read()
assert s.count("_allowedIdentities: []") == 1
open(p, "w").write(s.replace("_allowedIdentities: []", "_allowedIdentities: [" + json.dumps(ident) + "]"))
EOF
g commit -qam "ci test base: allow the bot user"
g push -q origin "$base"
g checkout -q "$head"
g merge -q --no-edit "$base"
g push -q origin "$head"
wait_pipeline job2
api GET "/projects/$project_id/merge_requests/$mr/discussions?per_page=100" >"$run/discussions2.json"

say "a /vizzini command and a second commit"
discussion="$(python3 -I -c '
import json, sys
for d in json.load(open(sys.argv[1])):
    n = d["notes"][0]
    if "<!-- vizzini:fp=" in n["body"] and (n.get("position") or {}).get("new_path") == "calc/calc.go":
        print(d["id"]); break' "$run/discussions2.json")"
[[ -n $discussion ]] || die "no bot discussion on calc/calc.go after job 2"
api POST "/projects/$project_id/merge_requests/$mr/discussions/$discussion/notes" '{"body":"/vizzini explain What does this do?"}' |
	jq_ 'd["id"]' >"$run/command-id"
echo "$discussion" >"$run/command-discussion"
# extra.go goes away, so its finding is gone: the bot resolves its own
# discussion there (mrman v0.1.6 resolves on GitLab).
g rm -q calc/extra.go
printf '\n// Mod returns a %% b.\nfunc Mod(a, b int) int { return a %% b }\n' >>"$repo/calc/calc.go"
g commit -qam "ci test: Mod, and extra.go removed"
g push -q origin "$head"
wait_pipeline job3
api GET "/projects/$project_id/merge_requests/$mr/discussions?per_page=100" >"$run/discussions3.json"

say "checks"
python3 -I - "$run" "$identity" <<'EOF' | tee "$run/summary.md"
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
    return [d for d in json.load(open(os.path.join(run, name)))
            if d["notes"] and marker.search(d["notes"][0]["body"] or "")]

print("# vizzini-bot GitLab CI template, live (self-managed GitLab CE in podman)\n")
print("## job 1: the policy lists no identity\n")
log1 = read("job1.log")
check(read("job1.result").strip() == "failed", "the job failed")
check("exit code 3" in log1 and "the grant policy denied posting" in log1,
      "vizzini-bot exited 3 (the grant policy denied posting)")
check('"decision":"deny"' in log1 and "MRM-002" in log1, "denied by MRM-002 (identity not listed)")
check(identity and identity == read("bot-username").strip(),
      f"the log names the identity the project access token posts as ({identity}, its bot user)")
check("install: done" in log1 and "mrman version v0.1.9" in log1, "install.sh built and verified the tools in the job")
# The bot user is named only if mrman authenticated, which on a self-managed
# host takes the template's [[forge.hosts]] entry.
check('if [ "$CI_SERVER_HOST" != gitlab.com ]' in log1 and identity == read("bot-username").strip(),
      "the template listed the self-managed instance in mrman's config, and mrman authenticated")

print("\n## job 2: the identity allowed on the base branch\n")
log2 = read("job2.log")
d2 = bot("discussions2.json")
check(read("job2.result").strip() == "success", "the job succeeded")
check('"decision":"allow"' in log2, "the base branch's policy allowed it")
check(d2, f"the findings were posted as discussions with markers ({len(d2)})")
check(all(d["notes"][0]["author"]["username"] == identity for d in d2), f"posted as {identity} (role Reporter)")
check(any((d["notes"][0].get("position") or {}).get("new_path") == "calc/calc.go" for d in d2), "a discussion sits on calc/calc.go")

print("\n## job 3: a /vizzini command, a second commit, and extra.go removed\n")
log3 = read("job3.log")
d3 = bot("discussions3.json")
fps = [marker.search(d["notes"][0]["body"]).group(1) for d in d3]
disc = read("command-discussion").strip()
replies = [n for d in d3 if d["id"] == disc for n in d["notes"] if "vizzini:reply-to=" in (n["body"] or "")]
check(read("job3.result").strip() == "success", "the job succeeded")
check("reviewing 1 file(s) changed since" in log3 and "1 file(s) with threads left the pull request" in log3,
      "an incremental review of calc.go; the removed calc/extra.go reconciled, not reviewed")
check(len(fps) == len(set(fps)), f"no discussion duplicated ({len(fps)} discussions, {len(set(fps))} distinct)")
check(len(replies) == 1 and replies[0]["author"]["username"] == identity,
      f"the /vizzini command was answered once in its discussion, by {identity} (mrman v0.1.6 replies on GitLab)")
extra = [d for d in d3 if (d["notes"][0].get("position") or {}).get("new_path") == "calc/extra.go"]
check(extra and all(d["notes"][0].get("resolved") and (d["notes"][0].get("resolved_by") or {}).get("username") == identity
                    and any("vizzini:reviewed" in (n["body"] or "") for n in d["notes"]) for d in extra),
      f"the finding on the removed calc/extra.go: {identity} resolved its own discussion, with its reply (mrman v0.1.6 resolves on GitLab)")
print("\nresult: " + ("PASS" if ok else "FAIL"))
sys.exit(0 if ok else 1)
EOF
