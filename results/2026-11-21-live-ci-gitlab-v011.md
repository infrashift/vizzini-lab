# Live: the GitLab CI template installs the released vizzini-bot (Vizzini v0.1.1)

Run 20261121T211920Z, 17/17, MR !1 on a throwaway self-managed GitLab CE 19.5.1 in podman, removed afterwards. The template is Vizzini `066d99b`: `VIZZINI_REF` pins the v0.1.1 commit `7575128` and `VIZZINI_VERSION` pins `v0.1.1`, with mrman v0.1.9. `install.sh` downloaded the `vizzini_0.1.1_linux_amd64` archive, checked it against the release's `SHA256SUMS`, and checked that `vizzini-bot --version` names the pinned commit. It did not build `vizzini-bot`. Every earlier check still passes (Vizzini ISSUE-034).

## job 1: the policy lists no identity

- [x] the job failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity the project access token posts as (project_1_bot_…, its bot user)
- [x] install.sh installed and verified the tools in the job
- [x] install.sh installed the vizzini-bot v0.1.1 release, checked against its SHA256SUMS and the pinned commit
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
