---
id: "01a1cf70-a63c-72d3-b0e9-4f6dc13bc8ee"
title: "UAT-REV-004: The must-catch TypeScript defects are caught"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that each model finds the four must-catch defects in the TypeScript fixture."
---

# UAT-REV-004: The must-catch TypeScript defects are caught

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** High

## Objective
Make sure that each model finds the four must-catch defects in the TypeScript fixture.

## Preconditions
- The TS-REV run is complete.

## Test data
- `fixtures/ts-seeded/expected.json`: cmdinj (`export.ts`), eval (`calc.ts`), secret and protopollution (`config.ts`).

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the lines for scope `ts-seeded/<model>`. | The lines start with `PASS [ts-seeded/<model>]`. |
| 2 | Find the line `must-catch defect cmdinj caught`. | The line starts with `PASS`. |
| 3 | Find the line `must-catch defect eval caught`. | The line starts with `PASS`. |
| 4 | Find the line `must-catch defect secret caught`. | The line starts with `PASS`. |
| 5 | Find the line `must-catch defect protopollution caught`. | The line starts with `PASS`. |
| 6 | Open `<run>/summary.md`. Find the table *Seeded defects* for `ts-seeded`. | Each must-catch row shows ✅ and a severity for each model. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0010](/decisions/adr-0010-seeded-fixtures-per-language-only-must-catch-defects-are-hard--01a1cf4af906.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
