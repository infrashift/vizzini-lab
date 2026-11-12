---
id: "01a1cf70-a6b9-7a08-a7a5-d95d6aaf508e"
title: "UAT-BOT-002: allow: a policy that lists the identity posts one thread per finding"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the bot posts when the policy lists the forge-verified identity."
---

# UAT-BOT-002: allow: a policy that lists the identity posts one thread per finding

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that the bot posts when the policy lists the forge-verified identity.

## Preconditions
- The TS-BOT run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Find the section `allow` in `<run>/summary.md`. | Each item shows `[x]`. |
| 2 | Open `<run>/allow/bot.code`. | The file contains `0`. |
| 3 | Examine the PR in the browser. | The PR has one thread for each finding, on the fixture's changed files. |
| 4 | Examine the author of each thread. | The author is the PAT's user. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0004](/decisions/adr-0004-the-unattended-leg-authorizes-by-policy-deny-first--01a1cbfe4052.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
