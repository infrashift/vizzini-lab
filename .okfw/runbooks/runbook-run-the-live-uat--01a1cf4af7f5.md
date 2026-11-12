---
id: "01a1cf4a-f7f5-78b4-be40-cfdff0785206"
title: "Runbook: run the live UAT"
type: "Runbook"
tags:
  - "runbook"
  - "live"
  - "forge"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Run make uat end to end with live Claude models, the attended mrman grant and the Azure DevOps leg, then record the result."
---

# Runbook: run the live UAT

`make uat` is the full UAT: [the flow](/architecture/uat-flow-one-c-pr-through-vizzini-garmr-okf-wiki-and-mrman--01a1caeb8cb9.md) with live Claude Sonnet 5.5 and Opus 5.5, both seeded fixtures, the Azure DevOps and mrman leg, and the real-world commits. It is **attended**: it waits for a person to grant mrman's submit ([ADR-0002](/decisions/adr-0002-the-mrman-submit-grant-stays-a-human-step--01a1caeb8ce7.md)).

## Before
- [First-time setup](/runbooks/runbook-first-time-setup--01a1cf4a8f24.md) is done, and `make ado-check` passes.
- `make litellm-up litellm-smoke`: both models answer in JSON mode.

## Run
1. `make uat`. Without the forge leg, run `make uat-vizzini`, which needs no person.
2. For each model the run opens an ADO PR and checks mrman's headless session. It then **pauses** and prints a command, `mrman pr <url> --vizzini-report … --auto` with a run-local `XDG_DATA_HOME`.
3. Run that command **in your own terminal** within `GRANT_TIMEOUT` (default 1200 s). Look at the findings in the TUI and grant submit. Leave it open while the harness posts the findings and reads the threads back over REST.
4. The run scores itself (`uat/score.py`). Its exit status is the hard checks' result ([ADR-0010](/decisions/adr-0010-seeded-fixtures-per-language-only-must-catch-defects-are-hard--01a1cf4af906.md)). It then writes `costs.md` ([read the costs](/runbooks/runbook-read-a-runs-costs--01a1cf4af85c.md)).

## After
- **Evidence:** `.cache/runs/<UTC>/summary.md`, `scores.json` and `costs.md` ([layout](/architecture/run-artifacts-and-the-cache-layout--01a1cf4af87e.md)).
- **Record a run worth keeping:** copy `summary.md` to `results/YYYY-MM-DD-live-<topic>.md`, and note the outcome in the issue or ADR the run was for (for example [ISSUE-001](/issues/issue-001-live-uat-with-claude-sonnet-5-5-and-opus-5-5--01a1caeb8d15.md)).
- **Clean ADO:** `make ado-down`. It abandons every open PR titled `vizzini-uat…` and deletes **every** `uat/*` branch, not just this run's; see [cleanup](/runbooks/runbook-clean-up-after-an-interrupted-run--01a1cf4af83a.md).
- `make litellm-down` when you are done with live models. The spend history stays in its volume.
