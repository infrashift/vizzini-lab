# Live: vizzini-webhook (experimental), delivered to locally

Run 20261112T114912Z, 30/30, on ADO PR #40 of the scratch project, with
stubllm as the model. Vizzini `956b4d7`: `cmd/vizzini-webhook` and
`vizzini-bot --commands-only`. Azure DevOps cannot deliver to this machine,
so the harness posted each event itself, built in the exact service-hook
shape from the real comment and PR (ADR-0012). Everything after the delivery
was real: the receiver's clone of the ADO repository, vizzini-bot, mrman,
garmr and the replies on the PR.

Replies arrived 16 s, 12 s and 9 s after their deliveries, with the PR's
head unchanged. Three deliveries of one comment gave one job and one
follow-up run, and one answer.

## UAT-HOOK-001 health

- [x] GET /healthz answers 200

## UAT-HOOK-002 authentication

- [x] a delivery without credentials is refused with 401
- [x] a delivery with a wrong password is refused with 401
- [x] GET on the hook is refused with 405

## UAT-HOOK-003 filtering

- [x] plain: ignored with 200 (no /vizzini command)
- [x] bot: ignored with 200 (written by the bot)
- [x] other-repo: ignored with 200 (repository not allowlisted)
- [x] inactive: ignored with 200 (pull request not active)
- [x] push: ignored with 200 (not a pull request comment event)
- [x] ADO's own sample event (legacy visualstudio.com host) is refused with 400

## UAT-HOOK-004 an immediate answer, with no push

- [x] the command's delivery is accepted with 202, queued
- [x] the reply appears in the thread in 16 s (at most 120)
- [x] the PR's head did not move: no push was needed
- [x] the receiver logged the job done, with the comment answered

## UAT-HOOK-005 coalescing, and each command answered once

- [x] three deliveries of one comment: "queue":"queued", "queue":"again", "queue":"again"
- [x] the second command is answered (12 s)
- [x] it has exactly one reply (1)
- [x] the first command still has exactly one reply (1)

## UAT-HOOK-006 commands only

- [x] the bot's finding threads are unchanged (4 of 4) and none was resolved

## UAT-HOOK-007 a denied reply names the identity to allow

- [x] the receiver with the committed policy accepts the delivery
- [x] its job is denied by the grant policy
- [x] the log names the identity to add to _allowedIdentities
- [x] nothing was posted for the denied command
- [x] the receiver with the allow policy then answers it (9 s)

## UAT-HOOK-008 no secret or identity in the logs

- [x] the PAT is in no log
- [x] the webhook password is in no log
- [x] the requester's identity is in no log (redacted)

## UAT-HOOK-009 a clean shutdown

- [x] SIGTERM: the receiver exits 0
- [x] it logs the shutdown
- [x] it warns at start that it is experimental

result: PASS
