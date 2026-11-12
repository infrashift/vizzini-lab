---
id: "01a1cf93-1815-76df-8a37-c7bf0352d12e"
title: "UAT-HOOK-005: Deliveries fold together and each command is answered once"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "high"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that repeated deliveries do not give repeated answers."
---

# UAT-HOOK-005: Deliveries fold together and each command is answered once

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-HOOK-05

## Objective
Make sure that repeated deliveries do not give repeated answers.

## Preconditions
- The TS-HOOK run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== UAT-HOOK-005 coalescing, and each command answered once`. | The line `deliver2_1:` shows `"queue":"queued"`. |
| 2 | Examine `deliver2_2` and `deliver2_3`. | Each shows `"queue":"coalesced"` or `"queue":"again"`. |
| 3 | Examine `replies_c2`. | The value is `1`. |
| 4 | Examine `replies_c1`. | The value is `1`. The first command did not get a second answer. |
| 5 | In the browser, open the thread. | Each command has one reply only. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
