---
id: "01a1cf70-a671-70c3-b272-68b69576e3c5"
title: "UAT-REV-010: A large commit is reviewed in more than one chunk"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-rev"
  - "medium"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that Vizzini splits a large real-world diff into chunks."
---

# UAT-REV-010: A large commit is reviewed in more than one chunk

- **Suite:** [TS-REV: Live review](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md)
- **Priority:** Medium

## Objective
Make sure that Vizzini splits a large real-world diff into chunks.

## Preconditions
- The TS-REV run is complete without `--no-oss`.

## Test data
- `fixtures/csharp-oss.txt`: `large-serilog-failure-listeners` at serilog `3da0979`.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the lines for the scope that contains `large-serilog-failure-listeners`. | The lines start with `PASS`. |
| 2 | Find the line `large commit is reviewed in more than one chunk`. | The line starts with `PASS`. |

## Pass criteria
The case passes when each step gives its expected result.

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
