#!/usr/bin/env bash
# costs.sh: cost attribution for one UAT run (Vizzini ISSUE-025).
#
#   uat/costs.sh RUN_DIR
#
# Needs litellm/litellm.sh up (LiteLLM with its Postgres). LiteLLM batches
# spend-log writes, so this waits until every request the run's reports
# counted is in the database (up to 3 minutes), then
# records the runs' facts (uat/record_runs.py) and writes RUN_DIR/costs.md:
# cost, tokens, repair and retry waste, findings and cost per finding per
# run, and the lifecycle total per pull request. Safe to rerun.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
run="$(realpath "${1:?usage: $0 RUN_DIR}")"

# LiteLLM batches spend-log writes; every report (review, describe,
# improve, plan) counts its requests in its usage block, so wait until
# LiteLLM has that many rows for the run ids, then record and summarize.
want="$(python3 -I -c '
import json, os, sys
n = 0
for d, _, fs in os.walk(sys.argv[1]):
    for name in fs:
        if name.endswith(".json") and name[:-5] in ("review", "describe", "improve", "plan"):
            try:
                n += (json.load(open(os.path.join(d, name))).get("usage") or {}).get("requests", 0)
            except (ValueError, AttributeError):
                pass
print(n)' "$run")"
ids="$(grep -rhoE '"run_id": "[0-9a-f-]{36}"' "$run" --include=review.json --include=describe.json --include=improve.json --include=plan.json | cut -d'"' -f4 | sort -u | paste -sd, - | sed "s/[^,][^,]*/'&'/g")"
if [[ -z $ids ]]; then
	echo "   no report in $run carries a run_id; nothing to attribute"
	exit 0
fi
if ! "$root/litellm/litellm.sh" views >/dev/null 2>&1; then
	echo "   LiteLLM's spend-log database is not reachable (litellm/litellm.sh up?); skipped"
	exit 1
fi
{
	for _ in $(seq 18); do
		got="$("$root/litellm/litellm.sh" psql "SELECT count(*) FROM vizzini_requests WHERE run_id IN ($ids)" | sed -n 3p | tr -d ' ')"
		((got >= want)) && break
		sleep 10
	done
	python3 -I "$root/uat/record_runs.py" "$run" | "$root/litellm/litellm.sh" psql - || true
	{
		echo "# Cost attribution for run $(basename "$run")"
		echo
		echo "Reports counted $want request(s) in their usage blocks; LiteLLM recorded $got for those runs."
		echo
		echo '```'
		"$root/litellm/litellm.sh" psql "SELECT f.fixture, f.model, v.modes AS mode, v.requests, v.input_tokens AS in_tok, v.output_tokens AS out_tok, v.cost_usd, v.wasted_on_repairs_and_retries_usd AS wasted_usd, v.findings, v.cost_per_finding_usd AS per_finding FROM vizzini_runs v JOIN vizzini_run_facts f USING (run_id) WHERE v.run_id IN ($ids) ORDER BY f.fixture, f.model, v.modes"
		"$root/litellm/litellm.sh" psql "SELECT pr_key, iterations, runs, requests, cost_usd FROM vizzini_pr_costs WHERE pr_key IN (SELECT DISTINCT pr_key FROM vizzini_requests WHERE run_id IN ($ids)) ORDER BY pr_key"
		echo '```'
	} >"$run/costs.md" 2>&1 || true
	sed 's/^/   /' "$run/costs.md"
}
