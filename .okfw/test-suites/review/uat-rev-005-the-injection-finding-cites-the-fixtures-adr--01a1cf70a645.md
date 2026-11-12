---
id: "01a1cf70-a645-7524-8247-d06a8f669cd7"
title: "UAT-REV-005: The injection finding cites the fixture's ADR"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the review grounds the injection finding in the fixture's knowledge base."
---

# UAT-REV-005: The injection finding cites the fixture's ADR

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** High

## Objective
Make sure that the review grounds the injection finding in the fixture's knowledge base.

## Preconditions
- The TS-REV run is complete.

## Test data
- The data-access ADR in `fixtures/csharp-seeded/base/.okfw/`.
- The shell-command ADR in `fixtures/ts-seeded/base/.okfw/`.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `sqli: a finding in its file cites ADR 01a1cae2-6830…` for each model. | The line starts with `PASS`. |
| 2 | Find the line `cmdinj: a finding in its file cites ADR 01a1cb22-3889…` for each model. | The line starts with `PASS`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
