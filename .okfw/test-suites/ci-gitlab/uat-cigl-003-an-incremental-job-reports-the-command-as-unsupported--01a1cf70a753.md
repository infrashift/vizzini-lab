---
id: "01a1cf70-a753-7db6-9822-0d1ed65a4ab4"
title: "UAT-CIGL-003: An incremental job reports the command as unsupported"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-cigl"
  - "high"
created: "2026-11-12T05:07:09-06:00"
timestamp: "2026-11-12T05:07:09-06:00"
description: "Make sure that the job reviews only the changed file and continues when it cannot reply."
---

# UAT-CIGL-003: An incremental job reports the command as unsupported

- **Suite:** [TS-CIGL: GitLab CI template](/test-suites/ci-gitlab/ts-cigl-gitlab-ci-template--01a1cf70a61d.md)
- **Priority:** High

## Objective
Make sure that the job reviews only the changed file and continues when it cannot reply.

## Preconditions
- The TS-CIGL run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `a /vizzini command and a second commit`. | The section shows `pipeline <id> (job <id>): success`. |
| 2 | Search `<run>/job3.log` for `reviewing 1 file(s) changed since`. | The log has the line. |
| 3 | Search `<run>/job3.log` for `not supported on this forge`. | The log has `replying in threads from the command line is not supported on this forge`. |
| 4 | Search `<run>/job3.log` for `answered 0 of 1 commands`. | The log has the line. |
| 5 | Find the item `no discussion duplicated`. | The item shows `[x]`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ISSUE-002](/issues/issue-002-ci-template-coverage-gaps--01a1cf4af927.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
