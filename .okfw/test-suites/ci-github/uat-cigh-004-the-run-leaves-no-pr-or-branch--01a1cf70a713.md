---
id: "01a1cf70-a713-7967-be2d-6869d810c86d"
title: "UAT-CIGH-004: The run leaves no PR or branch"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-cigh"
  - "medium"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the test removes what it made on GitHub."
---

# UAT-CIGH-004: The run leaves no PR or branch

- **Suite:** [TS-CIGH: GitHub Actions template](/test-suites/ci-github/ts-cigh-github-actions-template--01a1cf70a60f.md)
- **Priority:** Medium

## Objective
Make sure that the test removes what it made on GitHub.

## Preconditions
- The TS-CIGH run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== close the PR, delete the branches`. | The output shows `PR <n> closed` and two `branch … deleted` lines. |
| 2 | Run `gh pr view <n> -R infrashift/vizzini-uat --json state`. | The state is `CLOSED`. |
| 3 | Run `gh api repos/infrashift/vizzini-uat/branches -q '.[].name'`. | No branch starts with `ci/`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
