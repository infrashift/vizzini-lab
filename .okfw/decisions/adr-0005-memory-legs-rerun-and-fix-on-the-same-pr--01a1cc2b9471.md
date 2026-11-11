---
id: "01a1cc2b-9471-76bb-a28b-37597502dfa4"
title: "ADR-0005: Memory legs rerun and fix on the same PR"
type: "ADR"
tags:
  - "adr"
  - "automation"
  - "mrman"
created: "2026-11-11T13:52:50-06:00"
timestamp: "2026-11-11T13:52:50-06:00"
description: "uat/bot.sh proves thread memory on one live PR: a same-head rerun duplicates and resolves nothing, and after a pushed fix only the threads on the changed lines whose finding is gone are resolved."
---

# ADR-0005: Memory legs rerun and fix on the same PR


**Status:** Accepted
**Date:** 2026-11-11
**Related:** [ADR-0004](./adr-0004-the-unattended-leg-authorizes-by-policy-deny-first--01a1cbfe4052.md) (the deny and allow legs); Vizzini ISSUE-024 slice 2

## Context
In slice 2, vizzini-bot reads its own earlier threads back from the PR and decides three things:
- what not to post again;
- what to resolve: threads whose finding is gone and whose code changed;
- what to leave open: threads whose finding went unreported while the code stood still.

These behaviors only show across several runs on one PR, and against a live model that rewords findings between runs.

## Decision
After the allow leg, `uat/bot.sh` runs two more legs on the same PR, for any fixture that has a `fix/` overlay. Each leg is a separate bot run with its own mrman data directory, as a fresh CI job would be.
- **rerun:** the same head again. The bot must post no thread that raises what an open thread already raises (same file, category and overlapping lines), and must resolve nothing.
- **fix:** the overlay is committed and pushed to the PR's branch (`ado.sh push`), and the SARIF is rebuilt at the new head. The bot must:
  - resolve threads only on the changed file, each with status fixed and the bot's reply;
  - resolve the thread about the fixed defect (MD5 in csharp-seeded);
  - duplicate nothing on unchanged files.

New threads that come from model variance, and threads kept open, are reported as metrics, not failures.

## Consequences
- A run makes four reviews, about $0.22 with Sonnet 5.5.
- The SARIF has to be rebuilt after the fix. Otherwise its diagnostics would point at lines that no longer hold the code they describe, and the model would report the fixed defect again.

## Update 2026-11-11: incremental review (Vizzini ISSUE-024 slice 3)
The bot now reviews only what changed since the last reviewed head, so the legs change as follows:
- **New `idle` leg:** the same head, run incrementally. It must make no review at all.
- **`rerun` now runs with `--full`:** that keeps testing duplicate detection under rewording and variance.
- **`fix` runs incrementally:** it must review only the changed file and carry every open thread on the other files.
