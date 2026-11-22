# Pins: Vizzini v0.1.2 templates and mrman v0.1.10 (2026-11-21)

`versions.env` moved to Vizzini `a65f2cf` and mrman `v0.1.10`:
- Vizzini `a65f2cf` pins the CI templates to Vizzini v0.1.2, whose `install.sh` retries the go steps and any curl error (Vizzini ISSUE-035), and to mrman v0.1.10.
- mrman `v0.1.10` is the build that the bot, workflow and webhook suites use.

Every suite that uses either pin ran again on stubllm, with no model tokens:

| Suite | Run | Result | ADO / platform state after |
|---|---|---|---|
| `make uat-stub` | 20261121T233635Z | 36/36 hard checks | nothing remote |
| `make uat-bot-stub` | 20261121T233701Z | 46/46 | PR 75 left open by design, then abandoned |
| `make uat-workflow` | 20261121T233913Z | 26/26 | PR 76 abandoned by the script |
| `make uat-webhook` | 20261121T234038Z | 30/30 | PR 77 abandoned by the script |
| `make uat-ci-github` | 20261121T233635Z | 16/16 | PR closed, `ci/` branches deleted |
| `make uat-ci-ado` | 20261121T234335Z | 14/14 | PR 78 abandoned; pipeline, policy, branches and agent removed |
| `make uat-ci-gitlab` | 20261121T233635Z | 17/17 | GitLab, runner, volumes and network removed |

After the runs, the ADO organization had no active PRs, pipelines, policies, `ci/` branches or self-hosted agents. Podman had no lab containers or networks.

The template suites found `vizzini-bot` v0.1.2 from the release (commit `bfe7f12`) and `mrman version v0.1.10`. No job needed an `install.sh` retry on these runs.

## GitHub Actions template
### run 1: the policy lists no identity

- [x] the run failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity GITHUB_TOKEN posts as (github-actions[bot])
- [x] install.sh installed and verified the tools on the runner (mrman v0.1.10, the template's pin)
- [x] install.sh installed the vizzini-bot v0.1.2 release, checked against its SHA256SUMS and the pinned commit

### run 2: the identity allowed on the base branch

- [x] the re-run succeeded
- [x] the base branch's policy allowed it
- [x] the findings were posted as review comments with markers (3)
- [x] posted as github-actions[bot]
- [x] a comment sits on calc/calc.go

### run 3: a second commit

- [x] the run succeeded
- [x] an incremental review of calc.go; the removed calc/extra.go reconciled, not reviewed
- [x] no comment duplicated (3 comments, 3 distinct)
- [x] the /vizzini command was answered once in its thread, by github-actions[bot] (mrman v0.1.6 replies on GitHub)
- [x] the finding on the removed calc/extra.go: the bot resolved its own thread, with its reply (contents: write opt-in)

result: PASS

## Azure Pipelines template
### build 1: the policy lists no identity

- [x] the build failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity System.AccessToken posts as (scratch Build Service (ryanscraig))
- [x] install.sh installed and verified the tools on the agent (mrman v0.1.10, the template's pin)
- [x] install.sh installed the vizzini-bot v0.1.2 release, checked against its SHA256SUMS and the pinned commit

### build 2: the identity allowed on the base branch

- [x] the build succeeded
- [x] the base branch's policy allowed it
- [x] the findings were posted as threads with markers (1)
- [x] posted as scratch Build Service (ryanscraig)

### build 3: a /vizzini command and a second commit

- [x] the build succeeded
- [x] an incremental review of the changed file only
- [x] no thread duplicated (1 threads, 1 distinct)
- [x] the /vizzini command was answered once in its thread, by scratch Build Service (ryanscraig)

result: PASS

## GitLab CI template
### job 1: the policy lists no identity

- [x] the job failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity the project access token posts as (project_1_bot_…, its bot user)
- [x] install.sh installed and verified the tools in the job (mrman v0.1.10, the template's pin)
- [x] install.sh installed the vizzini-bot v0.1.2 release, checked against its SHA256SUMS and the pinned commit
- [x] the template listed the self-managed instance in mrman's config, and mrman authenticated

### job 2: the identity allowed on the base branch

- [x] the job succeeded
- [x] the base branch's policy allowed it
- [x] the findings were posted as discussions with markers (2)
- [x] posted as project_1_bot_… (role Reporter)
- [x] a discussion sits on calc/calc.go

### job 3: a /vizzini command, a second commit, and extra.go removed

- [x] the job succeeded
- [x] an incremental review of calc.go; the removed calc/extra.go reconciled, not reviewed
- [x] no discussion duplicated (2 discussions, 2 distinct)
- [x] the /vizzini command was answered once in its discussion, by project_1_bot_… (mrman v0.1.6 replies on GitLab)
- [x] the finding on the removed calc/extra.go: project_1_bot_… resolved its own discussion, with its reply (mrman v0.1.6 resolves on GitLab)

result: PASS
