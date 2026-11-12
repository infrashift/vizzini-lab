---
id: "01a1cfa4-f447-7300-aa60-11948d6d91ef"
title: "TS-WF: Full review workflow"
type: "Test Suite"
tags:
  - "uat"
  - "test-suite"
  - "ts-wf"
created: "2026-11-12T06:04:16-06:00"
timestamp: "2026-11-12T06:04:16-06:00"
description: "The whole review workflow on one Azure DevOps PR: Vizzini reviews; a person or a developer agent fixes, defends or disputes; a person settles what stays in dispute; and the agent cannot resolve, approve or grant itself."
---

# TS-WF: Full review workflow

- **Command:** `make uat-workflow` (stubllm, no tokens).
- **Attended:** No. UAT-WF-018 and UAT-WF-019 are manual.
- **Plan:** [UAT test plan](/test-suites/uat-test-plan--01a1cf70a5f6.md)

## Scope
The workflow from Vizzini ISSUE-027, -028 and -029 and ADR-0023. Vizzini reviews. A developer, a person or an agent, fixes, defends or disputes. A person settles what stays in dispute. The bot verifies fixes itself, and it may withdraw only its own finding.

## Variants
| Variant | Fixture | Actor | Outcome under test | Case |
|---|---|---|---|---|
| Fix | `wf/person.go` | person | the bot resolves | UAT-WF-003 |
| Fix | `wf/agent.go` | agent, from the findings view | the bot resolves | UAT-WF-004 |
| Not a fix | `wf/nofix.go` | person | stays open, no duplicate | UAT-WF-005 |
| Regression | `wf/regress.go` | person | a new thread | UAT-WF-006 |
| Defend | `wf/defend.go` | agent | stands, open, then settled by design and suppressed | UAT-WF-007, -009, -010 |
| Dispute won | `wf/withdraw.go` | agent | withdrawn, resolved by the bot, never reposted | UAT-WF-008 |
| Guardrails | any | agent | no resolve, no approve, no self-grant | UAT-WF-011..013 |
| Own identity | `wf/nofix.go` | agent, own account | cannot resolve the bot's thread; can be excluded from commands | UAT-WF-014, -015 |
| Other forges | | | GitHub, GitLab | UAT-WF-016, -017 |

## Test approach
One PR on the scratch ADO repository, with a synthetic Go module, `wf/`. stubllm reports one finding for each linter diagnostic on a changed line, and each round writes its own golangci-lint JSON. A `/reconsider` is withdrawn only when the argument contains `[stub:withdraw]`. So each outcome is deterministic, and the suite tests the workflow, not a model.

The developer agent is a script. It acts only through mrman: `review threads --findings`, then `review reply` under its own policy, which allows `reply` only. Every call has a run id, as the policy requires (MRM-004). It edits files and pushes with git.

