---
id: "01a1cf70-a6ea-7561-aa20-c2b3100c9057"
title: "UAT-BOT-008: dismiss: a won't-fix thread gets one suppression rule"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the bot suggests a suppression rule when a person dismisses its thread."
---

# UAT-BOT-008: dismiss: a won't-fix thread gets one suppression rule

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that the bot suggests a suppression rule when a person dismisses its thread.

## Preconditions
- The TS-BOT run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `dismiss` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, open the thread on `src/Data/Db.cs`. | The status is *Won't fix*. |
| 3 | Examine the bot's reply. | The reply has one `suppressions:` rule with `paths: ["src/Data/Db.cs"]` and a `reason:`. |
| 4 | Open `<run>/suggested-rule.yaml`. | The file has the same rule. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0005](/decisions/adr-0005-memory-legs-rerun-and-fix-on-the-same-pr--01a1cc2b9471.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
