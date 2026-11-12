---
id: "01a1cf70-a661-7879-b6e2-a573f78ca11a"
title: "UAT-REV-008: garmr denies a review with Critical or Major findings"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that garmr evaluates each review and denies a review with blocking findings."
---

# UAT-REV-008: garmr denies a review with Critical or Major findings

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** High

## Objective
Make sure that garmr evaluates each review and denies a review with blocking findings.

## Preconditions
- The TS-REV run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `garmr produced a decision` for each scope. | The line starts with `PASS`. |
| 2 | Find the line `garmr exit code matches decision deny`. | The line starts with `PASS`. |
| 3 | Find the line `garmr denies a review with Critical/Major findings (VZ-001)`. | The line starts with `PASS`. |
| 4 | Open `<run>/summary.md`. Find the garmr row. | The row shows `deny` and the rule `VZ-001`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
