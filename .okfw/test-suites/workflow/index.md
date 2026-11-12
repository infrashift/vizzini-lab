# test-suites/workflow

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [TS-WF: Full review workflow](ts-wf-full-review-workflow--01a1cfa4f447.md) - The whole review workflow on one Azure DevOps PR: Vizzini reviews; a person or a developer agent fixes, defends or disputes; a person settles what stays in dispute; and the agent cannot resolve, approve or grant itself.
* [UAT-WF-001: The review posts one thread for each finding](uat-wf-001-the-review-posts-one-thread-for-each-finding--01a1cfa4f450.md) - Make sure that the bot posts each planted finding as its own thread.
* [UAT-WF-002: The agent reads the findings view](uat-wf-002-the-agent-reads-the-findings-view--01a1cfa4f45a.md) - Make sure that an agent gets each finding as structured fields.
* [UAT-WF-003: A person fixes; the bot resolves](uat-wf-003-a-person-fixes-the-bot-resolves--01a1cfa4f464.md) - Make sure that the bot verifies a person's fix and resolves its own thread.
* [UAT-WF-004: The agent fixes; the bot resolves](uat-wf-004-the-agent-fixes-the-bot-resolves--01a1cfa4f46e.md) - Make sure that an agent can fix from the findings view, and that only the bot closes the thread.
* [UAT-WF-005: A change that does not fix keeps the thread open](uat-wf-005-a-change-that-does-not-fix-keeps-the-thread-open--01a1cfa4f478.md) - Make sure that a moved but unfixed defect keeps its thread, with no duplicate.
* [UAT-WF-006: A new defect gets a new thread](uat-wf-006-a-new-defect-gets-a-new-thread--01a1cfa4f481.md) - Make sure that a defect added in a later push gets its own thread.
* [UAT-WF-007: Defend: the finding stands and stays open](uat-wf-007-defend-the-finding-stands-and-stays-open--01a1cfa4f48c.md) - Make sure that an argument alone does not close a finding, and that the bot answers the dispute once.
* [UAT-WF-008: Withdraw: the bot resolves its own thread](uat-wf-008-withdraw-the-bot-resolves-its-own-thread--01a1cfa4f496.md) - Make sure that the bot can withdraw its finding, and does not post it again.
* [UAT-WF-009: A person settles by design; the bot suggests a rule](uat-wf-009-a-person-settles-by-design-the-bot-suggests-a-rule--01a1cfa4f4a0.md) - Make sure that a person's decision ends the dispute and gives one suggested rule.
* [UAT-WF-010: The merged rule suppresses the finding](uat-wf-010-the-merged-rule-suppresses-the-finding--01a1cfa4f4aa.md) - Make sure that the rule takes effect only from the base branch, and stops the finding.
* [UAT-WF-011: The agent cannot resolve under its own policy](uat-wf-011-the-agent-cannot-resolve-under-its-own-policy--01a1cfa4f4b4.md) - Make sure that the agent's policy (reply only) stops a resolve.
* [UAT-WF-012: The agent cannot approve](uat-wf-012-the-agent-cannot-approve--01a1cfa4f4bf.md) - Make sure that the agent cannot approve the PR.
* [UAT-WF-013: The agent cannot grant itself](uat-wf-013-the-agent-cannot-grant-itself--01a1cfa4f4c9.md) - Make sure that mrman's interactive grant needs a person.
* [UAT-WF-014: With its own account, the agent cannot resolve the bot's threads](uat-wf-014-with-its-own-account-the-agent-cannot-resolve-the-bots-threads--01a1cfa4f4d3.md) - Make sure that mrman's own-thread rule holds even when the agent's policy allows resolve.
* [UAT-WF-015: --command-authors can exclude the agent](uat-wf-015-command-authors-can-exclude-the-agent--01a1cfa4f4dd.md) - Make sure that a team can stop an agent from running `/vizzini` commands.
* [UAT-WF-016: The workflow on GitHub](uat-wf-016-the-workflow-on-github--01a1cfa4f4e7.md) - Make sure that reply, resolve and the findings view work on a GitHub PR.
* [UAT-WF-017: The workflow on GitLab](uat-wf-017-the-workflow-on-gitlab--01a1cfa4f4f1.md) - Make sure that reply, resolve and the findings view work on a GitLab MR.
* [UAT-WF-018: Fix rounds and cost are bounded](uat-wf-018-fix-rounds-and-cost-are-bounded--01a1cfa4f4fd.md) - Make sure that a runaway fix loop stops.
* [UAT-WF-019: Only a person merges](uat-wf-019-only-a-person-merges--01a1cfa4f508.md) - Make sure that the branch policy needs a human approval.
* [UAT-WF-020: Reconsider with a live model](uat-wf-020-reconsider-with-a-live-model--01a1d0fca7cd.md) - Make sure that a live model answers /vizzini reconsider with a real argument, and that the bot acts on each verdict.

