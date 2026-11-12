---
id: "01a1cf70-a6a9-71ce-9737-8afce0940f88"
title: "UAT-FRG-006: Cleanup removes the PRs and branches"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-frg"
  - "medium"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the forge leg leaves no open PR."
---

# UAT-FRG-006: Cleanup removes the PRs and branches

- **Suite:** [TS-FRG: Forge and mrman (attended)](/test-suites/forge/ts-frg-forge-and-mrman-attended--01a1cf70a603.md)
- **Priority:** Medium

## Objective
Make sure that the forge leg leaves no open PR.

## Preconditions
- The TS-FRG run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make ado-down`. | The output shows `ado: abandoned PR <id>` for each UAT PR. |
| 2 | Examine the output. | The output shows `ado: deleted refs/heads/uat/…` for each branch. |
| 3 | Refresh a UAT PR in the browser. | The PR status is *Abandoned*. |

> **CAUTION:** `make ado-down` deletes every `uat/*` branch on the repository, not only this run's.

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
