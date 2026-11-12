---
id: "01a1cfa4-f481-7cad-a7d6-fc796d5f9dcc"
title: "UAT-WF-006: A new defect gets a new thread"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "medium"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that a defect added in a later push gets its own thread."
---

# UAT-WF-006: A new defect gets a new thread

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** Medium
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-04

## Objective
Make sure that a defect added in a later push gets its own thread.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-006 a new defect` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, examine `wf/regress.go`. | The file has one thread. Its status is *Active*. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