## Requirements under test
| Requirement | Statement | Test cases |
|---|---|---|
| REQ-WF-01 | The bot posts one thread for each finding. | [UAT-WF-001](/test-suites/workflow/uat-wf-001-the-review-posts-one-thread-for-each-finding--01a1cfa4f450.md) |
| REQ-WF-02 | A developer agent reads the findings as structured data (`review threads --findings`), not as comment text. | [UAT-WF-002](/test-suites/workflow/uat-wf-002-the-agent-reads-the-findings-view--01a1cfa4f45a.md) |
| REQ-WF-03 | A fix, by a person or an agent, is verified by the bot, which resolves its own thread. | [UAT-WF-003](/test-suites/workflow/uat-wf-003-a-person-fixes-the-bot-resolves--01a1cfa4f464.md), [UAT-WF-004](/test-suites/workflow/uat-wf-004-the-agent-fixes-the-bot-resolves--01a1cfa4f46e.md) |
| REQ-WF-04 | A change that does not fix keeps the thread open, with no duplicate. A new defect gets a new thread. | [UAT-WF-005](/test-suites/workflow/uat-wf-005-a-change-that-does-not-fix-keeps-the-thread-open--01a1cfa4f478.md), [UAT-WF-006](/test-suites/workflow/uat-wf-006-a-new-defect-gets-a-new-thread--01a1cfa4f481.md) |
| REQ-WF-05 | A disputed finding that stands stays open for a person. The bot answers the dispute once. | [UAT-WF-007](/test-suites/workflow/uat-wf-007-defend-the-finding-stands-and-stays-open--01a1cfa4f48c.md) |
| REQ-WF-06 | The bot may withdraw its own finding on reconsideration. It then resolves its thread and does not post the finding again. | [UAT-WF-008](/test-suites/workflow/uat-wf-008-withdraw-the-bot-resolves-its-own-thread--01a1cfa4f496.md) |
| REQ-WF-07 | A person settles a dispute. A by-design resolution gives one suggested rule, which suppresses the finding only after a merge to the base branch. | [UAT-WF-009](/test-suites/workflow/uat-wf-009-a-person-settles-by-design-the-bot-suggests-a-rule--01a1cfa4f4a0.md), [UAT-WF-010](/test-suites/workflow/uat-wf-010-the-merged-rule-suppresses-the-finding--01a1cfa4f4aa.md) |
| REQ-WF-08 | The agent cannot resolve, approve or grant itself. | [UAT-WF-011](/test-suites/workflow/uat-wf-011-the-agent-cannot-resolve-under-its-own-policy--01a1cfa4f4b4.md), [UAT-WF-012](/test-suites/workflow/uat-wf-012-the-agent-cannot-approve--01a1cfa4f4bf.md), [UAT-WF-013](/test-suites/workflow/uat-wf-013-the-agent-cannot-grant-itself--01a1cfa4f4c9.md) |
| REQ-WF-09 | With its own account, the agent cannot resolve the bot's threads, and `--command-authors` can exclude it. | [UAT-WF-014](/test-suites/workflow/uat-wf-014-with-its-own-account-the-agent-cannot-resolve-the-bots-threads--01a1cfa4f4d3.md), [UAT-WF-015](/test-suites/workflow/uat-wf-015-command-authors-can-exclude-the-agent--01a1cfa4f4dd.md) |
| REQ-WF-10 | The workflow works on GitHub and GitLab too. | [UAT-WF-016](/test-suites/workflow/uat-wf-016-the-workflow-on-github--01a1cfa4f4e7.md), [UAT-WF-017](/test-suites/workflow/uat-wf-017-the-workflow-on-gitlab--01a1cfa4f4f1.md) |
| REQ-WF-11 | Fix rounds and model cost are bounded. | [UAT-WF-018](/test-suites/workflow/uat-wf-018-fix-rounds-and-cost-are-bounded--01a1cfa4f4fd.md) |
| REQ-WF-12 | Only a person merges. | [UAT-WF-019](/test-suites/workflow/uat-wf-019-only-a-person-merges--01a1cfa4f508.md) |

## Rounds
1. **Round 0:** the review. A deny run under mrman's committed policy names the identity, then the bot posts five threads.
2. **Round 1:** the agent reads the findings view and tries the three forbidden actions. It argues in the `defend` thread and writes two `/vizzini reconsider` commands. The fixes, the non-fix and the new defect are pushed, and the bot runs incrementally.
3. **Round 2:** a person resolves the `defend` thread as *by design*. The bot suggests a rule.
4. **Round 3:** the rule is merged to the base branch, and the bot runs with `--full`.

## Preconditions
- The [first-time setup](/runbooks/runbook-first-time-setup--01a1cf4a8f24.md) is complete. `make ado-check` passes.
- The pinned mrman has `review threads --findings` (ISSUE-027), and the pinned Vizzini has `/vizzini reconsider` (ISSUE-029).
- Optional, for UAT-WF-014 and UAT-WF-015: a second ADO account's PAT in `~/.config/vizzini-uat/ado-dev.pat`.
- You have a web browser signed in to Azure DevOps.

