---
id: "01a1cfa4-f464-756a-87a5-c2bfdca6b26b"
title: "UAT-WF-003: A person fixes; the bot resolves"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that the bot verifies a person's fix and resolves its own thread."
---

# UAT-WF-003: A person fixes; the bot resolves

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-03

## Objective
Make sure that the bot verifies a person's fix and resolves its own thread.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-003 a person fixes` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, open the thread on `wf/person.go`. | The status is *Resolved*. |
| 3 | Examine the last reply. | The reply starts with `Resolved by vizzini-bot: the code here changed`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
