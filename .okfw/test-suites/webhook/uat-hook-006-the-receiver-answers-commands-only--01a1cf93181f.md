---
id: "01a1cf93-181f-7d41-93b3-a93a32ccb154"
title: "UAT-HOOK-006: The receiver answers commands only"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "high"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that a comment event does not start a review, a new finding or a resolution."
---

# UAT-HOOK-006: The receiver answers commands only

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-HOOK-06

## Objective
Make sure that a comment event does not start a review, a new finding or a resolution.

## Preconditions
- The TS-HOOK run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== UAT-HOOK-006 commands only`. | The line `bot_threads_after:` shows `<findings> 0`. |
| 2 | Compare `<findings>` with the setup line `<n> bot thread(s)`. | The two numbers are equal. |
| 3 | In the browser, examine the PR's threads. | No new finding thread shows. No bot thread is resolved. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
