# Vizzini v0.1.3: tools cache and garmr from its release (2026-11-22)

`versions.env` moved to Vizzini `f6e27e3`. That commit pins the CI templates to Vizzini v0.1.3:
- `install.sh` keeps verified tools in a cache under their pins (`VIZZINI_TOOLS_CACHE`, Vizzini ADR-0026). The templates set it to a directory that stays between jobs on a self-hosted agent.
- `install.sh` downloads garmr from its v0.1.0 release (`GARMR_VERSION`). The templates set up no Go, and the GitLab job uses `buildpack-deps:bookworm-scm` (Vizzini ADR-0027).
- The v0.1.3 binaries have no code changes since v0.1.2.

The template tests add Go for the stub only ([ADR-0006](../.okfw/decisions/adr-0006-ci-template-tests-run-stubllm-inside-the-job--01a1cf4af8c2.md)). They gained a garmr release check, and the Azure test gained two cache checks.

Every suite that uses the pin ran on stubllm, with no model tokens:

| Suite | Run | Result | ADO / platform state after |
|---|---|---|---|
| `make uat-ci-github` | 20261123T002032Z | 17/17 | PR 22 closed, `ci/` branches deleted |
| `make uat-ci-ado` | 20261123T002004Z | 17/17 | PR 83 abandoned; pipeline, policy, branches, permission and agent removed |
| `make uat-ci-gitlab` | 20261123T002004Z | 18/18 | GitLab, runner, volumes and network removed |
| `make uat-stub` | 20261123T003335Z | 36/36 hard checks | nothing remote |
| `make uat-bot-stub` | 20261123T003402Z | 46/46 | PR 84 left open by design, then abandoned |
| `make uat-workflow` | 20261123T003633Z | 26/26 | PR 85 abandoned by the script |
| `make uat-webhook` | 20261123T003819Z | 30/30 | PR 86 abandoned by the script |

After the runs, the vizzini-scratch repository had no active PRs and no `ci/` branches. The org had no vizzini-lab agents, and podman had no lab containers or networks. The org's other pipelines and policy are in the macos-sandbox project's `\sbx-lab` folder, and were left alone.

## Install timings
| | Azure build 1 | Azure build 2 | Azure build 3 |
|---|---|---|---|
| clone Vizzini (full history) | 28 s | 39 s | 11 s |
| `install.sh` | 2 min 18 s (empty cache) | under 0.3 s (cache) | under 0.3 s (cache) |

On GitLab, jobs 2 and 3 also installed all three tools from the cache, because the docker executor keeps the builds volume between jobs. On a warm agent, the clone is now most of the install step (Vizzini ISSUE-037).

## Incident
The first GitHub start failed in `make build`: the three template suites started together, and two `uat/build.sh` runs took the same git lock in `.cache/src/mrman`. The GitHub suite then ran alone and passed. The troubleshooting runbook has the row.

## vizzini-bot GitHub Actions template, live

### run 1: the policy lists no identity

- [x] the run failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity GITHUB_TOKEN posts as (github-actions[bot])
- [x] install.sh installed and verified the tools on the runner (mrman v0.1.10, the template's pin)
- [x] install.sh installed the vizzini-bot v0.1.3 release, checked against its SHA256SUMS and the pinned commit
- [x] install.sh installed the garmr v0.1.0 release, checked against its SHA256SUMS and its version

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

## vizzini-bot Azure Pipelines template, live (self-hosted agent)

### build 1: the policy lists no identity

- [x] the build failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity System.AccessToken posts as (scratch Build Service (ryanscraig))
- [x] install.sh installed and verified the tools on the agent (mrman v0.1.10, the template's pin)
- [x] install.sh installed the vizzini-bot v0.1.3 release, checked against its SHA256SUMS and the pinned commit
- [x] install.sh installed the garmr v0.1.0 release, checked against its SHA256SUMS and its version

### build 2: the identity allowed on the base branch

- [x] the build succeeded
- [x] the base branch's policy allowed it
- [x] build 1 filled the agent's tools cache; build 2 installed all three tools from it
- [x] the findings were posted as threads with markers (1)
- [x] posted as scratch Build Service (ryanscraig)

### build 3: a /vizzini command and a second commit

- [x] the build succeeded
- [x] an incremental review of the changed file only
- [x] build 3 installed all three tools from the agent's tools cache
- [x] no thread duplicated (1 threads, 1 distinct)
- [x] the /vizzini command was answered once in its thread, by scratch Build Service (ryanscraig)

result: PASS

## vizzini-bot GitLab CI template, live (self-managed GitLab CE in podman)

### job 1: the policy lists no identity

- [x] the job failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity the project access token posts as (project_1_bot_49d0aa05884c21ec1904d6b04c24ddb5, its bot user)
- [x] install.sh installed and verified the tools in the job (mrman v0.1.10, the template's pin)
- [x] install.sh installed the vizzini-bot v0.1.3 release, checked against its SHA256SUMS and the pinned commit
- [x] install.sh installed the garmr v0.1.0 release, checked against its SHA256SUMS and its version
- [x] the template listed the self-managed instance in mrman's config, and mrman authenticated

### job 2: the identity allowed on the base branch

- [x] the job succeeded
- [x] the base branch's policy allowed it
- [x] the findings were posted as discussions with markers (2)
- [x] posted as project_1_bot_49d0aa05884c21ec1904d6b04c24ddb5 (role Reporter)
- [x] a discussion sits on calc/calc.go

### job 3: a /vizzini command, a second commit, and extra.go removed

- [x] the job succeeded
- [x] an incremental review of calc.go; the removed calc/extra.go reconciled, not reviewed
- [x] no discussion duplicated (2 discussions, 2 distinct)
- [x] the /vizzini command was answered once in its discussion, by project_1_bot_49d0aa05884c21ec1904d6b04c24ddb5 (mrman v0.1.6 replies on GitLab)
- [x] the finding on the removed calc/extra.go: project_1_bot_49d0aa05884c21ec1904d6b04c24ddb5 resolved its own discussion, with its reply (mrman v0.1.6 resolves on GitLab)

result: PASS

