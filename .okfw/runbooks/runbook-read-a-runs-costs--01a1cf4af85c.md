---
id: "01a1cf4a-f85c-7526-838f-493111ae6f74"
title: "Runbook: read a run's costs"
type: "Runbook"
tags:
  - "runbook"
  - "cost"
  - "litellm"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Produce and read a run's cost report from LiteLLM's spend logs with uat/costs.sh and litellm.sh psql."
---

# Runbook: read a run's costs

Every live `uat/run.sh` ends by running `uat/costs.sh` on its run directory. It writes `costs.md`; the source data is described in [the proxy architecture](/architecture/litellm-proxy-with-postgres-spend-logs--01a1cf4af88f.md) and [ADR-0009](/decisions/adr-0009-cost-attribution-from-litellm-spend-logs-never-prompts--01a1cf4af8f4.md).

## Produce
- **Re-run for one run directory:** `uat/costs.sh .cache/runs/<UTC>`. It is safe to repeat.
- LiteLLM writes spend logs in batches. The script waits, up to 3 minutes, until every request the run's reports counted is in the database.
- It records each run's facts in `vizzini_run_facts` (`uat/record_runs.py`) and uses Vizzini's views, created by `litellm/litellm.sh views` from the pinned Vizzini's `deploy/litellm/views.sql`.

## Read `costs.md`
- **Per review run:** cost, tokens, and the waste from repairs and retries.
- **Findings:** the count, and the cost per finding.
- **Per pull request:** the lifecycle total across every run on that PR, including bot reruns and `/vizzini` commands.

## Ad hoc
- `litellm/litellm.sh psql` opens psql in the spend-log database.
- `litellm/litellm.sh psql 'select …'` runs one query.
- The raw table is `"LiteLLM_SpendLogs"`. Vizzini's metadata (run id, mode, PR key, requester) is in its metadata column.

The requester is the PAT owner's identity, which is personal data. Keep it out of anything copied from the database ([credentials](/architecture/credential-handling--01a1cf4af8b1.md)).
