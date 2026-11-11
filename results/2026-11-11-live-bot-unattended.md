# UAT run 20261111T190057Z-bot: vizzini-bot, unattended (Vizzini ISSUE-024 slice 1)

`make uat-bot` (uat/bot.sh), live claude-sonnet-5-5 via LiteLLM, fixture
csharp-seeded, one Azure DevOps PR (#16), no person involved.

| tool | version | commit |
|---|---|---|
| vizzini | 02e1492 | `02e1492c15b9` |
| mrman | v0.1.1-1-gefef0ce (feature/grant-policy) | `efef0ced9850` |
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
- [x] the review found something (9 findings; deny leg 10)
- [x] one marked thread per finding (9 threads, 9 findings)
- [x] every thread is on a reviewed file (9/9)

policy digest 2a706cfb3a3c…, 9 comments, run 01a1cbfc-daa3-7362-b1d4-fb4a406af281

result: PASS

**Cost** (LiteLLM spend logs, `vizzini.agent = vizzini-bot`): 4 requests,
$0.217 in total for the two live runs (PR #15 and PR #16), with two reviews
each. Every request carries its PR as `vizzini.pr_key`
(`ado:…/vizzini-scratch#15` or `#16`), the head commit as
`vizzini.iteration`, and the run id.

**Earlier attempts the same day:**
- A `--stub` run (PR #14) passed the same ten checks with 4 stub findings.
- A live run (PR #15) passed the deny leg. Its allow leg failed when
  `mrman pr` hit a TLS handshake timeout from dev.azure.com. vizzini-bot now
  retries mrman's network errors (Vizzini 02e1492), and this run is the
  rerun.
