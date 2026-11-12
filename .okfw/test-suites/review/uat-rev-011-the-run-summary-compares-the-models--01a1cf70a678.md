---
id: "01a1cf70-a678-7d4a-9d52-175348051cf9"
title: "UAT-REV-011: The run summary compares the models"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "low"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the run records the model comparison. The values are metrics. They do not fail the run."
---

# UAT-REV-011: The run summary compares the models

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** Low

## Objective
Make sure that the run records the model comparison. The values are metrics. They do not fail the run.

## Preconditions
- The TS-REV run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Open `<run>/summary.md`. | The file starts with the tool versions and commits. |
| 2 | Find the line `**Hard checks:** N/M passed`. | N is equal to M. |
| 3 | Find each table *Seeded defects*. | The table has one column for each model. |
| 4 | Find the rows `recall` and `findings on the clean decoy` for each model. | The rows show a value for each model. |
| 5 | Write the two values in the record. | The record has the metrics. |

> **NOTE:** Recall, category agreement, severities and decoy findings are metrics ([ADR-0010](/decisions/adr-0010-seeded-fixtures-per-language-only-must-catch-defects-are-hard--01a1cf4af906.md)). Write them down. Do not fail the case on them.

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
