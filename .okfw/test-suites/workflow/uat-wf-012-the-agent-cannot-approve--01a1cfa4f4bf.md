---
id: "01a1cfa4-f4bf-70d4-a8cc-2d446ac7f24a"
title: "UAT-WF-012: The agent cannot approve"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that the agent cannot approve the PR."
---

# UAT-WF-012: The agent cannot approve

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-08

## Objective
Make sure that the agent cannot approve the PR.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-012 the agent cannot approve` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/guard-approve.json`. | The deny decision has event `approve` and `failed: ["MRM-001"]` only. |
| 3 | In the browser, examine the PR's reviewers. | No reviewer has *Approved*. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
