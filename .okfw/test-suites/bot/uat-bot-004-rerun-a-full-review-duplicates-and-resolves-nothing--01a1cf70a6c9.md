---
id: "01a1cf70-a6c9-799e-b5a4-a70f5c5ff036"
title: "UAT-BOT-004: rerun: a full review duplicates and resolves nothing"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the bot reads its threads and does not post a finding again."
---

# UAT-BOT-004: rerun: a full review duplicates and resolves nothing

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that the bot reads its threads and does not post a finding again.

## Preconditions
- The TS-BOT run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `rerun` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/rerun/bot.json`. | `already_posted` is not empty. `resolved` is empty. |
| 3 | Examine the PR in the browser. | The thread count is the same as after UAT-BOT-002. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0005](/decisions/adr-0005-memory-legs-rerun-and-fix-on-the-same-pr--01a1cc2b9471.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
