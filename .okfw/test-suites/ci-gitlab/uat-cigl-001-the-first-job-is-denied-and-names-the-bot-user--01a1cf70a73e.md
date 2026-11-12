---
id: "01a1cf70-a73e-7ca8-8b00-be571c2510bf"
title: "UAT-CIGL-001: The first job is denied and names the bot user"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-cigl"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the first job posts nothing and shows the token's bot user."
---

# UAT-CIGL-001: The first job is denied and names the bot user

- **Suite:** [TS-CIGL: GitLab CI template](/test-suites/ci-gitlab/ts-cigl-gitlab-ci-template--01a1cf70a61d.md)
- **Priority:** High

## Objective
Make sure that the first job posts nothing and shows the token's bot user.

## Preconditions
- The TS-CIGL run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `project <id>; access token (Reporter, api) for bot user <id>`. | The line shows. |
| 2 | Find the section `== MR: the policy lists no identity`. | The section shows `pipeline <id> for <sha> (job <id>): failed`. |
| 3 | Find the line `VIZZINI_GITLAB_TOKEN posts as: project_<n>_bot_<hash>`. | The line shows. |
| 4 | Open `<run>/job1.log`. | The log has `ERROR: Job failed: exit code 3`. |
| 5 | Search `<run>/job1.log` for `MRM-002`. | The log has `"decision":"deny"` and `MRM-002`. |
| 6 | Search `<run>/job1.log` for `!= gitlab.com`. | The log shows the template's self-managed host step. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0008](/decisions/adr-0008-gitlab-ci-runs-on-a-throwaway-self-managed-gitlab-ce-in-podman--01a1cf4af8e3.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
