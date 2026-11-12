# Live: the GitLab CI template resolves a discussion (mrman v0.1.6)

Run 20261112T134151Z, 16/16, MR !1 on a throwaway self-managed GitLab CE
19.5.1 in podman. The template is Vizzini `9e706bc`: mrman v0.1.6, the bot
built from `b7f55f9`. The merge request adds `calc/extra.go`; the third push
removes it. The bot reviewed only `calc.go`, reconciled the removed file,
and its token's bot user resolved its own discussion there with its reply,
and answered a `/vizzini explain` command. That verifies mrman's GitLab
resolve live (Vizzini ISSUE-028).

The run before it (20261112T133158Z) scored 14/16 on the test's own error:
GitLab created a second pipeline for one commit, and the test counted
pipelines. It now waits for the pipeline of the exact commit it pushed.

## job 1: the policy lists no identity

- [x] the job failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity the project access token posts as (project_1_bot_…, its bot user)
- [x] install.sh built and verified the tools in the job
- [x] the template listed the self-managed instance in mrman's config, and mrman authenticated

## job 2: the identity allowed on the base branch

- [x] the job succeeded
- [x] the base branch's policy allowed it
- [x] the findings were posted as discussions with markers (2)
- [x] posted as project_1_bot_… (role Reporter)
- [x] a discussion sits on calc/calc.go

## job 3: a /vizzini command, a second commit, and extra.go removed

- [x] the job succeeded
- [x] an incremental review of calc.go; the removed calc/extra.go reconciled, not reviewed
- [x] no discussion duplicated (2 discussions, 2 distinct)
- [x] the /vizzini command was answered once in its discussion, by project_1_bot_… (mrman v0.1.6 replies on GitLab)
- [x] the finding on the removed calc/extra.go: project_1_bot_… resolved its own discussion, with its reply (mrman v0.1.6 resolves on GitLab)

result: PASS
