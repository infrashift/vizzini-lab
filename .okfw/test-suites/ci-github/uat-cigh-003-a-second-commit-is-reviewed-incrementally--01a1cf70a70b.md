---
id: "01a1cf70-a70b-71ff-98ce-06d114138728"
title: "UAT-CIGH-003: A second commit is reviewed incrementally"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-cigh"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the job reviews only the changed file and posts no duplicate."
---

# UAT-CIGH-003: A second commit is reviewed incrementally

- **Suite:** [TS-CIGH: GitHub Actions template](/test-suites/ci-github/ts-cigh-github-actions-template--01a1cf70a60f.md)
- **Priority:** High

## Objective
Make sure that the job reviews only the changed file and posts no duplicate.

## Preconditions
- The TS-CIGH run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== run 3: a second commit`. | The section shows `run <id>: success`. |
| 2 | Search `<run>/run3.log` for `reviewing 1 file(s) changed since`. | The log has the line. |
| 3 | Find the item `no comment duplicated`. | The item shows `[x]`. The comment counts are equal. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
