---
id: "01a1cf93-180b-7a23-8276-bcb8f61d4640"
title: "UAT-HOOK-004: A command is answered with no push"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "high"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that a `/vizzini` command gets an answer in its thread soon after the delivery, and that no push is necessary."
---

# UAT-HOOK-004: A command is answered with no push

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-HOOK-04

## Objective
Make sure that a `/vizzini` command gets an answer in its thread soon after the delivery, and that no push is necessary.

## Preconditions
- The TS-HOOK run is complete.

## Test data
- The command `/vizzini explain What does this line do?` in a bot thread.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== UAT-HOOK-004 an immediate answer, with no push`. | The line `deliver1:` starts with `202` and has `"queue":"queued"`. |
| 2 | Examine the line `reply1_seconds:`. | The value is a number of 120 or less. |
| 3 | Examine the line `head_unchanged:`. | The value is `yes`. |
| 4 | Open the PR (`<run>/pr-url`) in the browser. Open the thread with `/vizzini explain What does this line do?`. | The thread has one reply from the PAT's user under the command. |
| 5 | Search `<run>/webhook.log` for `job done`. | A line shows `"answered":["<comment id>"]`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
