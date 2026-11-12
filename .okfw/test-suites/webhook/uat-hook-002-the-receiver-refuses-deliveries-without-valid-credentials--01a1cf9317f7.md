---
id: "01a1cf93-17f7-743b-81a3-104852041d09"
title: "UAT-HOOK-002: The receiver refuses deliveries without valid credentials"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "high"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that only a delivery with the configured basic-auth credentials gets in."
---

# UAT-HOOK-002: The receiver refuses deliveries without valid credentials

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** High
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-HOOK-02

## Objective
Make sure that only a delivery with the configured basic-auth credentials gets in.

## Preconditions
- The TS-HOOK run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== UAT-HOOK-002 authentication`. | The section shows `auth_none: 401`. |
| 2 | Examine the next line. | The line shows `auth_wrong: 401`. |
| 3 | Examine the next line. | The line shows `auth_get: 405`. |
| 4 | Search `<run>/webhook.log` for `bad credentials`. | The log has two lines `delivery refused: bad credentials`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
