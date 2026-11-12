---
id: "01a1cfa4-f4b4-79a5-a155-adb0e947e237"
title: "UAT-WF-011: The agent cannot resolve under its own policy"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that the agent's policy (reply only) stops a resolve."
---

# UAT-WF-011: The agent cannot resolve under its own policy

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-08

## Objective
Make sure that the agent's policy (reply only) stops a resolve.

## Preconditions
- The TS-WF run is complete.

## Test data
- `<run>/policy-agent/mrman`: `_allowedEvents: ["reply"]`.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-011 the agent cannot resolve (its policy has no resolve)` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/guard-resolve.json`. | The deny decision has event `resolve` and `failed: ["MRM-001"]` only: the event, not a missing run id or identity. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
