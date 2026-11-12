---
id: "01a1cf70-a748-7d61-9ad6-eb21c4614bb9"
title: "UAT-CIGL-002: The allowed bot user posts a discussion"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-cigl"
  - "high"
created: "2026-11-12T05:07:09-06:00"
timestamp: "2026-11-12T05:07:09-06:00"
description: "Make sure that a Reporter project access token can post a discussion when the policy lists its bot user."
---

# UAT-CIGL-002: The allowed bot user posts a discussion

- **Suite:** [TS-CIGL: GitLab CI template](/test-suites/ci-gitlab/ts-cigl-gitlab-ci-template--01a1cf70a61d.md)
- **Priority:** High

## Objective
Make sure that a Reporter project access token can post a discussion when the policy lists its bot user.

## Preconditions
- The TS-CIGL run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `allow the identity on the base branch; a new commit on the MR`. | The section shows `pipeline <id> for <sha> (job <id>): success`. |
| 2 | Run `grep -o '"username":"[^"]*"' <run>/discussions2.json`. | The output shows the bot user from UAT-CIGL-001. |
| 3 | Run `grep -o '"new_path":"[^"]*"' <run>/discussions2.json`. | The output shows `calc/calc.go`. |
| 4 | Find the section `job 2` in the checklist. | Each item shows `[x]`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
