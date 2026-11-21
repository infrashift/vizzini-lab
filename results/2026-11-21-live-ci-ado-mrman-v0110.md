# Live: the Azure Pipelines template on mrman v0.1.10

Run 20261121T230440Z, 14/14, PR 73 on a throwaway self-hosted agent in podman. Its pipeline, policy, branches, PR and agent were removed. The template is Vizzini `3ef79b2`: mrman v0.1.10, which changed only release packaging (Linux amd64 and arm64 archives with a provenance attestation), and the `vizzini-bot` v0.1.1 release (`VIZZINI_REF` `7575128`). The checks read both pins from the template. At the same time, another project's ADO test (folder `\sbx-lab`, stamp 20261121T230355Z) ran in the same organization, so the clean-org check must filter by this run's stamp.

## build 1: the policy lists no identity

- [x] the build failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity System.AccessToken posts as (scratch Build Service (ryanscraig))
- [x] install.sh installed and verified the tools on the agent (mrman v0.1.10, the template's pin)
- [x] install.sh installed the vizzini-bot v0.1.1 release, checked against its SHA256SUMS and the pinned commit

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
