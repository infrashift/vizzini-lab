---
id: "01a1cfa4-f450-7dca-b052-2f63463a815f"
title: "UAT-WF-001: The review posts one thread for each finding"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that the bot posts each planted finding as its own thread."
---

# UAT-WF-001: The review posts one thread for each finding

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-01

## Objective
Make sure that the bot posts each planted finding as its own thread.

## Preconditions
- The TS-WF run is complete.

## Test data
- `wf/person.go`, `agent.go`, `nofix.go`, `defend.go`, `withdraw.go`: one weak hash each, line 5.
- `<run>/lint-0.json`: five gosec G401 diagnostics.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== round 0: the review` in the output. | The line `bot: … 5 new …` shows. |
| 2 | Find the section `## UAT-WF-001 the review` in `<run>/summary.md`. | Each item shows `[x]`. |
| 3 | Open the PR (`<run>/pr-url`) in the browser. | The PR has five threads from the PAT's user, one on each `wf/*.go` file. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
