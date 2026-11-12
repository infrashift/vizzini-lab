---
id: "01a1cf70-a6f2-76b7-bc2c-375524293d1e"
title: "UAT-BOT-009: suppress: a merged rule suppresses the finding"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that a rule on the base branch stops the finding from being posted again."
---

# UAT-BOT-009: suppress: a merged rule suppresses the finding

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that a rule on the base branch stops the finding from being posted again.

## Preconditions
- The TS-BOT run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `suppress` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/repo/.vizzini/suppressions.yaml`. | The file has the suggested rule. |
| 3 | Open `<run>/suppress/bot.json`. | `suppressed` has the rule's id. `suggested` is empty. |
| 4 | Examine `src/Data/Db.cs` in the browser. | The PR has no new thread for the dismissed category on that file. |
| 5 | Examine the dismissed thread. | The status is still *Won't fix*. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0005](/decisions/adr-0005-memory-legs-rerun-and-fix-on-the-same-pr--01a1cc2b9471.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
