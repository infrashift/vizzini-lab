# Live: Vizzini's Azure Pipelines template, re-run on mrman v0.1.5

Run 20261112T111752Z, 13/13, as PR build validation on PR #38 of the scratch
project, with `System.AccessToken`, on a throwaway self-hosted agent. The
template is `deploy/ci/azure-pipelines/vizzini-bot.yml` from Vizzini
`1dfff26` (bot built from `517e434`, mrman v0.1.5). The test changes the
template in two ways only: the Default pool, and stubllm as the model.

## build 1: the policy lists no identity

- [x] the build failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity System.AccessToken posts as (scratch Build Service (ryanscraig))
- [x] install.sh built and verified the tools on the agent

## build 2: the identity allowed on the base branch

- [x] the build succeeded
- [x] the base branch's policy allowed it
- [x] the findings were posted as threads with markers (1)
- [x] posted as scratch Build Service (ryanscraig)

## build 3: a /vizzini command and a second commit

- [x] the build succeeded
- [x] an incremental review of the changed file only
- [x] no thread duplicated (1 threads, 1 distinct)
- [x] the /vizzini command was answered once in its thread, by scratch Build Service (ryanscraig)

result: PASS

**Cleanup:** the build service permission, PR, policy, pipeline, branches
and agent were removed; the agent's deregistration was confirmed through the
API. Afterwards the organization had no pipelines, policies, active PRs,
`ci/` branches or self-hosted agents.

**The attempt before it** (20261112T104018Z, PR #37) lost dev.azure.com
from the agent during build 2 (`Agent connect error: The HTTP request timed
out`); the job hung and the script gave up after 1500 s. Its cleanup
reported the agent deregistered, but ADO had refused that while it still held
the job: the registration was removed by hand once the cancelled job's lease
expired. `uat/ci-ado.sh` now cancels unfinished builds first and confirms,
with retries, that the agent left the pool.
