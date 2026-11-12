---
id: "01a1cf4a-f917-717c-8a42-f086ce3bab30"
title: "ADR-0011: Retry only what cannot have been applied"
type: "ADR"
tags:
  - "adr"
  - "reliability"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Network retries in the harness are limited to failures that happen before a request reaches the server, or to calls whose failure proves nothing was posted, so a retry can never post twice."
---

# ADR-0011: Retry only what cannot have been applied

**Status:** Accepted
**Date:** 2026-11-11
**Related:** [troubleshooting](/runbooks/runbook-troubleshooting--01a1cf4af84b.md)

## Context
- **Transient errors happen.** dev.azure.com occasionally resets a TLS handshake, and an early full run lost a submit to one.
- **A blind retry can double-post.** If the first attempt reached the server, a retried post creates duplicate threads, which the tests would then flag as the bot's fault.

## Decision
- **Retry only provable non-delivery.**
  - Raw REST calls (`api()` in `uat/ci-ado.sh`) retry only on curl exits 6, 7 and 35: DNS, connect and TLS handshake. In each case the request never reached the server.
  - `forge.sh` retries `mrman review submit` only when mrman reports a network error, which means nothing was posted.
  - Both retry at most three times, with backoff.
- **Reads and polls may retry freely**, and poll loops tolerate a failed iteration.

## Consequences
- **A transient reset no longer fails a run, and it cannot duplicate a thread.**
- **An error after the request was sent still fails the run,** for a person to inspect.
