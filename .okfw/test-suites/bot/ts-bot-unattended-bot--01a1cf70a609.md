---
id: "01a1cf70-a609-7638-9686-91011641532c"
title: "TS-BOT: Unattended bot"
type: "Test Suite"
tags:
  - "uat"
  - "test-suite"
  - "ts-bot"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "vizzini-bot on one Azure DevOps PR with no person: deny, allow, idle, rerun, fix, command, command-again, dismiss and suppress."
---

# TS-BOT: Unattended bot

- **Command:** `make uat-bot-stub` (or make uat-bot for live models)
- **Tokens:** No with `uat-bot-stub`. Yes with `uat-bot`.
- **Attended:** No
- **Plan:** [UAT test plan](/test-suites/uat-test-plan--01a1cf70a5f6.md)

## Scope
vizzini-bot posts, deduplicates, resolves, answers `/vizzini` commands and applies suppression rules, under a garmr policy.

## Remote changes
One ADO PR on the scratch repository, with threads and replies. The PR stays open.

## Preconditions
- The [first-time setup](/runbooks/runbook-first-time-setup--01a1cf4a8f24.md) is complete.
- `make ado-check` passes.
- For `make uat-bot` only: `make litellm-up` is complete.
- You have a web browser signed in to Azure DevOps.

## Execution
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make uat-bot-stub`. | The first line of output is `run: <run>`. |
| 2 | Write down the `<run>` path. | You have the run directory for all cases in this suite. |
| 3 | Wait for the run to stop. | The last line is `result: PASS` or `result: FAIL`. |
| 4 | Open the URL in `<run>/pr-url` in the browser. | The ADO PR opens. Use it for the cases in this suite. |

## Test cases
| ID | Title | Priority |
|---|---|---|
| [UAT-BOT-001](/test-suites/bot/uat-bot-001-deny-the-committed-default-policy-denies-the-pat--01a1cf70a6b0.md) | deny: the committed default policy denies the PAT | High |
| [UAT-BOT-002](/test-suites/bot/uat-bot-002-allow-a-policy-that-lists-the-identity-posts-one-thread-per-finding--01a1cf70a6b9.md) | allow: a policy that lists the identity posts one thread per finding | High |
| [UAT-BOT-003](/test-suites/bot/uat-bot-003-idle-the-same-head-gets-no-review--01a1cf70a6c1.md) | idle: the same head gets no review | High |
| [UAT-BOT-004](/test-suites/bot/uat-bot-004-rerun-a-full-review-duplicates-and-resolves-nothing--01a1cf70a6c9.md) | rerun: a full review duplicates and resolves nothing | High |
| [UAT-BOT-005](/test-suites/bot/uat-bot-005-fix-a-pushed-fix-resolves-only-its-threads--01a1cf70a6d1.md) | fix: a pushed fix resolves only its threads | High |
| [UAT-BOT-006](/test-suites/bot/uat-bot-006-command-the-bot-answers-vizzini-commands-in-the-thread--01a1cf70a6d9.md) | command: the bot answers /vizzini commands in the thread | High |
| [UAT-BOT-007](/test-suites/bot/uat-bot-007-command-again-no-command-is-answered-twice--01a1cf70a6e2.md) | command-again: no command is answered twice | Medium |
| [UAT-BOT-008](/test-suites/bot/uat-bot-008-dismiss-a-wont-fix-thread-gets-one-suppression-rule--01a1cf70a6ea.md) | dismiss: a won't-fix thread gets one suppression rule | High |
| [UAT-BOT-009](/test-suites/bot/uat-bot-009-suppress-a-merged-rule-suppresses-the-finding--01a1cf70a6f2.md) | suppress: a merged rule suppresses the finding | High |

## After the run
Abandon the PR in the ADO web UI. The script does not abandon it.

## Traces to
[ADR-0004](/decisions/adr-0004-the-unattended-leg-authorizes-by-policy-deny-first--01a1cbfe4052.md), [ADR-0005](/decisions/adr-0005-memory-legs-rerun-and-fix-on-the-same-pr--01a1cc2b9471.md), [Run the unattended bot test](/runbooks/runbook-run-the-unattended-bot-test--01a1cf4af807.md)
