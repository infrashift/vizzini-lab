---
id: "01a1cfa4-f4fd-7dc1-9bac-2f4ba360e1bf"
title: "UAT-WF-018: Fix rounds and cost are bounded"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "low"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that a runaway fix loop stops."
---

# UAT-WF-018: Fix rounds and cost are bounded

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** Low
- **Mode:** Manual
- **Requirement:** REQ-WF-11

## Objective
Make sure that a runaway fix loop stops.

## Preconditions
- A developer agent product, which this project does not build.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Examine the agent's configuration. | It sets a maximum number of fix rounds. |
| 2 | Examine the LiteLLM key of the bot. | The key has a budget. |

> **NOTE:** BLOCKED: the round limit belongs to the agent, not to Vizzini or mrman. Record the agent's setting.

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
