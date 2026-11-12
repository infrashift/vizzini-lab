---
id: "01a1cf93-17e2-7ad7-a1b4-a0dc9b311d08"
title: "TS-HOOK: Webhook receiver (experimental)"
type: "Test Suite"
tags:
  - "uat"
  - "test-suite"
  - "ts-hook"
  - "experimental"
created: "2026-11-12T05:44:46-06:00"
timestamp: "2026-11-12T05:44:46-06:00"
description: "vizzini-webhook, the experimental receiver that answers /vizzini commands as they are written: health, authentication, filtering, an answer with no push, coalescing, commands only, policy denial, log hygiene and shutdown."
---

# TS-HOOK: Webhook receiver (experimental)

- **Command:** `make uat-webhook` (stubllm). `uat/webhook.sh --live` uses the live models.
- **Tokens:** No with `make uat-webhook`. Yes with `--live`.
- **Attended:** No. UAT-HOOK-010 is manual.
- **Plan:** [UAT test plan](/test-suites/uat-test-plan--01a1cf70a5f6.md)
- **Status:** The receiver is EXPERIMENTAL and optional.

## Scope
vizzini-webhook takes Azure DevOps comment events and runs `vizzini-bot --commands-only` to answer `/vizzini` commands at once. This suite runs the receiver on this machine against a real ADO PR.

## Test approach
Azure DevOps cannot deliver to this machine. The harness makes each event from the real comment and the real PR, in the exact shape of the *Pull request commented on* event, and posts it to the receiver. All steps after the delivery are real: the clone, vizzini-bot, mrman, garmr and the reply on the PR. UAT-HOOK-010 covers a delivery by Azure DevOps itself, on a deployed receiver.

## Requirements under test
| Requirement | Statement | Test cases |
|---|---|---|
| REQ-HOOK-01 | The receiver gives its health on `GET /healthz`. | [UAT-HOOK-001](/test-suites/webhook/uat-hook-001-the-receiver-answers-its-health-check--01a1cf9317ec.md) |
| REQ-HOOK-02 | The receiver refuses a delivery without valid basic-auth credentials (401) and a method other than POST (405). | [UAT-HOOK-002](/test-suites/webhook/uat-hook-002-the-receiver-refuses-deliveries-without-valid-credentials--01a1cf9317f7.md) |
| REQ-HOOK-03 | The receiver acts only on a text comment with a `/vizzini` line, on an active PR of an allowlisted repository, that the bot did not write. It gives 200 and a reason for other events, and 400 for a payload it cannot use. | [UAT-HOOK-003](/test-suites/webhook/uat-hook-003-the-receiver-ignores-events-it-must-not-act-on--01a1cf931801.md) |
| REQ-HOOK-04 | A command is answered in its thread without a push, within 120 s of the delivery. | [UAT-HOOK-004](/test-suites/webhook/uat-hook-004-a-command-is-answered-with-no-push--01a1cf93180b.md) |
| REQ-HOOK-05 | Deliveries for one PR fold into one job, and each command gets one answer only. | [UAT-HOOK-005](/test-suites/webhook/uat-hook-005-deliveries-fold-together-and-each-command-is-answered-once--01a1cf931815.md) |
| REQ-HOOK-06 | The receiver answers commands only. It does not review, post findings or resolve threads. | [UAT-HOOK-006](/test-suites/webhook/uat-hook-006-the-receiver-answers-commands-only--01a1cf93181f.md) |
| REQ-HOOK-07 | The grant policy on the base branch authorizes each reply. A denial posts nothing and the log names the identity to allow. | [UAT-HOOK-007](/test-suites/webhook/uat-hook-007-a-denied-reply-posts-nothing-and-names-the-identity-to-allow--01a1cf93182a.md) |
| REQ-HOOK-08 | The logs contain no token, no webhook password and no full requester identity. | [UAT-HOOK-008](/test-suites/webhook/uat-hook-008-the-logs-hold-no-secret-and-no-identity--01a1cf931834.md) |
| REQ-HOOK-09 | The receiver stops cleanly on SIGTERM and warns at start that it is experimental. | [UAT-HOOK-009](/test-suites/webhook/uat-hook-009-the-receiver-stops-cleanly-and-says-it-is-experimental--01a1cf93183f.md) |
| REQ-HOOK-10 | Azure DevOps itself delivers a comment event to a deployed receiver over public HTTPS. | [UAT-HOOK-010](/test-suites/webhook/uat-hook-010-azure-devops-delivers-to-a-deployed-receiver-manual--01a1cf93184a.md) |

