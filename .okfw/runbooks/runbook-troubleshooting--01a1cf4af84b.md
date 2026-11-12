---
id: "01a1cf4a-f84b-7319-8f80-f2c05e649f78"
title: "Runbook: troubleshooting"
type: "Runbook"
tags:
  - "runbook"
  - "troubleshooting"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Known failures in the vizzini-lab suites, what each one means, and the fix."
---

# Runbook: troubleshooting

| symptom | meaning | fix |
|---|---|---|
| bot exits **3**, `"decision":"deny"`, `MRM-002` | the grant policy does not list the posting identity | Expected in the deny leg and in the first run of each CI test. Elsewhere, list the identity the log names ([ADR-0004](/decisions/adr-0004-the-unattended-leg-authorizes-by-policy-deny-first--01a1cbfe4052.md)). |
| ADO `403 … TF401027 … PullRequestContribute` | the build service cannot post on PRs | Grant it *Contribute to pull requests* on the repository. mrman ≥ v0.1.5 names the permission and the identity. |
| `curl: (35) Connection reset by peer` from dev.azure.com | a TLS handshake reset; nothing reached the server | Retried automatically ([ADR-0011](/decisions/adr-0011-retry-only-what-cannot-have-been-applied--01a1cf4af917.md)). Poll loops also tolerate it. Re-run only if a step failed. |
| `LiteLLM is not running` | live suite without the proxy | `make litellm-up litellm-smoke` ([architecture](/architecture/litellm-proxy-with-postgres-spend-logs--01a1cf4af88f.md)). |
| the forge leg times out waiting for the grant | nobody ran the printed `mrman … --auto` command | Run it in your own terminal, or raise `GRANT_TIMEOUT` ([ADR-0002](/decisions/adr-0002-the-mrman-submit-grant-stays-a-human-step--01a1caeb8ce7.md)). |
| `score.py` exits on a stale anchor | the fixture changed but `expected.json` did not | Fix the anchors (CLAUDE.md rule 5). |
| ADO agent does not reach `Listening for Jobs` | bad PAT, or the agent image is missing | `podman logs vizzini-lab-<stamp>`, or rebuild `ci/ado-agent`. The organization has one free self-hosted job, so a second concurrent pipeline waits. |
| ADO build never completes; the agent log shows `Agent connect error: The HTTP request timed out` | the agent lost dev.azure.com mid-job and the job hung | Re-run. The cleanup cancels the build and removes the agent's registration; ADO keeps a cancelled job's lease for some minutes, so the cleanup retries. If it prints `AGENT … IS STILL REGISTERED`, delete the agent in Organization settings → Agent pools → Default. |
| GitHub test: `net/http: TLS handshake timeout` from `gh` | api.github.com dropped a handshake | Read calls are retried. The exit trap closes the PR and deletes the branches on any failure. |
| `go: … requires go >= 1.26.11` then failure | `GOTOOLCHAIN=local` somewhere | `install.sh` sets `GOTOOLCHAIN=auto`; do not override it. |
| GitLab job: `no space left on device` | the host disk is full (it happened at 99%) | Free disk space (`podman system df`). GitLab data and the jobs' Go caches already live on tmpfs ([ADR-0008](/decisions/adr-0008-gitlab-ci-runs-on-a-throwaway-self-managed-gitlab-ce-in-podman--01a1cf4af8e3.md)). |
| GitLab job: `Could not resolve host: github.com` | seen once, transient; never reproduced | The runner's pre-build line logs the job's DNS server and whether github.com resolves; start from that line. |
| GitLab job: `api_base uses plaintext http` | mrman warns about the test instance's http | Expected for the local instance only. |
| GitLab or GitHub: `replying in threads … is not supported on this forge` | an mrman older than v0.1.6 | Pin v0.1.6 or later. With older ones, the command is retried, and fails, on every run ([ISSUE-002](/issues/issue-002-ci-template-coverage-gaps--01a1cf4af927.md)). |
| `build.sh` checks out an old commit for a tag | the tag was moved upstream | Already handled: `fetch --tags --force`. Clear `.cache/src/<tool>` if a clone predates that. |
