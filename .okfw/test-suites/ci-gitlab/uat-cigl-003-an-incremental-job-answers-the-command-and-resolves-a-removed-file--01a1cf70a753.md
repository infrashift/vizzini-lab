---
id: "01a1cf70-a753-7db6-9822-0d1ed65a4ab4"
title: "UAT-CIGL-003: An incremental job answers the command and resolves a removed file's finding"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-cigl"
  - "high"
created: "2026-11-12T05:07:09-06:00"
timestamp: "2026-11-12T07:42:33-06:00"
description: "Make sure that the job reviews only the changed file, answers the /vizzini command, and resolves the bot's discussion on a file the push removed."
---

# UAT-CIGL-003: An incremental job answers the command and resolves a removed file's finding

- **Suite:** [TS-CIGL: GitLab CI template](/test-suites/ci-gitlab/ts-cigl-gitlab-ci-template--01a1cf70a61d.md)
- **Priority:** High

## Objective
Make sure that the job reviews only the changed file, answers the /vizzini command, and resolves the bot's discussion on a file the push removed.

## Preconditions
- The TS-CIGL run is complete.
- The pinned mrman is v0.1.6 or later (reply and resolve on GitLab).

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `a /vizzini command and a second commit`. | The section shows `pipeline <id> for <sha> (job <id>): success`. |
| 2 | Search `<run>/job3.log` for `reviewing 1 file(s) changed since`. | The log has the line. |
| 3 | Search `<run>/job3.log` for `left the pull request`. | The log has `1 file(s) with threads left the pull request`. |
| 4 | Find the item `the /vizzini command was answered once in its discussion`. | The item shows `[x]`. |
| 5 | Find the item `the finding on the removed calc/extra.go`. | The item shows `[x]`: the bot user resolved its own discussion, with its reply. |
| 6 | Find the item `no discussion duplicated`. | The item shows `[x]`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ISSUE-028 (reply and resolve on GitLab); Vizzini `b7f55f9` (threads on files that left the pull request).

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
