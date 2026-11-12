---
id: "01a1cf70-a6c1-7b2d-8d33-21c485842889"
title: "UAT-BOT-003: idle: the same head gets no review"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the bot does not review again when nothing changed."
---

# UAT-BOT-003: idle: the same head gets no review

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that the bot does not review again when nothing changed.

## Preconditions
- The TS-BOT run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `idle` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/idle/bot.json`. | The value of `mode` is `unchanged`. |
| 3 | Examine `<run>/idle/`. | The directory has no `review.json`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0005](/decisions/adr-0005-memory-legs-rerun-and-fix-on-the-same-pr--01a1cc2b9471.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
