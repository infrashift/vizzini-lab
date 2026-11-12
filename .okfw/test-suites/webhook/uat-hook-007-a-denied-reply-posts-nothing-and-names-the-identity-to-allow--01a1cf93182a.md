---
id: "01a1cf93-182a-7389-b5a3-85977dd32e0e"
title: "UAT-HOOK-007: A denied reply posts nothing and names the identity to allow"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "high"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that the base branch's grant policy controls the receiver, and that a denial tells the admin what to change."
---

# UAT-HOOK-007: A denied reply posts nothing and names the identity to allow

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-HOOK-07

## Objective
Make sure that the base branch's grant policy controls the receiver, and that a denial tells the admin what to change.

## Preconditions
- The TS-HOOK run is complete.

## Test data
- Receiver 1 uses a run-local policy that lists the PAT's identity.
- Receiver 2 uses mrman's committed policy. It lists only `vizzini-bot`.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== UAT-HOOK-007 a denied reply names the identity to allow`. | The line `deliver3_deny:` shows `202`. |
| 2 | Examine `deny_logged` and `deny_names_identity`. | `deny_logged` is more than 0. `deny_names_identity` is `yes`. |
| 3 | Open `<run>/webhook-deny.log`. Find `grant policy denied the reply`. | The line has `add "<identity>" to _allowedIdentities`. |
| 4 | Examine `replies_c3_denied`. | The value is `0`. |
| 5 | Examine `deliver3_allow` and `reply3_seconds`. | `deliver3_allow` is `202`. `reply3_seconds` is a number. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022, [ADR-0004](/decisions/adr-0004-the-unattended-leg-authorizes-by-policy-deny-first--01a1cbfe4052.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
