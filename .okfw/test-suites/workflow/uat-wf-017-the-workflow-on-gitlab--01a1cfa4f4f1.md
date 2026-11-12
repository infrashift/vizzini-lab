---
id: "01a1cfa4-f4f1-7a9a-8387-4ec62d4d4dfd"
title: "UAT-WF-017: The workflow on GitLab"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "medium"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that reply, resolve and the findings view work on a GitLab MR."
---

# UAT-WF-017: The workflow on GitLab

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** Medium
- **Mode:** Pending automation
- **Requirement:** REQ-WF-10

## Objective
Make sure that reply, resolve and the findings view work on a GitLab MR.

## Preconditions
- As UAT-WF-016.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make uat-ci-gitlab` with a mrman release that includes ISSUE-028. | The `/vizzini` command is answered, not reported unsupported. |

> **NOTE:** BLOCKED until the mrman release.

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0023

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
