---
id: "01a1cf70-a6a1-7089-b009-1de4533ae4fd"
title: "UAT-FRG-005: The findings are posted as inline threads"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-frg"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that each finding becomes an inline thread on the PR."
---

# UAT-FRG-005: The findings are posted as inline threads

- **Suite:** [TS-FRG: Forge and mrman (attended)](/test-suites/forge/ts-frg-forge-and-mrman-attended--01a1cf70a603.md)
- **Priority:** High

## Objective
Make sure that each finding becomes an inline thread on the PR.

## Preconditions
- UAT-FRG-003 is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | In the first terminal, find the line `review add: N added, 0 failed`. | N is the finding count. The failed count is 0. |
| 2 | Find the line `ADO threads: N inline`. | N is more than 0. |
| 3 | Find the line `ADO threads sit on every must-catch defect`. | The line starts with `PASS`. |
| 4 | Refresh the PR in the browser. | The PR shows inline comment threads on the changed files. |
| 5 | Open the thread on the SQL injection line in `OrdersController.cs` (C#) or the command line in `export.ts` (TypeScript). | The thread shows the finding's title and text. |
| 6 | Quit mrman. | The TUI closes. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
