---
id: "01a1cf93-17ec-7d3d-8ca9-08c0735adb7e"
title: "UAT-HOOK-001: The receiver answers its health check"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "medium"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that the receiver starts and gives its health."
---

# UAT-HOOK-001: The receiver answers its health check

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** Medium
- **Mode:** Automated, tester-verified
- **Requirement:** REQ-HOOK-01

## Objective
Make sure that the receiver starts and gives its health.

## Preconditions
- The TS-HOOK run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `== UAT-HOOK-001 health` in the output. | The section shows `health: 200`. |
| 2 | Open `<run>/summary.md`. Find the section `UAT-HOOK-001 health`. | Each item shows `[x]`. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
