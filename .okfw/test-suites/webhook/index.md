# test-suites/webhook

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [TS-HOOK: Webhook receiver (experimental)](ts-hook-webhook-receiver-experimental--01a1cf9317e2.md) - vizzini-webhook, the experimental receiver that answers /vizzini commands as they are written: health, authentication, filtering, an answer with no push, coalescing, commands only, policy denial, log hygiene and shutdown.
* [UAT-HOOK-001: The receiver answers its health check](uat-hook-001-the-receiver-answers-its-health-check--01a1cf9317ec.md) - Make sure that the receiver starts and gives its health.
* [UAT-HOOK-002: The receiver refuses deliveries without valid credentials](uat-hook-002-the-receiver-refuses-deliveries-without-valid-credentials--01a1cf9317f7.md) - Make sure that only a delivery with the configured basic-auth credentials gets in.
* [UAT-HOOK-003: The receiver ignores events it must not act on](uat-hook-003-the-receiver-ignores-events-it-must-not-act-on--01a1cf931801.md) - Make sure that the receiver acts only on qualifying `/vizzini` comments.
* [UAT-HOOK-004: A command is answered with no push](uat-hook-004-a-command-is-answered-with-no-push--01a1cf93180b.md) - Make sure that a `/vizzini` command gets an answer in its thread soon after the delivery, and that no push is necessary.
* [UAT-HOOK-005: Deliveries fold together and each command is answered once](uat-hook-005-deliveries-fold-together-and-each-command-is-answered-once--01a1cf931815.md) - Make sure that repeated deliveries do not give repeated answers.
* [UAT-HOOK-006: The receiver answers commands only](uat-hook-006-the-receiver-answers-commands-only--01a1cf93181f.md) - Make sure that a comment event does not start a review, a new finding or a resolution.
* [UAT-HOOK-007: A denied reply posts nothing and names the identity to allow](uat-hook-007-a-denied-reply-posts-nothing-and-names-the-identity-to-allow--01a1cf93182a.md) - Make sure that the base branch's grant policy controls the receiver, and that a denial tells the admin what to change.
* [UAT-HOOK-008: The logs hold no secret and no identity](uat-hook-008-the-logs-hold-no-secret-and-no-identity--01a1cf931834.md) - Make sure that the receiver does not write a token, the password or a person's identity to its logs.
* [UAT-HOOK-009: The receiver stops cleanly and says it is experimental](uat-hook-009-the-receiver-stops-cleanly-and-says-it-is-experimental--01a1cf93183f.md) - Make sure that a stop does not lose a running job and that the receiver shows its status.
* [UAT-HOOK-010: Azure DevOps delivers to a deployed receiver (manual)](uat-hook-010-azure-devops-delivers-to-a-deployed-receiver-manual--01a1cf93184a.md) - Make sure that a real ADO service hook reaches a receiver that an admin deployed with the runbook.

