# Live: Vizzini's GitLab CI template, re-run after an image prune

Run 20261112T104049Z, 15/15, MR !1 on a throwaway self-managed GitLab CE
19.5.1 and gitlab-runner v19.5.1 in podman (images pulled again after the
host's image store was pruned). The template is
`deploy/ci/gitlab/vizzini-bot.gitlab-ci.yml` from Vizzini `1dfff26` (bot built
from `517e434`, mrman v0.1.5), with a Reporter project access token. The
test's only change: stubllm, started in the job, is the model.

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
