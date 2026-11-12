---
id: "01a1cfa4-f496-7807-be81-54a275029a97"
title: "UAT-WF-008: Withdraw: the bot resolves its own thread"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that the bot can withdraw its finding, and does not post it again."
---

# UAT-WF-008: Withdraw: the bot resolves its own thread

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-06

## Objective
Make sure that the bot can withdraw its finding, and does not post it again.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-008 a withdrawn finding` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, open the thread on `wf/withdraw.go`. | The status is *Resolved*. The bot's reply starts with `**Withdrawn.**`. |
| 3 | Open `<run>/bot-r3/bot.json`. | `posted` is `0`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
