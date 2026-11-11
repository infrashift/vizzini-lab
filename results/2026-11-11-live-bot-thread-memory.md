# UAT run 20261111T194822Z-bot: vizzini-bot thread memory (Vizzini ISSUE-024 slice 2)

`make uat-bot` (uat/bot.sh), live claude-sonnet-5-5 via LiteLLM, fixture
csharp-seeded, one Azure DevOps PR (#19), no person involved. The run has
four legs on that PR, each a separate bot run with its own mrman data
directory: deny, allow, rerun at the same head, and fix (a pushed commit
replacing the MD5 reset token).

| tool | version | commit |
|---|---|---|
| vizzini | 2ddfb3e | `2ddfb3e4661f` |
| mrman | v0.1.2-2-g71c0201 (feature/thread-resolve) | `71c02018972d` |
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

policy digest d12ee1c3c8c5…, 11 comments, run 01a1cc28-6f69-7cfd-acb4-a4402dd5b4cd

## rerun: same head, the bot reads its threads back

- [x] bot exit 0, got 0
- [x] no duplicated thread (0 duplicates)
- [x] findings recognized as already posted: 10 of 10
- [x] nothing resolved without a code change ([])

metrics: 0 new thread(s) from model variance, 0 kept open (unreported this run, code unchanged)

## fix: a commit fixes the MD5 reset token

- [x] bot exit 0, got 0
- [x] the bot resolved threads (1: ['197'])
- [x] the forge shows exactly the threads the bot reported resolved
- [x] only threads on src/Services/PasswordHasher.cs were resolved
- [x] resolved threads have status fixed (Resolved)
- [x] the MD5 thread(s) are resolved (1 before, 0 still open)
- [x] no thread duplicated on unchanged files (0 duplicates)

metrics: 1 new thread(s), 8 already posted, 1 kept open

result: PASS

**The fix leg, thread by thread:**
- **Resolved, #197** (`PasswordHasher.cs:29-30`, Security): "Password reset
  token is a predictable MD5 of email + date". Its lines changed and the
  finding is gone. The bot posted a reply and set the status to fixed.
- **Kept open, #195** (`ImportService.cs:21`, Performance): not reported in
  this run, but its code is unchanged. The bot treats that as model variance,
  not a fix.
- **New, #202** (`RateService.cs:7`, Maintainability, Trivial): a variance
  finding on a file with no earlier thread, so not a duplicate.

**Cost** (LiteLLM spend logs, `vizzini.pr_key = …#19`): 4 requests, $0.217
in total, $0.051–$0.057 per bot run.

A `--stub` run (PR #18) passed the same 21 checks.
