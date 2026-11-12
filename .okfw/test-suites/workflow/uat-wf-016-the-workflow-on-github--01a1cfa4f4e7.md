---
id: "01a1cfa4-f4e7-7802-8d45-2819f62ba25c"
title: "UAT-WF-016: The workflow on GitHub"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "medium"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that reply, resolve and the findings view work on a GitHub PR."
---

# UAT-WF-016: The workflow on GitHub

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** Medium
- **Mode:** Pending automation
- **Requirement:** REQ-WF-10

## Objective
Make sure that reply, resolve and the findings view work on a GitHub PR.

## Preconditions
- A mrman release with ISSUE-028 pinned in Vizzini's CI templates.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make uat-ci-github` with a mrman release that includes ISSUE-028. | The run passes. |
| 2 | Examine the bot's thread after the second commit. | A fixed finding's thread is resolved by the bot. |

> **NOTE:** BLOCKED until the mrman release. The automation for the full workflow on GitHub is not written yet.

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
