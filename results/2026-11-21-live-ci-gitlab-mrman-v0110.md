# Live: the GitLab CI template on mrman v0.1.10

Run 20261121T230440Z, 17/17, MR !1 on a throwaway self-managed GitLab CE 19.5.1 in podman, removed afterwards. The template is Vizzini `3ef79b2`: mrman v0.1.10, which changed only release packaging (Linux amd64 and arm64 archives with a provenance attestation), and the `vizzini-bot` v0.1.1 release (`VIZZINI_REF` `7575128`). The checks read both pins from the template. The run before it (20261121T225224Z) failed in job 2 on a network error while Go fetched the go1.26.11 toolchain for garmr, before mrman installed. Its job 1 had already installed mrman v0.1.10.

## job 1: the policy lists no identity

- [x] the job failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity the project access token posts as (project_1_bot_…, its bot user)
- [x] install.sh installed and verified the tools in the job (mrman v0.1.10, the template's pin)
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
