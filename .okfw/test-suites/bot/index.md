# test-suites/bot

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [TS-BOT: Unattended bot](ts-bot-unattended-bot--01a1cf70a609.md) - vizzini-bot on one Azure DevOps PR with no person: deny, allow, idle, rerun, fix, command, command-again, dismiss and suppress.
* [UAT-BOT-001: deny: the committed default policy denies the PAT](uat-bot-001-deny-the-committed-default-policy-denies-the-pat--01a1cf70a6b0.md) - Make sure that the bot posts nothing when the policy does not list its identity.
* [UAT-BOT-002: allow: a policy that lists the identity posts one thread per finding](uat-bot-002-allow-a-policy-that-lists-the-identity-posts-one-thread-per-finding--01a1cf70a6b9.md) - Make sure that the bot posts when the policy lists the forge-verified identity.
* [UAT-BOT-003: idle: the same head gets no review](uat-bot-003-idle-the-same-head-gets-no-review--01a1cf70a6c1.md) - Make sure that the bot does not review again when nothing changed.
* [UAT-BOT-004: rerun: a full review duplicates and resolves nothing](uat-bot-004-rerun-a-full-review-duplicates-and-resolves-nothing--01a1cf70a6c9.md) - Make sure that the bot reads its threads and does not post a finding again.
* [UAT-BOT-005: fix: a pushed fix resolves only its threads](uat-bot-005-fix-a-pushed-fix-resolves-only-its-threads--01a1cf70a6d1.md) - Make sure that the bot resolves the thread of a fixed defect and keeps the other threads.
* [UAT-BOT-006: command: the bot answers /vizzini commands in the thread](uat-bot-006-command-the-bot-answers-vizzini-commands-in-the-thread--01a1cf70a6d9.md) - Make sure that the bot answers a valid command and gives usage for a malformed command.
* [UAT-BOT-007: command-again: no command is answered twice](uat-bot-007-command-again-no-command-is-answered-twice--01a1cf70a6e2.md) - Make sure that the bot does not answer a command again.
* [UAT-BOT-008: dismiss: a won't-fix thread gets one suppression rule](uat-bot-008-dismiss-a-wont-fix-thread-gets-one-suppression-rule--01a1cf70a6ea.md) - Make sure that the bot suggests a suppression rule when a person dismisses its thread.
* [UAT-BOT-009: suppress: a merged rule suppresses the finding](uat-bot-009-suppress-a-merged-rule-suppresses-the-finding--01a1cf70a6f2.md) - Make sure that a rule on the base branch stops the finding from being posted again.

