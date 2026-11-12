---
id: "01a1cfa4-f508-783b-9be6-0e89a4f3a4bb"
title: "UAT-WF-019: Only a person merges"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that the branch policy needs a human approval."
---

# UAT-WF-019: Only a person merges

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Manual
- **Requirement:** REQ-WF-12

## Objective
Make sure that the branch policy needs a human approval.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | In ADO, open the base branch's policies. | A minimum number of reviewers is set, and the PR's author cannot approve. |
| 2 | Try to complete a PR with only the bot's and the agent's comments. | ADO refuses to complete the PR. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
