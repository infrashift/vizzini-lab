---
id: "01a1cf93-1801-7661-918d-92bb903d440c"
title: "UAT-HOOK-003: The receiver ignores events it must not act on"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "high"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that the receiver acts only on qualifying `/vizzini` comments."
---

# UAT-HOOK-003: The receiver ignores events it must not act on

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-HOOK-03

## Objective
Make sure that the receiver acts only on qualifying `/vizzini` comments.

## Preconditions
- The TS-HOOK run is complete.

## Test data
- The real event for the first command, with one field changed for each case (`<run>/ev-*.json`).
- ADO's sample event, from Vizzini's `cmd/vizzini-webhook/testdata/`.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== UAT-HOOK-003 filtering`. | Each `ignore_…` line except the last starts with `200` and has `"accepted":false`. |
| 2 | Examine `ignore_plain`. | The reason is `no /vizzini command`. |
| 3 | Examine `ignore_bot`. | The reason is `written by the bot`. |
| 4 | Examine `ignore_other-repo`. | The reason is `repository not allowlisted`. |
| 5 | Examine `ignore_inactive`. | The reason is `pull request not active`. |
| 6 | Examine `ignore_push`. | The reason is `not a pull request comment event`. |
| 7 | Examine `ignore_ado_sample`. | The value is `400`. ADO's own sample uses a legacy host. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
