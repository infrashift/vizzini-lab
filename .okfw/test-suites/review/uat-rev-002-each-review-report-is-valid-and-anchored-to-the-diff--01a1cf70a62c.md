---
id: "01a1cf70-a62c-7372-b2c9-a7a9420fbdc1"
title: "UAT-REV-002: Each review report is valid and anchored to the diff"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that each review gives a valid report and that each finding is on a changed line."
---

# UAT-REV-002: Each review report is valid and anchored to the diff

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** High

## Objective
Make sure that each review gives a valid report and that each finding is on a changed line.

## Preconditions
- The TS-REV run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | In the terminal output, find the lines for scope `<fixture>/<model>`. | The lines start with `PASS [<fixture>/<model>]`. |
| 2 | Find the line `review exit code is 0 or 2 (policy gate)`. | The line starts with `PASS`. |
| 3 | Find the line `report envelope`. | The line starts with `PASS`. |
| 4 | Find the line `repair loop never gave up`. | The line starts with `PASS`. |
| 5 | Find the line `all N finding(s) anchored to diff hunks`. | The line starts with `PASS`. N is more than 0. |
| 6 | Do steps 1 to 5 again for each fixture and model. | All lines start with `PASS`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
score.py check `report envelope`, [ADR-0010](/decisions/adr-0010-seeded-fixtures-per-language-only-must-catch-defects-are-hard--01a1cf4af906.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
