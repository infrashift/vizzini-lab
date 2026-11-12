---
id: "01a1cfa4-f46e-7b64-b135-86a3e2f44039"
title: "UAT-WF-004: The agent fixes; the bot resolves"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that an agent can fix from the findings view, and that only the bot closes the thread."
---

# UAT-WF-004: The agent fixes; the bot resolves

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-03

## Objective
Make sure that an agent can fix from the findings view, and that only the bot closes the thread.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-004 the agent fixes, located by the findings view` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, open the thread on `wf/agent.go`. | The status is *Resolved*. The only reply is the bot's. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
