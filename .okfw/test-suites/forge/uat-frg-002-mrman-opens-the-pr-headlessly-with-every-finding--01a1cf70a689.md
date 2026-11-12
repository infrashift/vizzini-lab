---
id: "01a1cf70-a689-763f-8465-141a35e2caef"
title: "UAT-FRG-002: mrman opens the PR headlessly with every finding"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-frg"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that mrman reads the Vizzini report and carries each finding and the risk score."
---

# UAT-FRG-002: mrman opens the PR headlessly with every finding

- **Suite:** [TS-FRG: Forge and mrman (attended)](/test-suites/forge/ts-frg-forge-and-mrman-attended--01a1cf70a603.md)
- **Priority:** High

## Objective
Make sure that mrman reads the Vizzini report and carries each finding and the risk score.

## Preconditions
- The TS-FRG run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `mrman session: <slug>`. | The line shows a session slug. |
| 2 | Find the line `mrman opened the PR headlessly` for the scope. | The line starts with `PASS`. |
| 3 | Find the line `mrman session carries every Vizzini finding`. | The line starts with `PASS`. |
| 4 | Find the line `mrman shows the report's risk score`. | The line starts with `PASS`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
