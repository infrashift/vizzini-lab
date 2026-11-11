# UAT run 20261111T203416Z-bot: vizzini-bot incremental review (Vizzini ISSUE-024 slice 3)

`make uat-bot` (uat/bot.sh), live claude-sonnet-5-5 via LiteLLM, fixture
csharp-seeded, one Azure DevOps PR (#22), no person involved. The run has
five legs, each a separate bot run with its own mrman data directory: deny,
allow, idle (same head, incremental), rerun (same head, `--full`), and fix
(a pushed commit replacing the MD5 reset token, reviewed incrementally).

| tool | version | commit |
|---|---|---|
| vizzini | 1eda2f4 | `1eda2f4a3c3f` |
| mrman | v0.1.3 tag on afd933a (thread-resolve) | `afd933ace876` |
| garmr | bf96753 | `bf96753b9123` |
| okfw | v2026.10.2-2-g557c304 | `557c304ed561` |

## deny: committed default policy

- [x] bot exit 3 (policy denied), got 3
- [x] one audited deny decision
- [x] denied by MRM-002 only (identity), failed ['MRM-002']
- [x] the decision names the agent and run
- [x] nothing posted on the PR (0 marked threads)

## allow: the pack listing the forge-verified identity

- [x] bot exit 0, got 0
- [x] audited allow decision(s) (1)
- [x] the review found something (11 findings)
- [x] one marked thread per finding (11 threads, 11 findings)
- [x] every thread is on a reviewed file

policy digest d12ee1c3c8c5…, 11 comments, run 01a1cc52-5ccb-7264-9dcc-546150096ff6

## idle: same head, incremental

- [x] bot exit 0, got 0
- [x] nothing changed since the last reviewed head: no review (mode unchanged)
- [x] no review report was written
- [x] nothing was submitted or resolved

## rerun: same head with --full, the bot reads its threads back

- [x] bot exit 0, got 0
- [x] no duplicated thread (0 duplicates)
- [x] findings recognized as already posted: 9 of 9
- [x] nothing resolved without a code change ([])

metrics: 0 new thread(s) from model variance, 1 kept open (unreported this run, code unchanged)

## fix: a commit fixes the MD5 reset token

- [x] bot exit 0, got 0
- [x] only the changed file was reviewed (mode incremental, files ['src/Services/PasswordHasher.cs'])
- [x] every open thread on another file was carried (10 of 10)
- [x] the bot resolved threads (1: ['222'])
- [x] the forge shows exactly the threads the bot reported resolved
- [x] only threads on src/Services/PasswordHasher.cs were resolved
- [x] resolved threads have status fixed (Resolved)
- [x] the MD5 thread(s) are resolved (1 before, 0 still open)
- [x] no thread duplicated on unchanged files (0 duplicates)

metrics: 1 new thread(s), 0 already posted, 0 kept open

result: PASS

**Cost per bot run** (LiteLLM spend logs, `vizzini.pr_key = …#22`):

| leg | mode | input tokens | cost |
|---|---|---|---|
| deny | full | 4,850 | $0.0590 (review made, then denied) |
| allow | full | 4,850 | $0.0572 |
| idle | unchanged | none | no request |
| rerun | full (`--full`) | 4,850 | $0.0511 |
| fix | incremental, 1 file | 1,994 | $0.0081 |

The incremental review of the push cost about 1/7 of a full review and took
16s instead of 43–50s. The 10 threads on the files it did not review were
carried untouched. The MD5 thread on the changed file was resolved.

A `--stub` run (PR #21) passed the same 27 checks.
