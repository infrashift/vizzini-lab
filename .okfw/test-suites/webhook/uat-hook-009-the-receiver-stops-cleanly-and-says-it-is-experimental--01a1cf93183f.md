---
id: "01a1cf93-183f-789c-aac5-455c878e8e8d"
title: "UAT-HOOK-009: The receiver stops cleanly and says it is experimental"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "medium"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that a stop does not lose a running job and that the receiver shows its status."
---

# UAT-HOOK-009: The receiver stops cleanly and says it is experimental

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** Medium
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-HOOK-09

## Objective
Make sure that a stop does not lose a running job and that the receiver shows its status.

## Preconditions
- The TS-HOOK run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== UAT-HOOK-009 a clean shutdown`. | The line `shutdown_exit:` shows `0`. |
| 2 | Examine `shutdown_logged`. | The value is more than 0. |
| 3 | Open `<run>/webhook.log`. Examine the first line. | The line has `vizzini-webhook is EXPERIMENTAL`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
