# Live: Vizzini's GitHub Actions template (uat/ci-github.sh)

Run 20261111T223350Z, 13/13. The template is Vizzini's
`deploy/ci/github/vizzini-bot.yml`, pinned to Vizzini `517e434` and built by
the template's own `install.sh` on GitHub's `ubuntu-latest` runner. It ran
on throwaway PR #4 of this repository, with `GITHUB_TOKEN`. The test's only
change to the template: stubllm (`-finding-per-file`), started in the job,
is the model.

## run 1: the policy lists no identity

- [x] the run failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity GITHUB_TOKEN posts as (github-actions[bot])
- [x] install.sh built and verified the tools on the runner

## run 2: the identity allowed on the base branch

- [x] the re-run succeeded
- [x] the base branch's policy allowed it
- [x] the findings were posted as review comments with markers (2)
- [x] posted as github-actions[bot]
- [x] a comment sits on calc/calc.go

## run 3: a second commit

- [x] the run succeeded
- [x] an incremental review of the changed file only
- [x] no comment duplicated (2 comments, 2 distinct)

result: PASS

**What the bot logged:**
- **Re-run:** `0 earlier threads; 2 new`, then `posted 2 of 2 new comments`.
- **Second push:** `reviewing 1 file(s) changed since bac62574fff6`, then
  `1 already posted, 1 carried`.

**Problems the first attempts surfaced:**
1. **garmr would not install on the runner.** garmr requires Go 1.26.11,
   but `setup-go` installs Vizzini's 1.25 and sets `GOTOOLCHAIN=local`.
   `install.sh` now sets `GOTOOLCHAIN=auto` (Vizzini 517e434). This would
   have broken the Azure and GitLab templates the same way.
2. **The harness's own bugs:** its stubllm build step ran outside Vizzini's
   module, and it used a `gh run view` field that does not exist. Both are
   fixed.

The throwaway PRs (#1–#4) are closed, and every `ci/*` branch is deleted.

**Not run live:**
- **Azure Pipelines:** this ADO organization has no hosted parallelism for
  private projects (0 free, 0 purchased; 1 free self-hosted job).
- **GitLab CI:** no GitLab project is set up for it.

Both templates pass `make ci-check` (shellcheck and YAML parse). Their
install step is the one verified here, and also in a golang:1.25.4
container.
