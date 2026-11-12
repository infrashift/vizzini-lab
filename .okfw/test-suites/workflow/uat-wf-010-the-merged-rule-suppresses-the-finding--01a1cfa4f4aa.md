---
id: "01a1cfa4-f4aa-7a00-85c9-c6e9aa116b3b"
title: "UAT-WF-010: The merged rule suppresses the finding"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that the rule takes effect only from the base branch, and stops the finding."
---

# UAT-WF-010: The merged rule suppresses the finding

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-07

## Objective
Make sure that the rule takes effect only from the base branch, and stops the finding.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-010 the rule, merged to the base` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/bot-r3/bot.json`. | `suppressed` has an entry for `wf/defend.go`. `suggested` is empty. |
| 3 | In the browser, examine `wf/defend.go`. | The file has one thread only. Its status is *By design*. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
