---
id: "01a1cf70-a6e2-71ef-86f5-04f66e0992f1"
title: "UAT-BOT-007: command-again: no command is answered twice"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "medium"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the bot does not answer a command again."
---

# UAT-BOT-007: command-again: no command is answered twice

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** Medium

## Objective
Make sure that the bot does not answer a command again.

## Preconditions
- The TS-BOT run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `command-again` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, count the replies in the command thread. | Each command has one reply only. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
