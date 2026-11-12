---
id: "01a1cf70-a64e-7bdc-b3f7-dc79befc328a"
title: "UAT-REV-006: Only the relevant knowledge reaches the model"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "medium"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that Vizzini gives the model the relevant ADRs and no other OKF document."
---

# UAT-REV-006: Only the relevant knowledge reaches the model

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** Medium

## Objective
Make sure that Vizzini gives the model the relevant ADRs and no other OKF document.

## Preconditions
- The TS-REV run is complete.

## Test data
- Each fixture wiki has two ADRs that apply and one runbook that must not apply.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `knowledge: the relevant ADRs were given to the model` for each scope. | The line starts with `PASS`. |
| 2 | Find the line `knowledge: no irrelevant OKF document given to the model` for each scope. | The line starts with `PASS`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
