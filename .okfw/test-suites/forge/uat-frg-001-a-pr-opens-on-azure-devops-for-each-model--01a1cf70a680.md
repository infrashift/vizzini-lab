---
id: "01a1cf70-a680-7e0b-80f2-ff3610043198"
title: "UAT-FRG-001: A PR opens on Azure DevOps for each model"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-frg"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the run opens a real ADO PR for the fixture."
---

# UAT-FRG-001: A PR opens on Azure DevOps for each model

- **Suite:** [TS-FRG: Forge and mrman (attended)](/test-suites/forge/ts-frg-forge-and-mrman-attended--01a1cf70a603.md)
- **Priority:** High

## Objective
Make sure that the run opens a real ADO PR for the fixture.

## Preconditions
- The TS-FRG run is in progress.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `PR: https://dev.azure.com/…/pullrequest/<id>` for the fixture and model. | The line shows a PR URL. |
| 2 | Open the PR URL in the browser. | The PR title starts with `vizzini-uat`. |
| 3 | Examine the target branch. | The target branch is `uat/<fixture>/base`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
