---
id: "01a1cf4a-f807-7c02-9d58-27170e3cc396"
title: "Runbook: run the unattended bot test"
type: "Runbook"
tags:
  - "runbook"
  - "bot"
  - "automation"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Run uat/bot.sh, live or against stubllm, and read its nine legs on an Azure DevOps PR."
---

# Runbook: run the unattended bot test

`uat/bot.sh` runs vizzini-bot on a seeded fixture's ADO PR the way a CI step would, with no person: up to nine legs on one PR ([ADR-0004](/decisions/adr-0004-the-unattended-leg-authorizes-by-policy-deny-first--01a1cbfe4052.md), [ADR-0005](/decisions/adr-0005-memory-legs-rerun-and-fix-on-the-same-pr--01a1cc2b9471.md)).

## Run
- **Live:** `make litellm-up`, then `make uat-bot`. A run makes several reviews; ADR-0005 put four of them at about $0.22 with Sonnet 5.5.
- **Token-free:** `make uat-bot-stub` uses stubllm. It still posts on ADO.
- **Options:** `uat/bot.sh --fixture csharp-seeded --model claude-opus-5-5`. Only fixtures with a `fix/` overlay (csharp-seeded) run the legs after `rerun`.

## The legs
| leg | what must happen |
|---|---|
| deny | the committed default policy denies your PAT's identity (MRM-002): exit 3, nothing posted |
| allow | a run-local policy listing the forge-verified identity: one marked thread per finding |
| idle | same head, incremental: no review at all |
| rerun | same head, `--full`: nothing duplicated, nothing resolved |
| fix | a pushed fix: only the changed file reviewed; only threads whose finding is gone resolved |
| command | `/vizzini explain` and a malformed command answered in the thread |
| command-again | nothing answered twice |
| dismiss | a thread resolved as won't fix gets one suggested suppression rule |
| suppress | the rule merged into the base branch: the finding comes back suppressed, not posted |

## Read the result
- The run ends with `result: PASS` or `FAIL` and a checklist. Evidence is under `.cache/runs/<UTC>-bot/`.
- Live runs also attribute every model call to its run and PR in the spend logs ([ADR-0009](/decisions/adr-0009-cost-attribution-from-litellm-spend-logs-never-prompts--01a1cf4af8f4.md)).

## After
**The PR is left open** for inspection; the script does not abandon it. Abandon that one PR in the ADO web UI. `make ado-down` also works, but it deletes every `uat/*` branch ([cleanup](/runbooks/runbook-clean-up-after-an-interrupted-run--01a1cf4af83a.md)).
