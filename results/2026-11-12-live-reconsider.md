# Live: /vizzini reconsider with Claude Sonnet 5.5 and Opus 5.5

Vizzini ISSUE-029's last open item: a live model answers `/vizzini reconsider`
with a real argument. TS-WF tests the mechanics with stubllm, whose verdict is
scripted; here a real model reads the developer's argument
(`make uat-reconsider`, [UAT-WF-020](../.okfw/test-suites/workflow/uat-wf-020-reconsider-with-a-live-model--01a1d0fca7cd.md)).

Tools: Vizzini `b002fad`, mrman v0.1.9. stubllm writes the two findings, so
the threads are the same in each run; the model answers only the
reconsiders. The developer agent writes each command through mrman, under a
reply-only policy.

| Fixture | Finding | Argument | Expected |
|---|---|---|---|
| `wf/form.go:4` | gosec G101 on `const passwordField = "password"` | it is the form field's name, not a credential | withdrawn |
| `wf/login.go:5` | gosec G401: MD5 for stored passwords | "MD5 is fine here", no evidence | stands |

| Model | Run | ADO PR | Hard checks | Verdicts as expected | Tokens in/out | Spend |
|---|---|---|---|---|---|---|
| claude-sonnet-5-5 | 20261112T181552Z | #68 | 8/8 | 2/2 | 1913/902 | $0.0128 |
| claude-opus-5-5 | 20261112T181743Z | #69 | 8/8 | 2/2 | 1915/1129 | $0.0302 |

The hard checks:
- the review posts exactly two open threads;
- the agent writes both commands through mrman;
- the bot answers both through the schema;
- no new finding is posted;
- each verdict is acted on: withdrawn resolves the bot's own thread, and stands leaves it open;
- a later run answers nothing;
- both model calls are attributed to the run in command mode.

Both PRs were abandoned and their branches deleted at the end.

**What the answers show.**
- **The false positive.** Both models withdrew it. Each named the cause: G101 matches the identifier, and the literal is a map key. Both offered an optional `#nosec G101` with a reason.
- **The real defect.** Both models kept it standing. Each answered the two claims point by point: long passwords do not make up for a fast, unsalted hash, and network isolation does nothing once the hashes leak. Each said what evidence would change its mind, and named bcrypt, scrypt or Argon2.
- **An extra point.** Without being asked, both also noted that `CheckPassword` compares hashes with `==`, which is not constant-time.
- **What Sonnet could not see.** Sonnet said it cannot see the body of `weakHash`, which is on the base branch and outside the diff, so it relied on the developer's word that it is MD5. That is correct: the reconsider prompt carries the PR's diff, not the whole file tree.

Round 0 of the Sonnet run hit one network error while posting. The bot
retried and posted 2 of 2, and the PR had exactly two threads, so nothing
was posted twice.
