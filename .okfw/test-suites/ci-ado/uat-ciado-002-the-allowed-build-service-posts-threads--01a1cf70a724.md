---
id: "01a1cf70-a724-75d1-a6d3-124fd7cdf7f9"
title: "UAT-CIADO-002: The allowed build service posts threads"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-ciado"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the build posts threads when the base branch's policy lists the build service."
---

# UAT-CIADO-002: The allowed build service posts threads

- **Suite:** [TS-CIADO: Azure Pipelines template](/test-suites/ci-ado/ts-ciado-azure-pipelines-template--01a1cf70a616.md)
- **Priority:** High

## Objective
Make sure that the build posts threads when the base branch's policy lists the build service.

## Preconditions
- The TS-CIADO run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `allow the identity on the base branch; a new commit on the PR`. | The section shows `build <id>: succeeded`. |
| 2 | Open the URL in `<run>/pr-url` in the browser. | The PR opens. Its status is *Abandoned*. |
| 3 | Find the thread on `calc/calc.go`. | The thread shows a finding. |
| 4 | Examine the thread's author. | The author is `<Project> Build Service (<org>)`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
