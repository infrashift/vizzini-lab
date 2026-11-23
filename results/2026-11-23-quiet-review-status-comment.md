# A quiet review records its head (2026-11-23)

`versions.env` moved to Vizzini `e64a0fc` (ADR-0028) and mrman `2a59e9c`. Both are local commits, not pushed or released. mrman adds `review edit` and lists pull-request-level comments under `summaries` in `review threads`. vizzini-bot uses them: a review that posts nothing records its head in one status comment, posted once and then edited. On Azure DevOps the bot resolves the comment's thread, so a policy that requires resolved comments does not block the PR. A `--commands-only` run no longer records a head in its answers.

All suites ran on stubllm, one after another:

| Suite | Run | Result | Platform state after |
|---|---|---|---|
| `uat/bot.sh --stub` (TS-BOT) | 20261123T055310Z | 61/61 (46 earlier checks, 15 new) | PR 91 abandoned, `uat/` branches deleted |
| `uat/webhook.sh` (TS-HOOK) | 20261123T055758Z | 30/30 | PR abandoned, branches deleted |
| `uat/workflow.sh` (TS-WF) | 20261123T060203Z | 26/26 | PR abandoned, branches deleted |

- The first TS-BOT run (20261123T054749Z) passed 59/59. It showed that the status comment's thread stayed *Active* on Azure DevOps. The bot now resolves it, and two checks were added for that.
- TS-WF first failed because its policy helper matched the old `_allowedEvents` line of mrman's pack, which now includes `edit`. The helper now matches any events list, in `workflow.sh` and `reconsider.sh`. A second attempt hit a network reset on `git push` to Azure DevOps. The third attempt passed.
- TS-RC (`uat/reconsider.sh`) needs a live model and did not run.
- The template suites did not run. Their jobs install mrman from its release, and v0.1.10 has no `review edit`. With it, vizzini-bot sees no `summaries` and writes no status comment, as before.

## The quiet legs

### quiet-1: a review that posts nothing records its head (ADR-0028)

- [x] bot exit 0, got 0
- [x] only the new file was reviewed (mode incremental, files ['docs/quiet-1.md'])
- [x] nothing else was posted (posted 0, resolved [])
- [x] one status comment was posted (status 'posted', 1 on the PR)
- [x] the status comment records the reviewed head
- [x] posted, then resolved, under the policy (['comment', 'resolve'])
- [x] its thread is resolved, so it cannot block the PR (status fixed)

### quiet-2: the next quiet review starts from that head and edits the comment

- [x] bot exit 0, got 0
- [x] the review started from the status comment's head (since e35c65414de3, files ['docs/quiet-2.md'])
- [x] the same status comment was edited (status 'edited', 1 on the PR)
- [x] it records both reviewed heads
- [x] the edit left the thread resolved (status fixed)
- [x] edited under the policy as event edit (['edit'])

### quiet-idle: the recorded head again

- [x] no review was needed (exit 0, mode unchanged)
- [x] nothing was written (status None, 0 decisions)

The status comment on PR 91 after `quiet-2`:

```
**vizzini-bot** reviewed this pull request through `<head 2>` (run `<run>`) and found nothing new to post.

_vizzini-bot edits this comment after each review that posts nothing, so that the next review starts from the last reviewed commit._

<!-- vizzini:status -->
<!-- vizzini:reviewed head=<head 1> run=<run 1> -->
<!-- vizzini:reviewed head=<head 2> run=<run 2> -->
```
