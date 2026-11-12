---
id: "01a1cf4a-f88f-7b26-9890-38585d3a1da3"
title: "LiteLLM proxy with Postgres spend logs"
type: "Architecture"
tags:
  - "architecture"
  - "litellm"
  - "cost"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "How the UAT reaches Claude: a podman pod running LiteLLM and Postgres on 127.0.0.1, keyed by podman secrets, recording spend per request without prompts."
---

# LiteLLM proxy with Postgres spend logs

`litellm/litellm.sh` runs the model gateway for live suites.

## Shape
- **Pod:** `vizzini-litellm-pod` holds two containers.
  - **`vizzini-litellm`:** the proxy, LiteLLM v1.99.4 by digest ([ADR-0003](/decisions/adr-0003-litellm-v1-99-4-with-explicit-max-tokens-for-the-claude-5-5-models--01a1caeb8cfe.md)), on `127.0.0.1:4000` only.
  - **`vizzini-litellm-db`:** Postgres 17.10 by digest. Its data is in the volume `vizzini-litellm-pg`, so cost history survives `down`/`up`.
- **Models** (`litellm/config.yaml`): `claude-sonnet-5-5` and `claude-opus-5-5` map to Anthropic, each with an explicit `max_tokens`, and `drop_params` is set.
- **Keys**, all podman secrets, never files the containers read from this repository:
  - `vizzini-anthropic-key`: the Anthropic key, created by a person ([setup](/runbooks/runbook-first-time-setup--01a1cf4a8f24.md)).
  - `vizzini-litellm-master`: a random proxy master key, generated into `.cache/litellm/master.key`.
  - `vizzini-litellm-db-password`: generated into `.cache/litellm/db.password`.
- **Clients:** `eval "$(litellm/litellm.sh env)"` exports `VIZZINI_LITELLM_URL` and `VIZZINI_API_KEY` (the master key) for Vizzini.

## Spend logs
- **Per request:** LiteLLM records spend, tokens and Vizzini's request metadata in `LiteLLM_SpendLogs`. The metadata is the run id, mode, PR key and requester.
- **Never stored:** `store_prompts_in_spend_logs: false` keeps prompts and diffs out ([ADR-0009](/decisions/adr-0009-cost-attribution-from-litellm-spend-logs-never-prompts--01a1cf4af8f4.md)).
- **Reports:** `uat/costs.sh` joins the logs with each run's facts into `costs.md` ([read the costs](/runbooks/runbook-read-a-runs-costs--01a1cf4af85c.md)).

## Commands
`up`, `down`, `status`, `env`, `smoke`, `logs`, `psql`, `views`, and `reset`, which also deletes the database.
