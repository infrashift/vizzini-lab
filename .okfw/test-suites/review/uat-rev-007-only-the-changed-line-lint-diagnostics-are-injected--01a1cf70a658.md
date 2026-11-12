---
id: "01a1cf70-a658-753c-8faf-48f7e4af818d"
title: "UAT-REV-007: Only the changed-line lint diagnostics are injected"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "medium"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that Vizzini gives the model only the linter diagnostics on changed lines."
---

# UAT-REV-007: Only the changed-line lint diagnostics are injected

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** Medium

## Objective
Make sure that Vizzini gives the model only the linter diagnostics on changed lines.

## Preconditions
- The TS-REV run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `exactly the N changed-line lint diagnostic(s) injected` for each scope. | The line starts with `PASS`. |
| 2 | Open `<run>/<fixture>/repo.sarif`. | The file is SARIF from Roslyn (C#) or ESLint (TypeScript). |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
