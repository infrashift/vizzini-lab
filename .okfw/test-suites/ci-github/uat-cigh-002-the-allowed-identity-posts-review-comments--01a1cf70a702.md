---
id: "01a1cf70-a702-7b5b-84c4-5aaa222c02fa"
title: "UAT-CIGH-002: The allowed identity posts review comments"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-cigh"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the job posts when the base branch's policy lists `github-actions[bot]`."
---

# UAT-CIGH-002: The allowed identity posts review comments

- **Suite:** [TS-CIGH: GitHub Actions template](/test-suites/ci-github/ts-cigh-github-actions-template--01a1cf70a60f.md)
- **Priority:** High

## Objective
Make sure that the job posts when the base branch's policy lists `github-actions[bot]`.

## Preconditions
- The TS-CIGH run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `allow github-actions[bot] on the base branch, re-run`. | The section shows `run <id>: success`. |
| 2 | Find the section `run 2` in the checklist. | Each item shows `[x]`. |
| 3 | In the browser, open the PR's *Files changed* tab. | `calc/calc.go` has a review comment. |
| 4 | Examine the comment's author. | The author is `github-actions[bot]`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
