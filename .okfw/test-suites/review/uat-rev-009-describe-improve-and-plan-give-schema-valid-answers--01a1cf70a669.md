---
id: "01a1cf70-a669-775c-a6d4-075bb376f2ae"
title: "UAT-REV-009: describe, improve and plan give schema-valid answers"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "medium"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the other Vizzini modes give answers that agree with the schema."
---

# UAT-REV-009: describe, improve and plan give schema-valid answers

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** Medium

## Objective
Make sure that the other Vizzini modes give answers that agree with the schema.

## Preconditions
- The TS-REV run is complete.

## Test data
- `fixtures/<fixture>/issue.json` for plan mode.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `describe returns a schema-valid answer` for each scope. | The line starts with `PASS`. |
| 2 | Find the line `improve returns a schema-valid answer` for each scope. | The line starts with `PASS`. |
| 3 | Find the line `plan returns a schema-valid answer` for each scope. | The line starts with `PASS`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
