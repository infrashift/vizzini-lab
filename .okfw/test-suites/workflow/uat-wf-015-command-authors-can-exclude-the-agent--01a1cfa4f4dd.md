---
id: "01a1cfa4-f4dd-737b-8163-a2b9a59be7eb"
title: "UAT-WF-015: --command-authors can exclude the agent"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "medium"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that a team can stop an agent from running `/vizzini` commands."
---

# UAT-WF-015: --command-authors can exclude the agent

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** Medium
- **Mode:** Automated, needs a second account
- **Requirement:** REQ-WF-09

## Objective
Make sure that a team can stop an agent from running `/vizzini` commands.

## Preconditions
- As UAT-WF-014.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Do UAT-WF-014 steps 1 and 2. | The identity section runs. |
| 2 | Find `UAT-WF-014 / 015` in `<run>/summary.md`. | The second item shows `[x]`: the agent's command is not answered. |

> **NOTE:** Without the second account, the run records BLOCKED.

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
