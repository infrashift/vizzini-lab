---
id: "01a1cf70-a6d1-7a41-ab24-8bf4f7870bce"
title: "UAT-BOT-005: fix: a pushed fix resolves only its threads"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the bot resolves the thread of a fixed defect and keeps the other threads."
---

# UAT-BOT-005: fix: a pushed fix resolves only its threads

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that the bot resolves the thread of a fixed defect and keeps the other threads.

## Preconditions
- The TS-BOT run is complete.
- The fixture has a `fix/` overlay (csharp-seeded).

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the line `== push a fix to the PR` in the terminal output. | The line shows. |
| 2 | Find the section `fix` in `<run>/summary.md`. | Each item shows `[x]`. |
| 3 | Open `<run>/fix/bot.json`. | `mode` is `incremental`. `reviewed_files` has only `src/Services/PasswordHasher.cs`. |
| 4 | In the browser, open the MD5 thread on `PasswordHasher.cs`. | The status is *Resolved*. |
| 5 | Examine the last reply in that thread. | The reply starts with `Resolved by vizzini-bot: the code here changed`. |
| 6 | Examine the threads on the other files. | Their status is *Active*. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0005](/decisions/adr-0005-memory-legs-rerun-and-fix-on-the-same-pr--01a1cc2b9471.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
