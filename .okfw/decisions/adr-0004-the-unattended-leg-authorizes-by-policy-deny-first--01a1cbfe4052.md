---
id: "01a1cbfe-4052-760d-86cf-2678527ec882"
title: "ADR-0004: The unattended leg authorizes by policy, deny first"
type: "ADR"
tags:
  - "adr"
  - "mrman"
  - "security"
  - "automation"
created: "2026-11-11T13:03:19-06:00"
timestamp: "2026-11-11T13:03:19-06:00"
description: "uat/bot.sh proves vizzini-bot posts with no person only under a garmr policy: the committed default must deny the PAT's identity, then a run-local copy listing the identity mrman verified with the forge must allow."
---

# ADR-0004: The unattended leg authorizes by policy, deny first


**Status:** Accepted
**Date:** 2026-11-11
**Related:** [ADR-0002](./adr-0002-the-mrman-submit-grant-stays-a-human-step--01a1caeb8ce7.md) (the human grant, still how `make uat` posts); Vizzini ADR-0016 and ISSUE-024 (automation mode)

## Context
Vizzini ISSUE-024 slice 1 adds `vizzini-bot`. It reviews the CI checkout and posts through `mrman review submit --grant-policy DIR`. mrman submits with no person present only when garmr allows the event for the identity the forge reports for the token. The UAT has one ADO token, the owner's PAT, and no separate bot account.

## Decision
`uat/bot.sh` (`make uat-bot`) opens one PR and runs vizzini-bot twice, the way a CI step would. Each run gets its own mrman data directory.
1. **Deny:** run with mrman's committed default pack, which lists only `vizzini-bot`. It must deny on MRM-002 (identity), exit 3, and post nothing.
2. **Allow:** run with a copy of that pack in the run directory whose `_allowedIdentities` holds the identity mrman *verified with the forge* in the deny decision. The harness reads it from mrman's audit log, never from configuration. The copy stands in for a repository that lists its bot account. The run must exit 0 and post one thread per finding, each carrying the `<!-- vizzini:fp=… -->` marker.

ADR-0002 still holds: the harness never fakes mrman's TTY grant. The unattended path is a separate, policy-authorized mechanism.

## Consequences
- The generated policy contains the PAT owner's display name. It lives only under `.cache/runs/` and is never committed, and logs show only its first three characters.
- Running deny first proves the default is closed before anything can be posted.
- Each leg runs its own review: two reviews per run, about $0.11 each with Sonnet 5.5.
