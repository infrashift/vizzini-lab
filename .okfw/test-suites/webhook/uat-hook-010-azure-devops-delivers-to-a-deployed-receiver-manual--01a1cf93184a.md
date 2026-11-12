---
id: "01a1cf93-184a-751e-9840-865a42cf3ded"
title: "UAT-HOOK-010: Azure DevOps delivers to a deployed receiver (manual)"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-hook"
  - "medium"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "Make sure that a real ADO service hook reaches a receiver that an admin deployed with the runbook."
---

# UAT-HOOK-010: Azure DevOps delivers to a deployed receiver (manual)

- **Suite:** [TS-HOOK: Webhook receiver (experimental)](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md)
- **Priority:** Medium
- **Mode:** Manual
- **Requirement:** REQ-HOOK-10

## Objective
Make sure that a real ADO service hook reaches a receiver that an admin deployed with the runbook.

## Preconditions
- A Linux host with a public DNS name and HTTPS.
- A dedicated ADO bot account and its PAT.
- A Project Administrator for the subscription.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Deploy the receiver with steps 1 to 6 of Vizzini's `deploy/webhook/README.md`. | `https://<host>/healthz` gives `ok` from outside the network. |
| 2 | In ADO, open *Project settings* > *Service hooks*. Select the subscription. Click *Test*. | The test result shows status `400` or `200`. It does not show `401`. |
| 3 | In an open PR of the repository, write `/vizzini explain What does this do?` on a changed line. | Within 2 minutes, the bot account replies in the thread. |
| 4 | Examine the subscription's *History*. | The delivery for the comment shows `202`. |
| 5 | Run `journalctl -u vizzini-webhook`. | The log shows `delivery accepted`, `job started` and `job done`. |
| 6 | Delete the subscription. Stop the service. | No more deliveries occur. |

> **NOTE:** This case is manual. Azure DevOps cannot deliver to this machine. Without a public host, record BLOCKED.

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
Vizzini ADR-0022

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
