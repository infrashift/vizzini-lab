# UAT run 20261111T215504Z-bot: suppression from dismissal (Vizzini ISSUE-024 slice 5)

`make uat-bot` (uat/bot.sh), live claude-sonnet-5-5 via LiteLLM, fixture
csharp-seeded, one Azure DevOps PR (#30), 47/47. The run has nine legs on
one PR: deny, allow, idle, rerun, fix, command, command-again, dismiss and
suppress.
- **dismiss:** as the PAT's user, the harness resolved one of the bot's
  threads as won't fix. The bot answered once with a rule to commit.
- **suppress:** the harness merged that rule, unedited, into the base
  branch's `.vizzini/suppressions.yaml` and ran the bot with `--full`. The
  finding came back suppressed by the rule and was not posted, and no second
  suggestion was made.

| tool | version | commit |
|---|---|---|
| vizzini | d004c27 | `d004c277de69` |
| mrman | v0.1.4 | `c4025062005919a0` |
| garmr | bf96753 | `bf96753b9123` |
| okfw | v2026.10.2-2-g557c304 | `557c304ed561` |

The rule the bot suggested, merged as it was:

```yaml
suppressions:
  - id: architecture-24d4592d
    reason: "Dismissed as won't fix in ado:dev.azure.com/ryanscraig/scratch/vizzini-scratch#30: say why"
    paths: ["src/Controllers/OrdersController.cs"]
    categories: [Architecture]
    # Narrower, but a model may word the title differently next time:
    # title: "Controller builds SQL by concatenating user input (SQL injection)"
```

## deny: committed default policy

- [x] bot exit 3 (policy denied), got 3
- [x] one audited deny decision
- [x] denied by MRM-002 only (identity), failed ['MRM-002']
- [x] the decision names the agent and run
- [x] nothing posted on the PR (0 marked threads)

## allow: the pack listing the forge-verified identity

- [x] bot exit 0, got 0
- [x] audited allow decision(s) (1)
- [x] the review found something (10 findings)
- [x] one marked thread per finding (10 threads, 10 findings)
- [x] every thread is on a reviewed file

policy digest db4c3255396b…, 10 comments, run 01a1cc9c-894f-7269-bb6c-f19251fe6a7d

## idle: same head, incremental

- [x] bot exit 0, got 0
- [x] nothing changed since the last reviewed head: no review (mode unchanged)
- [x] no review report was written
- [x] nothing was submitted or resolved

## rerun: same head with --full, the bot reads its threads back

- [x] bot exit 0, got 0
- [x] no duplicated thread (0 duplicates)
- [x] findings recognized as already posted: 8 of 9
- [x] nothing resolved without a code change ([])

metrics: 1 new thread(s) from model variance, 0 kept open (unreported this run, code unchanged)

## fix: a commit fixes the MD5 reset token

- [x] bot exit 0, got 0
- [x] only the changed file was reviewed (mode incremental, files ['src/Services/PasswordHasher.cs'])
- [x] every open thread on another file was carried (10 of 10)
- [x] the bot resolved threads (1: ['295'])
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
- [x] the explain command got one real answer (1 replies, 2948 chars)
- [x] the answer is a reply to the command comment
- [x] the malformed command got one usage reply
- [x] each reply was authorized as event reply (2)

> **/explain** `src/Controllers/OrdersController.cs:14-15`: Why is this dangerous, and what would an attacker send?
> 
> **What the lines do**
> 
> Line 14 creates a `DbCommand` from the injected `DbConnection`. Line 15 builds the SQL text by concatenating `customerPrefix` directly into the string: `... WHERE customer LIKE '` + `customerPrefix` + `%'`. Nothing escapes or parameterizes the value, so whatever the caller supplies becomes part of the SQL syntax rather than staying data.
> 
> **Why it is dangerous**
> 
> A single quote in `customerPrefix` closes the string literal early, and everything after it is parsed as SQL. The attacker controls the structure of the query, not just the value being matched. This is the classic SQL injection pattern (flagged as CA2100).
> 
> **What an attacker could send**
> 
> These examples assume the value reaches `customerPrefix` unmodified. I can't see the caller or any upstream validation in this diff, so I can't say how an HTTP request maps to this parameter.
> 
> - `x' OR 1=1 --` produces `... LIKE 'x' OR 1=1 --%'`. The condition is always true and the trailing `--` comments out the rest, so the count covers every row. That is a data-disclosure
- [x] every command request is attributed to its run and PR (1 of 1)

## dismiss: a person resolves the bot's thread on src/Controllers/OrdersController.cs (Architecture) as won't fix

- [x] bot exit 0, got 0
- [x] one suggestion, in the dismissed thread (['289'])
- [x] the suggestion is a rule for src/Controllers/OrdersController.cs, Architecture
- [x] the thread stays won't fix (wontFix)
- [x] the suggested rule was extracted

## suppress: the rule is merged into the base branch

- [x] bot exit 0, got 0
- [x] the dismissed finding was suppressed by architecture-24d4592d (['architecture-24d4592d src/Controllers/OrdersController.cs:12'])
- [x] no Architecture thread was posted on src/Controllers/OrdersController.cs (0)
- [x] no second suggestion ([])
- [x] the dismissed thread is left as it was (wontFix)

## command-again: nothing is answered twice

- [x] no command answered again ([])
- [x] nothing was posted

result: PASS

**Cost** (`vizzini.pr_key = …#30`): 5 reviews, $0.224 in total; 1 `/explain`
command, $0.0124.

**Which thread was dismissed:** the harness meant to dismiss the
hardcoded-secret thread (`src/Data/Db.cs`). Sonnet filed that finding as
Architecture, citing the data-access ADR, not Security, so the selection fell
back to the first open bot thread: the SQL injection's Architecture thread on
`OrdersController.cs`. The selection now prefers the `Db.cs` thread in any
category. A `--stub` run passed 46/46; stubllm has no model, so the
command-attribution check does not apply.
