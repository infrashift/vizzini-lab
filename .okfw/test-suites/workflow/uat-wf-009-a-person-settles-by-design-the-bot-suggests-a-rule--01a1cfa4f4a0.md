---
id: "01a1cfa4-f4a0-7b9b-9b9e-e5e898180efb"
title: "UAT-WF-009: A person settles by design; the bot suggests a rule"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that a person's decision ends the dispute and gives one suggested rule."
---

# UAT-WF-009: A person settles by design; the bot suggests a rule

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-07

## Objective
Make sure that a person's decision ends the dispute and gives one suggested rule.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-009 a person settles: by design` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | In the browser, open the thread on `wf/defend.go`. | The status is *By design*. The bot replied once with a `suppressions:` rule. |
| 3 | Open `<run>/suggested-rule.yaml`. | The rule has `paths: ["wf/defend.go"]` and `categories: [Security]`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
