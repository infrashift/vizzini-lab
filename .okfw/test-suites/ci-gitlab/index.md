# test-suites/ci-gitlab

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [TS-CIGL: GitLab CI template](ts-cigl-gitlab-ci-template--01a1cf70a61d.md) - Vizzini's GitLab CI template on a throwaway self-managed GitLab CE in podman: denied, allowed for a Reporter token's bot user, then incremental with an unsupported /vizzini command.
* [UAT-CIGL-001: The first job is denied and names the bot user](uat-cigl-001-the-first-job-is-denied-and-names-the-bot-user--01a1cf70a73e.md) - Make sure that the first job posts nothing and shows the token's bot user.
* [UAT-CIGL-002: The allowed bot user posts a discussion](uat-cigl-002-the-allowed-bot-user-posts-a-discussion--01a1cf70a748.md) - Make sure that a Reporter project access token can post a discussion when the policy lists its bot user.
* [UAT-CIGL-003: An incremental job reports the command as unsupported](uat-cigl-003-an-incremental-job-reports-the-command-as-unsupported--01a1cf70a753.md) - Make sure that the job reviews only the changed file and continues when it cannot reply.
* [UAT-CIGL-004: The run leaves nothing in podman](uat-cigl-004-the-run-leaves-nothing-in-podman--01a1cf70a760.md) - Make sure that the test removes its containers, volumes and network.

