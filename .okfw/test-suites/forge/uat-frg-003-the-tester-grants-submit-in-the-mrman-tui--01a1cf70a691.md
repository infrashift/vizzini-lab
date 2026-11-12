---
id: "01a1cf70-a691-7270-902a-3d059681df44"
title: "UAT-FRG-003: The tester grants submit in the mrman TUI"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-frg"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that a person, not the harness, grants mrman's submit."
---

# UAT-FRG-003: The tester grants submit in the mrman TUI

- **Suite:** [TS-FRG: Forge and mrman (attended)](/test-suites/forge/ts-frg-forge-and-mrman-attended--01a1cf70a603.md)
- **Priority:** High

## Objective
Make sure that a person, not the harness, grants mrman's submit.

## Preconditions
- The TS-FRG run shows the `YOUR TURN` box.
- `GRANT_TIMEOUT` (default 1200 s) has not expired.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Wait for the box `YOUR TURN (<fixture> / <model>)`. | The box shows an `mrman pr … --auto` command. |
| 2 | Copy the command to the second terminal. | The command is in the second terminal. |
| 3 | Run the command. | The mrman TUI opens on the PR. |
| 4 | Examine the header. | The header shows the Vizzini score and the finding count. |
| 5 | Push `F`. | mrman shows the list of findings, with severity and file. |
| 6 | Examine the first terminal. | The line `grant seen after Ns; posting findings` shows. |

> **NOTE:** Do not close mrman until UAT-FRG-005 is complete.

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0002](/decisions/adr-0002-the-mrman-submit-grant-stays-a-human-step--01a1caeb8ce7.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
