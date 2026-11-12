---
id: "01a1cf70-a6b0-7cba-80b1-9c8996f15749"
title: "UAT-BOT-001: deny: the committed default policy denies the PAT"
type: "Test Case"
tags:
  - "uat"
  - "test-case"
  - "ts-bot"
  - "high"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Make sure that the bot posts nothing when the policy does not list its identity."
---

# UAT-BOT-001: deny: the committed default policy denies the PAT

- **Suite:** [TS-BOT: Unattended bot](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md)
- **Priority:** High

## Objective
Make sure that the bot posts nothing when the policy does not list its identity.

## Preconditions
- The TS-BOT run is complete.

## Steps
| Step | Action | Expected result |
|---|---|---|
| 1 | Open `<run>/summary.md`. Find the section `deny: committed default policy`. | Each item shows `[x]`. |
| 2 | Open `<run>/deny/bot.code`. | The file contains `3`. |
| 3 | Open `<run>/deny/audit.jsonl`. | The file has one line. The line has `"decision":"deny"` and `MRM-002`. |
| 4 | Examine the PR in the browser. | The PR has no thread from the bot. |

## Pass criteria
The case passes when each step gives its expected result.

## Traces to
[ADR-0004](/decisions/adr-0004-the-unattended-leg-authorizes-by-policy-deny-first--01a1cbfe4052.md)

## Record
| Date | Tester | Build | Result | Notes |
|---|---|---|---|---|
| | | | | |
