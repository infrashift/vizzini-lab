---
id: "01a1cf93-1834-7d3d-9690-120e17bfef0d"
title: "UAT-HOOK-008: The logs hold no secret and no identity"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "high"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that the receiver does not write a token, the password or a person's identity to its logs."
---

# UAT-HOOK-008: The logs hold no secret and no identity

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-HOOK-08

## Objective
Make sure that the receiver does not write a token, the password or a person's identity to its logs.

## Preconditions
- The TS-HOOK run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== UAT-HOOK-008 no secret or identity in the logs`. | The line `log_has_pat:` shows `0`. |
| 2 | Examine `log_has_secret`. | The value is `0`. |
| 3 | Examine `log_has_requester`. | The value is `0`. |
| 4 | Search `<run>/webhook.log` for `requester`. | Each value has three characters and `…`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022, [Credential handling](/architecture/credential-handling--01a1cf4af8b1.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
