---
x-okfw-id: "01a20701-536d-78ab-89cc-932cf85f0148"
title: "UAT-BOT-011: quiet again: the next quiet review edits the status comment"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
x-okfw-created: "2026-11-23T00:04:17-06:00"
x-okfw-timestamp: "2026-11-23T00:04:17-06:00"
description: "Make sure that the next quiet review starts from the recorded head and edits the same status comment."
---

# UAT-BOT-011: quiet again: the next quiet review edits the status comment

# UAT-BOT-011: quiet again: the next quiet review edits the status comment

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that the next quiet review starts from the head that the status comment records, and that the bot edits that comment instead of posting a second one.

## Preconditions
- [UAT-BOT-010](/test-suites/bot/uat-bot-010-quiet-a-review-that-posts-nothing-records-its-head--01a207015360.md) passed in the same run.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the sections `quiet-2` and `quiet-idle` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/quiet-2/bot.json`. | `since` is the head in `<run>/quiet-1.head`. `reviewed_files` is `["docs/quiet-2.md"]`. `status` is `edited`. |
| 3 | Open `<run>/quiet-2/audit.jsonl`. | One allow decision, event `edit`. |
| 4 | Open `<run>/quiet-idle/bot.json`. | `mode` is `unchanged`. There is no `status`. |
| 5 | Examine the PR overview in the browser. | There is still one status comment. It names the second quiet commit. Its thread is still *Resolved*. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0028 (a review that posts nothing records its head in one edited status comment)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
