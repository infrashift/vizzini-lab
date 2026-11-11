# UAT run 20261111T211042Z-bot: /vizzini commands in PR threads (Vizzini ISSUE-024 slice 4)

`make uat-bot` (uat/bot.sh), live claude-sonnet-5-5 via LiteLLM, fixture
csharp-seeded, one Azure DevOps PR (#26). The run has seven legs: deny,
allow, idle, rerun (`--full`), fix (incremental), command, and
command-again. In the command leg the harness writes two comments, as the
PAT's user, in the bot's SQL injection thread: `/vizzini explain Why is
this dangerous, and what would an attacker send?` and the malformed
`/vizzini dance`.

| tool | version | commit |
|---|---|---|
| vizzini | a820a35 | `a820a3577dd5` |
| mrman | v0.1.3-1-gf13ff54 (feature/thread-reply) | `f13ff54c34be` |
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

policy digest db4c3255396b…, 11 comments, run 01a1cc73-a62c-72ff-93bd-8673989f1d20

## idle: same head, incremental

- [x] bot exit 0, got 0
- [x] nothing changed since the last reviewed head: no review (mode unchanged)
- [x] no review report was written
- [x] nothing was submitted or resolved

## rerun: same head with --full, the bot reads its threads back

- [x] bot exit 0, got 0
- [x] no duplicated thread (0 duplicates)
- [x] findings recognized as already posted: 11 of 11
- [x] nothing resolved without a code change ([])

metrics: 0 new thread(s) from model variance, 1 kept open (unreported this run, code unchanged)

## fix: a commit fixes the MD5 reset token

- [x] bot exit 0, got 0
- [x] only the changed file was reviewed (mode incremental, files ['src/Services/PasswordHasher.cs'])
- [x] every open thread on another file was carried (10 of 10)
- [x] the bot resolved threads (1: ['264'])
- [x] the forge shows exactly the threads the bot reported resolved
- [x] only threads on src/Services/PasswordHasher.cs were resolved
- [x] resolved threads have status fixed (Resolved)
- [x] the MD5 thread(s) are resolved (1 before, 0 still open)
- [x] no thread duplicated on unchanged files (0 duplicates)

metrics: 1 new thread(s), 0 already posted, 0 kept open

## command: /vizzini in a PR thread

- [x] bot exit 0, got 0
- [x] no review was needed (mode unchanged)
- [x] both commands answered (['2', '3'])
- [x] the explain command got one real answer (1 replies, 3224 chars)
- [x] the answer is a reply to the command comment
- [x] the malformed command got one usage reply
- [x] each reply was authorized as event reply (2)

> **/explain** `src/Controllers/OrdersController.cs:14-17`: Why is this dangerous, and what would an attacker send?
> 
> **What the lines do (14-17)**
> 
> `CountMatching` creates a `DbCommand` from the injected `DbConnection`. It builds the SQL by string concatenation, so `customerPrefix` goes straight into the statement text:
> 
> ```
> SELECT COUNT(*) FROM orders WHERE customer LIKE '<customerPrefix>%'
> ```
> 
> It then runs the query with `ExecuteScalarAsync` and converts the result to `int`.
> 
> **Why it's dangerous**
> 
> The database parses `customerPrefix` as SQL, not as data. Whoever controls that string can close the quoted literal and add their own SQL. I can't see where `customerPrefix` comes from. If it traces back to a request parameter, which is the usual case for a controller method, it is attacker-controlled. Nothing in the visible lines validates, escapes or parameterizes it.
> 
> **What an attacker could send**
> 
> - **Break out of the filter:** `' OR 1=1 --`. This makes the predicate always true, so the count covers every order. The count is only a number, but it still leaks information about the table.
> - **Boolean/blind extraction:** `a' AND (SELECT COUNT(*)
- [x] every command request is attributed to its run and PR (1 of 1)

## command-again: nothing is answered twice

- [x] no command answered again ([])
- [x] nothing was posted

result: PASS

**Cost per bot run** (LiteLLM spend logs, `vizzini.pr_key = …#26`):

| leg | mode | input tokens | cost |
|---|---|---|---|
| deny | review, full | 4,850 | $0.0512 |
| allow | review, full | 4,850 | $0.0595 |
| idle | none (unchanged) | none | no request |
| rerun | review, full | 4,850 | $0.0603 |
| fix | review, incremental (1 file) | 1,994 | $0.0081 |
| command | `/explain` only (head unchanged, no review) | 1,485 | $0.0139 |
| command-again | none | none | no request |

**Two bugs this UAT caught, fixed before this run:**
- **Resolve-only runs left no marker.** A run that resolved threads or
  answered commands, but posted no new finding, recorded no reviewed head.
  The next run then re-reviewed the fixed file. Every bot comment now
  records the head it reviewed (Vizzini ef1cbe5).
- **Command requests were unattributed.** They reached LiteLLM with no run
  ID or PR key: two requests, $0.03, attributed to nobody. Attribution now
  covers the whole run (Vizzini a820a35), and this harness checks it.
