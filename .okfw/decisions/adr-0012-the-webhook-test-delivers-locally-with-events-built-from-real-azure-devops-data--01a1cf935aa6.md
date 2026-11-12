---
id: "01a1cf93-5aa6-7100-9ffe-5df5b3809a1e"
title: "ADR-0012: The webhook test delivers locally, with events built from real Azure DevOps data"
type: "ADR"
tags:
  - "adr"
  - "webhook"
  - "experimental"
created: "2026-11-12T05:45:03-06:00"
timestamp: "2026-11-12T05:45:03-06:00"
description: "uat/webhook.sh runs vizzini-webhook on 127.0.0.1 and posts to it events in the exact service-hook shape, built from the real comment and PR, because Azure DevOps delivers only to public HTTPS endpoints; a delivery by ADO itself stays a manual case."
---

# ADR-0012: The webhook test delivers locally, with events built from real Azure DevOps data

**Status:** Accepted
**Date:** 2026-11-12
**Related:** [TS-HOOK](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md); Vizzini ADR-0022, ISSUE-026

## Context
vizzini-webhook (experimental) answers `/vizzini` commands when Azure DevOps posts a comment event to it. ADO delivers service hooks only to public HTTPS endpoints. It refuses localhost and private addresses. This machine has no public endpoint, and opening one, through a tunnel or a cloud host, would expose it and is a decision for its owner.

## Decision
- **Local delivery:** `uat/webhook.sh` runs the receiver on 127.0.0.1 and posts each event to it itself.
- **Real data:** each event is built from the real comment and the real PR, fetched over REST, in the exact shape of ADO's *Pull request commented on* event: resource version 2.0, resource details All. ADO's own test-notification sample confirmed that shape and is kept as the receiver's unit-test data.
- **Real everything after:** the receiver's clone of the ADO repository, `vizzini-bot --commands-only`, mrman, garmr, and the reply on the PR.
- **Two receivers:** one under a policy that lists the PAT's identity, and one under mrman's committed policy. They show the answer and the denial on the same PR.
- **ADO's own delivery** is the manual case UAT-HOOK-010. It is done on a deployed receiver with Vizzini's admin runbook, and it is BLOCKED where no public host exists.

## Consequences
- **No ADO service-hook configuration is tested automatically.** That covers the subscription, its filters, its retries and its basic-auth header. UAT-HOOK-010 covers them by hand.
- **The run needs no exposure of this machine and no subscription in the organization.**
