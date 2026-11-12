---
id: "01a1cf70-a699-7248-94a9-09f8f4301190"
title: "UAT-FRG-004: The tester promotes a finding to a draft comment"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-frg"
  - "medium"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that a person can turn a Vizzini finding into a review comment."
---

# UAT-FRG-004: The tester promotes a finding to a draft comment

- **Suite:** [TS-FRG: Forge and mrman (attended)](/test-suites/forge/ts-frg-forge-and-mrman-attended--01a1cf70a603.md)
- **Priority:** Medium

## Objective
Make sure that a person can turn a Vizzini finding into a review comment.

## Preconditions
- UAT-FRG-003 is complete. mrman is open.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | In the mrman TUI, select a finding. | mrman shows the finding. |
| 2 | Push `p`. | mrman opens a draft comment with the finding's title and text. |
| 3 | Push `Enter`. | mrman saves the draft. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
