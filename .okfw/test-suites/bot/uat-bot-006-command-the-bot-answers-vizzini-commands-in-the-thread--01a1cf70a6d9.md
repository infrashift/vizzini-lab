---
id: "01a1cf70-a6d9-7e01-95c6-92f1cd663e09"
title: "UAT-BOT-006: command: the bot answers /vizzini commands in the thread"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the bot answers a valid command and gives usage for a malformed command."
---

# UAT-BOT-006: command: the bot answers /vizzini commands in the thread

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that the bot answers a valid command and gives usage for a malformed command.

## Preconditions
- The TS-BOT run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `command` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, find the thread with `/vizzini explain`. | The thread has the command and a malformed `/vizzini` command. |
| 3 | Examine the reply to `/vizzini explain`. | The reply explains the finding. |
| 4 | Examine the reply to the malformed command. | The reply contains `I could not run that` and the usage. |
| 5 | For `make uat-bot` only: find the item `every command request is attributed to its run and PR`. | The item shows `[x]`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0005](/decisions/adr-0005-memory-legs-rerun-and-fix-on-the-same-pr--01a1cc2b9471.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
