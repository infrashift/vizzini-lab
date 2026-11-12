---
id: "01a1cf70-a72c-7cee-bd59-4c03a3d3a11f"
title: "UAT-CIADO-003: An incremental build answers a /vizzini command"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-ciado"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the build reviews only the changed file and answers the command once."
---

# UAT-CIADO-003: An incremental build answers a /vizzini command

- **Suite:** [TS-CIADO: Azure Pipelines template](/test-suites/ci-ado/ts-ciado-azure-pipelines-template--01a1cf70a616.md)
- **Priority:** High

## Objective
Make sure that the build reviews only the changed file and answers the command once.

## Preconditions
- The TS-CIADO run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `a /vizzini command and a second commit`. | The section shows `build <id>: succeeded`. |
| 2 | Search `<run>/build3.log` for `reviewing 1 file(s) changed since`. | The log has the line. |
| 3 | In the PR, open the thread on `calc/calc.go`. | The thread has `/vizzini explain What does this do?`. |
| 4 | Examine the replies. | The build service replies one time. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
