---
id: "01a1cfa4-f48c-764f-99b2-4d819e2b431e"
title: "UAT-WF-007: Defend: the finding stands and stays open"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that an argument alone does not close a finding, and that the bot answers the dispute once."
---

# UAT-WF-007: Defend: the finding stands and stays open

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-05

## Objective
Make sure that an argument alone does not close a finding, and that the bot answers the dispute once.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-007 defend: the argument, and a finding that stands` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, open the thread on `wf/defend.go`. | The thread has the agent's argument and `/vizzini reconsider …`. |
| 3 | Examine the bot's reply. | The reply starts with `**The finding stands.**`. The thread was *Active* until UAT-WF-009. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
