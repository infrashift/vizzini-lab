---
id: "01a1cf70-a6fa-7a54-9242-5e9247519c23"
title: "UAT-CIGH-001: The first run is denied and names the identity"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-cigh"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the first run posts nothing and shows the identity to allow."
---

# UAT-CIGH-001: The first run is denied and names the identity

- **Suite:** [TS-CIGH: GitHub Actions template](/test-suites/ci-github/ts-cigh-github-actions-template--01a1cf70a60f.md)
- **Priority:** High

## Objective
Make sure that the first run posts nothing and shows the identity to allow.

## Preconditions
- The TS-CIGH run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== run 1: the policy lists no identity`. | The section shows `run <id>: failure`. |
| 2 | Find the line `GITHUB_TOKEN posts as: github-actions[bot]`. | The line shows. |
| 3 | Open `<run>/run1.log`. | The log has `mrman: authorization:` with `"decision":"deny"` and `MRM-002`. |
| 4 | Search `<run>/run1.log` for `install: done`. | The log has `install: done` and `mrman version v0.1.5`. |
| 5 | In the browser, open the PR. Open the *Checks* tab. | The first `vizzini-bot` attempt shows *Failure*. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0006](/decisions/adr-0006-ci-template-tests-run-stubllm-inside-the-job--01a1cf4af8c2.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
