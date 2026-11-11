#!/usr/bin/env bash
# litellm.sh: run the UAT's LiteLLM proxy in podman.
#
#   litellm.sh up       start the proxy on 127.0.0.1:${LITELLM_PORT:-4000}
#   litellm.sh down     stop and remove it
#   litellm.sh status   exit 0 if it is up and healthy
#   litellm.sh env      print the VIZZINI_* exports for it (eval "$(litellm.sh env)")
#   litellm.sh smoke    one JSON-mode request per model in $MODELS
#   litellm.sh logs     the container's log
#
# The Anthropic key comes from the podman secret vizzini-anthropic-key. Create
# it once, in your own terminal, so the key never lands in a file or in shell
# history:
#
#   read -rs K && printf %s "$K" | podman secret create vizzini-anthropic-key - && unset K
#
# A random proxy master key is generated into .cache/litellm/master.key (0600)
# and handed to the container as the secret vizzini-litellm-master.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=versions.env
source "$root/versions.env"
name=vizzini-litellm
port="${LITELLM_PORT:-4000}"
url="http://127.0.0.1:$port"
keyfile="$root/.cache/litellm/master.key"
anthropic_secret="${ANTHROPIC_SECRET:-vizzini-anthropic-key}"
master_secret=vizzini-litellm-master

die() { printf 'litellm: %s\n' "$*" >&2; exit 1; }

healthy() { curl -sf -o /dev/null "$url/health/liveliness"; }

master_key() {
	[[ -s $keyfile ]] || die "no master key yet; run: $0 up"
	cat "$keyfile"
}

up() {
	podman secret exists "$anthropic_secret" || die "podman secret $anthropic_secret is missing. Create it in your own terminal:
  read -rs K && printf %s \"\$K\" | podman secret create $anthropic_secret - && unset K"
	if [[ ! -s $keyfile ]]; then
		mkdir -p "$(dirname "$keyfile")"
		(umask 077 && printf 'sk-uat-%s' "$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')" >"$keyfile")
	fi
	# Recreate the secret so it always matches the key file.
	podman secret rm "$master_secret" >/dev/null 2>&1 || true
	podman secret create "$master_secret" "$keyfile" >/dev/null
	podman rm -f "$name" >/dev/null 2>&1 || true
	podman run -d --name "$name" \
		-p "127.0.0.1:$port:4000" \
		-v "$root/litellm/config.yaml:/app/config.yaml:ro,Z" \
		--secret "$anthropic_secret,type=env,target=ANTHROPIC_API_KEY" \
		--secret "$master_secret,type=env,target=LITELLM_MASTER_KEY" \
		"$LITELLM_IMAGE" --config /app/config.yaml --port 4000 >/dev/null
	for _ in $(seq 120); do
		healthy && { echo "litellm: up at $url ($LITELLM_IMAGE)"; return; }
		podman container exists "$name" && [[ $(podman inspect -f '{{.State.Running}}' "$name") == true ]] ||
			{ podman logs --tail 30 "$name" >&2 || true; die "container exited"; }
		sleep 1
	done
	podman logs --tail 30 "$name" >&2
	die "not healthy after 120s"
}

smoke() {
	healthy || die "not running; run: $0 up"
	local key model rc=0
	key="$(master_key)"
	for model in $MODELS; do
		local started body
		started=$(date +%s.%N)
		body="$(curl -sS "$url/v1/chat/completions" \
			-H @<(printf 'Authorization: Bearer %s\n' "$key") \
			-H 'Content-Type: application/json' \
			-d "$(printf '{"model":"%s","response_format":{"type":"json_object"},"messages":[{"role":"system","content":"Answer with a single JSON object and nothing else."},{"role":"user","content":"Return {\\"ok\\": true, \\"language\\": \\"C#\\", \\"answer\\": 6*7} with answer evaluated."}]}' "$model")")" || {
			echo "  FAIL $model: request failed"
			rc=1
			continue
		}
		python3 -I - "$model" "$started" "$body" <<'EOF' || rc=1
import json, re, sys, time
model, started, body = sys.argv[1], float(sys.argv[2]), sys.argv[3]
took = time.time() - started
try:
    resp = json.loads(body)
except ValueError:
    print(f"  FAIL {model}: non-JSON response: {body[:300]}")
    sys.exit(1)
if "error" in resp:
    print(f"  FAIL {model}: {json.dumps(resp['error'])[:400]}")
    sys.exit(1)
content = resp["choices"][0]["message"]["content"] or ""
fenced = content.strip().startswith("```")
m = re.search(r"\{.*\}", content, re.S)
try:
    doc = json.loads(m.group(0) if m else content)
except ValueError:
    print(f"  FAIL {model}: content is not JSON: {content[:300]}")
    sys.exit(1)
if doc.get("ok") is not True or doc.get("answer") != 42:
    print(f"  FAIL {model}: unexpected answer {doc}")
    sys.exit(1)
u = resp.get("usage", {})
print(f"  PASS {model} -> {resp.get('model')} in {took:.1f}s, "
      f"tokens in/out {u.get('prompt_tokens')}/{u.get('completion_tokens')}, "
      f"finish {resp['choices'][0].get('finish_reason')}, "
      f"{'code-fenced' if fenced else 'bare'} JSON")
EOF
	done
	return $rc
}

case "${1:-}" in
up) up ;;
down)
	podman rm -f "$name" >/dev/null 2>&1 || true
	podman secret rm "$master_secret" >/dev/null 2>&1 || true
	echo "litellm: down"
	;;
status)
	if healthy; then echo "litellm: up at $url"; else echo "litellm: not running"; exit 1; fi
	;;
env)
	printf 'export VIZZINI_LITELLM_URL=%s/v1\n' "$url"
	printf 'export VIZZINI_API_KEY=%s\n' "$(master_key)"
	;;
smoke) smoke ;;
logs) podman logs "$name" ;;
*) sed -n '2,17p' "$0" >&2; exit 2 ;;
esac
