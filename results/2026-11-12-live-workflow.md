# Live: the full review workflow (uat/workflow.sh)

Run 20261112T122153Z, 26/26, ADO PR #50, stubllm as the model. Vizzini
`dd40bb5` (pkg/marker, `/vizzini reconsider`); mrman `226722b` (branch
`feature/review-threads-findings`, the findings view, stacked on
`feature/github-gitlab-reply-resolve`, reply and resolve on GitHub and
GitLab). A scripted developer agent acted only through mrman, under its
own policy (reply only, with a run id): it read the findings view, argued,
disputed with `/vizzini reconsider`, and tried to resolve, approve and grant
itself, all refused by MRM-001 or mrman. A person fixed, then settled a
dispute by design; the suggested rule, merged to the base, suppressed the
finding. UAT-WF-014/015 (the agent's own account) are BLOCKED: no second
ADO account.

The same suite passed on run 20261112T121641Z (PR #47) with the local
integration build; runs in between failed on connection resets from this
machine to dev.azure.com over IPv6, never on a check. The harness now
retries only what cannot have been applied (ADR-0011): requests that never
left, idempotent methods, and agent actions stopped before any
authorization decision.

## UAT-WF-001 the review

- [x] the bot posts one thread per finding (5)

## UAT-WF-002 the agent reads the findings view

- [x] five findings, none malformed (5)
- [x] each is decoded: Security, Major, a v1 fingerprint, posted at line 5, open, by vizzini-bot
- [x] with the right files

## UAT-WF-003 a person fixes

- [x] the bot resolves the thread, with a reply

## UAT-WF-004 the agent fixes, located by the findings view

- [x] the bot resolves the agent-fixed thread
- [x] the agent did not reply or resolve there

## UAT-WF-005 a change that does not fix

- [x] the thread stays open
- [x] no duplicate thread on wf/nofix.go

## UAT-WF-006 a new defect

- [x] one new thread on wf/regress.go

## UAT-WF-007 defend: the argument, and a finding that stands

- [x] the agent replies through mrman under its own policy (reply)
- [x] the bot answers the reconsider once: the finding stands
- [x] the thread stays open for a person

## UAT-WF-008 a withdrawn finding

- [x] the agent writes /vizzini reconsider through mrman
- [x] the bot withdraws: it resolves its own thread, with its reasons
- [x] the bot's result lists the withdrawal
- [x] a later full review does not post it again

## UAT-WF-009 a person settles: by design

- [x] the bot suggests one suppression rule
- [x] the thread is resolved as by design

## UAT-WF-010 the rule, merged to the base

- [x] a full review suppresses the finding (['security-92102fa0 wf/defend.go:5'])
- [x] no new thread, no second suggestion
- [x] the settled thread is left as it was

## UAT-WF-011 the agent cannot resolve (its policy has no resolve)

- [x] mrman refuses: the policy denies event resolve, by MRM-001 only (MRM-001)

## UAT-WF-012 the agent cannot approve

- [x] mrman refuses: the policy denies event approve, by MRM-001 (MRM-001)
- [x] the PR has no approval vote

## UAT-WF-013 the agent cannot grant itself

- [x] mrman refuses --auto without a terminal

## UAT-WF-014 / 015 identity separation

- BLOCKED: no second ADO account (~/.config/vizzini-uat/ado-dev.pat); not run

result: PASS
