#!/usr/bin/env bash
# Register with AZP_URL / AZP_POOL as AZP_AGENT, run until stopped, then
# deregister. The PAT arrives as VSTS_AGENT_INPUT_TOKEN (the agent's own
# unattended input variable), never on a command line.
set -euo pipefail
: "${AZP_URL:?}" "${AZP_POOL:?}" "${AZP_AGENT:?}" "${VSTS_AGENT_INPUT_TOKEN:?}"
cd /azp
./config.sh --unattended --url "$AZP_URL" --auth pat --pool "$AZP_POOL" --agent "$AZP_AGENT" \
	--work _work --replace --acceptTeeEula
cleanup() { ./config.sh remove --unattended --auth pat || true; }
trap cleanup EXIT
trap 'kill -TERM "$pid" 2>/dev/null' TERM INT
./run.sh &
pid=$!
wait "$pid" || true
