---
id: "01a1cfa4-f45a-7c7e-92e4-abcc5738d8de"
title: "UAT-WF-002: The agent reads the findings view"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-wf"
  - "high"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "Make sure that an agent gets each finding as structured fields."
---

# UAT-WF-002: The agent reads the findings view

- **Suite:** [TS-WF: Full review workflow](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-WF-02

## Objective
Make sure that an agent gets each finding as structured fields.

## Preconditions
- The TS-WF run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `## UAT-WF-002 the agent reads the findings view` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/findings-r0.json`. | `findings` has five objects. `malformed` is empty. |
| 3 | Examine one object. | It has `thread`, `path`, `line`, `status` `open`, `severity` `Major`, `category` `Security`, `title`, `body`, `fingerprint` and `posted_start_line` `5`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ISSUE-027

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