## Remote changes
One ADO PR on the scratch repository, with the bot's threads and three commands with their replies. The script abandons the PR and deletes its branch at the end.

## Preconditions
- The [first-time setup](/runbooks/runbook-first-time-setup--01a1cf4a8f24.md) is complete.
- `make ado-check` passes.
- `make build` gives `vizzini-webhook` in `.cache/bin`.
- The ports 18484, 18485 and 18774 are free on 127.0.0.1.
- You have a web browser signed in to Azure DevOps.

## Execution
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make uat-webhook`. | The first line of output is `run: <run>`. |
| 2 | Write down the `<run>` path. | You have the run directory for all cases in this suite. |
| 3 | Open the URL in `<run>/pr-url` in the browser before the run stops. | The ADO PR opens. You can watch the replies arrive. |
| 4 | Wait for the run to stop. | The output shows `result: PASS` or `result: FAIL`, then `PR <id> abandoned`. |

## Test cases
| ID | Title | Priority | Mode |
|---|---|---|---|
| [UAT-HOOK-001](/test-suites/webhook/uat-hook-001-the-receiver-answers-its-health-check--01a1cf9317ec.md) | The receiver answers its health check | Medium | Automated, tester-verified |
| [UAT-HOOK-002](/test-suites/webhook/uat-hook-002-the-receiver-refuses-deliveries-without-valid-credentials--01a1cf9317f7.md) | The receiver refuses deliveries without valid credentials | High | Automated, tester-verified |
| [UAT-HOOK-003](/test-suites/webhook/uat-hook-003-the-receiver-ignores-events-it-must-not-act-on--01a1cf931801.md) | The receiver ignores events it must not act on | High | Automated, tester-verified |
| [UAT-HOOK-004](/test-suites/webhook/uat-hook-004-a-command-is-answered-with-no-push--01a1cf93180b.md) | A command is answered with no push | High | Automated, tester-verified |
| [UAT-HOOK-005](/test-suites/webhook/uat-hook-005-deliveries-fold-together-and-each-command-is-answered-once--01a1cf931815.md) | Deliveries fold together and each command is answered once | High | Automated, tester-verified |
| [UAT-HOOK-006](/test-suites/webhook/uat-hook-006-the-receiver-answers-commands-only--01a1cf93181f.md) | The receiver answers commands only | High | Automated, tester-verified |
| [UAT-HOOK-007](/test-suites/webhook/uat-hook-007-a-denied-reply-posts-nothing-and-names-the-identity-to-allow--01a1cf93182a.md) | A denied reply posts nothing and names the identity to allow | High | Automated, tester-verified |
| [UAT-HOOK-008](/test-suites/webhook/uat-hook-008-the-logs-hold-no-secret-and-no-identity--01a1cf931834.md) | The logs hold no secret and no identity | High | Automated, tester-verified |
| [UAT-HOOK-009](/test-suites/webhook/uat-hook-009-the-receiver-stops-cleanly-and-says-it-is-experimental--01a1cf93183f.md) | The receiver stops cleanly and says it is experimental | Medium | Automated, tester-verified |
| [UAT-HOOK-010](/test-suites/webhook/uat-hook-010-azure-devops-delivers-to-a-deployed-receiver-manual--01a1cf93184a.md) | Azure DevOps delivers to a deployed receiver (manual) | Medium | Manual |

## After the run
None. The script abandons the PR. Its base branch stays, as for the other ADO suites.

## Traces to
Vizzini ADR-0022 and ISSUE-026; Vizzini `deploy/webhook/README.md` (the admin runbook).
