---
id: "01a1cfa4-f4c9-71b9-8cde-031a87303d68"
title: "UAT-WF-013: The agent cannot grant itself"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that mrman's interactive grant needs a person."
---

# UAT-WF-013: The agent cannot grant itself

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-08

## Objective
Make sure that mrman's interactive grant needs a person.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-013 the agent cannot grant itself` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/guard-auto.out`. | mrman refuses `--auto` without a terminal. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0002](/decisions/adr-0002-the-mrman-submit-grant-stays-a-human-step--01a1caeb8ce7.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
