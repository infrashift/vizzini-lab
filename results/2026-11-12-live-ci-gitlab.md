# Live: Vizzini's GitLab CI template (uat/ci-gitlab.sh)

Run 20261112T102318Z, 15/15. The template is Vizzini's
`deploy/ci/gitlab/vizzini-bot.gitlab-ci.yml` at `1dfff26`, which builds the bot
from Vizzini `517e434` and installs mrman v0.1.5. It ran as a merge request
pipeline (MR !1) on a throwaway self-managed GitLab CE 19.5.1 with
gitlab-runner v19.5.1 (docker executor), both in podman, using a Reporter
project access token in the masked variable `VIZZINI_GITLAB_TOKEN`. The test
changes the template in one way only: stubllm, started in the job, is the
model.

The first complete run (20261112T050706Z, 14/14) needed the test to add
mrman's `[[forge.hosts]]` entry itself. A self-managed instance otherwise gets
no token: mrman reads `GITLAB_TOKEN` for gitlab.com only. Vizzini `1dfff26`
moved that step into the template; this run checks it.

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
- [x] the findings were posted as discussions with markers (1)
- [x] posted as project_1_bot_… (role Reporter)
- [x] a discussion sits on calc/calc.go

## job 3: a /vizzini command and a second commit

- [x] the job succeeded
- [x] an incremental review of the changed file only
- [x] no discussion duplicated (1 discussions, 1 distinct)
- [x] the /vizzini command went unanswered, reported as unsupported (mrman has no GitLab reply yet), and the job went on

result: PASS
