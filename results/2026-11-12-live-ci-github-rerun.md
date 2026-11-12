# Live: Vizzini's GitHub Actions template, re-run on mrman v0.1.5

Run 20261112T104715Z, 13/13, on throwaway PR #7 of this repository with
`GITHUB_TOKEN`. The template is `deploy/ci/github/vizzini-bot.yml` from
Vizzini `1dfff26` (bot built from `517e434`, mrman v0.1.5). The test's only
change: stubllm, started in the job, is the model.

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

**The attempt before it** (20261112T104113Z, PR #6) stopped when `gh`
hit `net/http: TLS handshake timeout` while it polled the re-run, and it
left the PR and both branches open (closed and deleted by hand).
`uat/ci-github.sh` now retries read-only `gh` calls and cleans up in an exit
trap.
