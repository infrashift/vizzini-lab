---
id: "01a1cfa4-f4d3-71a9-bcb4-dca8ca0d2394"
title: "UAT-WF-014: With its own account, the agent cannot resolve the bot's threads"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that mrman's own-thread rule holds even when the agent's policy allows resolve."
---

# UAT-WF-014: With its own account, the agent cannot resolve the bot's threads

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, needs a second account
- **Requirement:** REQ-WF-09

## Objective
Make sure that mrman's own-thread rule holds even when the agent's policy allows resolve.

## Preconditions
- A second ADO account (the developer's) with *Code (Read & Write)* on the repository.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Put a second ADO account's PAT in `~/.config/vizzini-lab/ado-dev.pat` (mode 0600). | The file exists. |
| 2 | Run `make uat-workflow`. | The output shows `== identity separation` without `BLOCKED`. |
| 3 | Find `UAT-WF-014 / 015` in `<run>/summary.md`. | The first item shows `[x]`. |

> **NOTE:** Without the second account, the run records BLOCKED.

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