## Execution
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make uat-workflow`. | The first line of output is `run: <run>`. |
| 2 | Write down the `<run>` path. Open `<run>/pr-url` in the browser. | The ADO PR opens. |
| 3 | Wait for the run to stop. | The output shows `result: PASS` or `result: FAIL`, then `PR <id> abandoned`. |

## Test cases
| ID | Title | Priority | Mode |
|---|---|---|---|
| [UAT-WF-001](/test-suites/workflow/uat-wf-001-the-review-posts-one-thread-for-each-finding--01a1cfa4f450.md) | The review posts one thread for each finding | High | Automated, tester-verified |
| [UAT-WF-002](/test-suites/workflow/uat-wf-002-the-agent-reads-the-findings-view--01a1cfa4f45a.md) | The agent reads the findings view | High | Automated, tester-verified |
| [UAT-WF-003](/test-suites/workflow/uat-wf-003-a-person-fixes-the-bot-resolves--01a1cfa4f464.md) | A person fixes; the bot resolves | High | Automated, tester-verified |
| [UAT-WF-004](/test-suites/workflow/uat-wf-004-the-agent-fixes-the-bot-resolves--01a1cfa4f46e.md) | The agent fixes; the bot resolves | High | Automated, tester-verified |
| [UAT-WF-005](/test-suites/workflow/uat-wf-005-a-change-that-does-not-fix-keeps-the-thread-open--01a1cfa4f478.md) | A change that does not fix keeps the thread open | High | Automated, tester-verified |
| [UAT-WF-006](/test-suites/workflow/uat-wf-006-a-new-defect-gets-a-new-thread--01a1cfa4f481.md) | A new defect gets a new thread | Medium | Automated, tester-verified |
| [UAT-WF-007](/test-suites/workflow/uat-wf-007-defend-the-finding-stands-and-stays-open--01a1cfa4f48c.md) | Defend: the finding stands and stays open | High | Automated, tester-verified |
| [UAT-WF-008](/test-suites/workflow/uat-wf-008-withdraw-the-bot-resolves-its-own-thread--01a1cfa4f496.md) | Withdraw: the bot resolves its own thread | High | Automated, tester-verified |
| [UAT-WF-009](/test-suites/workflow/uat-wf-009-a-person-settles-by-design-the-bot-suggests-a-rule--01a1cfa4f4a0.md) | A person settles by design; the bot suggests a rule | High | Automated, tester-verified |
| [UAT-WF-010](/test-suites/workflow/uat-wf-010-the-merged-rule-suppresses-the-finding--01a1cfa4f4aa.md) | The merged rule suppresses the finding | High | Automated, tester-verified |
| [UAT-WF-011](/test-suites/workflow/uat-wf-011-the-agent-cannot-resolve-under-its-own-policy--01a1cfa4f4b4.md) | The agent cannot resolve under its own policy | High | Automated, tester-verified |
| [UAT-WF-012](/test-suites/workflow/uat-wf-012-the-agent-cannot-approve--01a1cfa4f4bf.md) | The agent cannot approve | High | Automated, tester-verified |
| [UAT-WF-013](/test-suites/workflow/uat-wf-013-the-agent-cannot-grant-itself--01a1cfa4f4c9.md) | The agent cannot grant itself | High | Automated, tester-verified |
| [UAT-WF-014](/test-suites/workflow/uat-wf-014-with-its-own-account-the-agent-cannot-resolve-the-bots-threads--01a1cfa4f4d3.md) | With its own account, the agent cannot resolve the bot's threads | High | Automated, needs a second account |
| [UAT-WF-015](/test-suites/workflow/uat-wf-015-command-authors-can-exclude-the-agent--01a1cfa4f4dd.md) | --command-authors can exclude the agent | Medium | Automated, needs a second account |
| [UAT-WF-016](/test-suites/workflow/uat-wf-016-the-workflow-on-github--01a1cfa4f4e7.md) | The workflow on GitHub | Medium | Pending automation |
| [UAT-WF-017](/test-suites/workflow/uat-wf-017-the-workflow-on-gitlab--01a1cfa4f4f1.md) | The workflow on GitLab | Medium | Pending automation |
| [UAT-WF-018](/test-suites/workflow/uat-wf-018-fix-rounds-and-cost-are-bounded--01a1cfa4f4fd.md) | Fix rounds and cost are bounded | Low | Manual |
| [UAT-WF-019](/test-suites/workflow/uat-wf-019-only-a-person-merges--01a1cfa4f508.md) | Only a person merges | High | Manual |

## Traces to
Vizzini ISSUE-027, ISSUE-028, ISSUE-029 and ADR-0023.
