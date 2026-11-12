---
id: "01a1cfa4-f478-732e-8b0e-90878694f666"
title: "UAT-WF-005: A change that does not fix keeps the thread open"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that a moved but unfixed defect keeps its thread, with no duplicate."
---

# UAT-WF-005: A change that does not fix keeps the thread open

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-04

## Objective
Make sure that a moved but unfixed defect keeps its thread, with no duplicate.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-005 a change that does not fix` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, examine `wf/nofix.go`. | The file has one thread. Its status is *Active*. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
