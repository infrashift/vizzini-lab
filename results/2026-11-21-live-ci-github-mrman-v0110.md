# Live: the GitHub Actions template on mrman v0.1.10

Run 20261121T230440Z, 16/16, PR #20 on infrashift/vizzini-lab, closed with its two `ci/` branches deleted. The template is Vizzini `3ef79b2`: mrman v0.1.10, which changed only release packaging (Linux amd64 and arm64 archives with a provenance attestation), and the `vizzini-bot` v0.1.1 release (`VIZZINI_REF` `7575128`). The checks read both pins from the template.

## run 1: the policy lists no identity

- [x] the run failed
- [x] vizzini-bot exited 3 (the grant policy denied posting)
- [x] denied by MRM-002 (identity not listed)
- [x] the log names the identity GITHUB_TOKEN posts as (github-actions[bot])
- [x] install.sh installed and verified the tools on the runner (mrman v0.1.10, the template's pin)
- [x] install.sh installed the vizzini-bot v0.1.1 release, checked against its SHA256SUMS and the pinned commit

## run 2: the identity allowed on the base branch

- [x] the re-run succeeded
- [x] the base branch's policy allowed it
- [x] the findings were posted as review comments with markers (3)
- [x] posted as github-actions[bot]
- [x] a comment sits on calc/calc.go

## run 3: a second commit

- [x] the run succeeded
- [x] an incremental review of calc.go; the removed calc/extra.go reconciled, not reviewed
- [x] no comment duplicated (3 comments, 3 distinct)
- [x] the /vizzini command was answered once in its thread, by github-actions[bot] (mrman v0.1.6 replies on GitHub)
- [x] the finding on the removed calc/extra.go: the bot resolved its own thread, with its reply (contents: write opt-in)

result: PASS
