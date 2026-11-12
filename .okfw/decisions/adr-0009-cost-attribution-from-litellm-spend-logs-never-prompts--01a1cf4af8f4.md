---
id: "01a1cf4a-f8f4-7cab-9365-32f421421255"
title: "ADR-0009: Cost attribution from LiteLLM spend logs, never prompts"
type: "ADR"
tags:
  - "adr"
  - "cost"
  - "privacy"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Every live run's cost is read from LiteLLM's Postgres spend logs keyed by Vizzini's request metadata; prompts and diffs are never stored there, and the requester identity is redacted in logs."
---

# ADR-0009: Cost attribution from LiteLLM spend logs, never prompts

**Status:** Accepted
**Date:** 2026-11-11
**Related:** [proxy](/architecture/litellm-proxy-with-postgres-spend-logs--01a1cf4af88f.md), [read the costs](/runbooks/runbook-read-a-runs-costs--01a1cf4af85c.md); Vizzini ISSUE-025

## Context
Vizzini needed proof that a review's cost can be attributed:
- to its run and mode;
- to the pull request across its whole lifecycle;
- to the person who caused it.

That proof had to come without a second store of the code under review.

## Decision
- **Where costs come from:** LiteLLM runs with Postgres. Every request is recorded in `LiteLLM_SpendLogs` with Vizzini's metadata: run id, mode, a stable PR key and the requester.
- **No prompts:** `store_prompts_in_spend_logs: false`. Prompts and diffs never reach the database.
- **The requester** is the human behind the token, the PAT owner's forge identity (`ado.sh whoami`). Logs redact it to three characters.
- **The report:** `uat/costs.sh` waits for LiteLLM's batched writes, records run facts (`record_runs.py`) and reports through Vizzini's views.

## Consequences
- **Costs per run, per finding and per PR lifecycle** come from one SQL source, including bot reruns and `/vizzini` commands.
- **The database holds personal data** (the requester). It stays in a local volume, and `litellm.sh reset` deletes it.
