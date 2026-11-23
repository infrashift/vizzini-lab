---
id: "01a20701-5360-7d1b-a7ab-d099b65a937c"
title: "UAT-BOT-010: quiet: a review that posts nothing records its head"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
created: "2026-11-23T00:04:17-06:00"
timestamp: "2026-11-23T00:04:17-06:00"
description: "Make sure that a review with nothing to post records its head in one resolved status comment."
---

# UAT-BOT-010: quiet: a review that posts nothing records its head

# UAT-BOT-010: quiet: a review that posts nothing records its head

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that a review with nothing to post records its head in one status comment, and that the comment cannot block the PR.

## Preconditions
- The TS-BOT run is complete. It ran with `--stub` (`make uat-bot-stub`): only stubllm makes the quiet legs certain to find nothing.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `quiet-1` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/quiet-1/bot.json`. | `mode` is `incremental`, `reviewed_files` is `["docs/quiet-1.md"]`, `posted` is 0 and `status` is `posted`. |
| 3 | Open `<run>/quiet-1/audit.jsonl`. | Two allow decisions: event `comment`, then event `resolve`. |
| 4 | Examine the PR overview in the browser. | One comment from the bot says that it reviewed the PR through a commit and found nothing new. Its thread is *Resolved*. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0028 (a review that posts nothing records its head in one edited status comment)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
