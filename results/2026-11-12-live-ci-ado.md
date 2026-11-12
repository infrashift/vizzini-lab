# Live: Vizzini's Azure Pipelines template (uat/ci-ado.sh)

Run 20261112T000243Z, 13/13. The template is Vizzini's
`deploy/ci/azure-pipelines/vizzini-bot.yml`, pinned to Vizzini `517e434`. It
ran as PR build validation on Azure DevOps (PR #34 in the scratch project),
with `System.AccessToken`, on a throwaway self-hosted agent (`ci/ado-agent`
in podman). The organization has no hosted parallelism for private
projects. The test changes the template in two ways only: the Default pool,
and stubllm started in the Review step as the model.

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

**What the run exercised:**
- **The template's setup step:** granting *scratch Build Service
  (ryanscraig)* Contribute to pull requests on the repository. The harness
  granted it for the run (authorized by the repository owner) and removed it
  at the end. Without it, ADO refuses the post with `TF401027
  PullRequestContribute`, which an earlier attempt showed.
- **Everything removed afterwards:** the pipeline, the policy, the branches,
  the agent registration and the permission. No pipelines, policies, agents
  or build-service entry remained on the repository.

**Problems the attempts surfaced, all in the harness:**
- It matched PR builds by a trigger field ADO does not fill in; they are now
  matched by `refs/pull/<id>/merge`.
- A dev.azure.com TLS reset ended one attempt. API calls now retry failures
  that happen before the request is sent.
- The exit-code check looked for GitHub's wording. ADO says
  `Bash exited with code '3'`; the check was fixed and the run re-scored from
  its saved logs.

**Follow-up for mrman:** on a 403, mrman's hint says to check the PAT's
scopes. In a pipeline it is the build identity that lacks a permission, so
the hint misleads there.
