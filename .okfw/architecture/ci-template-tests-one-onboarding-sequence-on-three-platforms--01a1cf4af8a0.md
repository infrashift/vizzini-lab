---
id: "01a1cf4a-f8a0-7d22-9812-f0023c5ed617"
title: "CI template tests: one onboarding sequence on three platforms"
type: "Architecture"
tags:
  - "architecture"
  - "ci"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "How uat/ci-github.sh, uat/ci-ado.sh and uat/ci-gitlab.sh play the same deny, allow, incremental sequence through Vizzini's CI templates on throwaway infrastructure."
---

# CI template tests: one onboarding sequence on three platforms

`uat/ci-github.sh`, `uat/ci-ado.sh` and `uat/ci-gitlab.sh` test Vizzini's three CI templates (`deploy/ci/` in the pinned Vizzini clone) on real platforms.

## The sequence
Every test plays the same onboarding, the one Vizzini's `deploy/ci/README.md` describes:

1. **Base branch:**
   - a small Go file;
   - the template's grant policy, which lists **no** identity;
   - the test pipeline (the template plus the stub, [ADR-0006](/decisions/adr-0006-ci-template-tests-run-stubllm-inside-the-job--01a1cf4af8c2.md)).
2. **Pull/merge request** from a branch that changes the file. The job must:
   - fail with exit 3, with nothing posted;
   - log mrman's denied decision, which names the identity the CI posts as. The test reads the identity from that log line, never from configuration.
3. **The identity committed to the base branch's policy,** merged into the PR, and a new push. The job must:
   - be allowed by the **base** branch's policy;
   - post the stub's findings with hidden markers, as that identity.
4. **A second commit,** with a `/vizzini explain` comment in a bot thread on ADO and GitLab. The job must:
   - review incrementally, the changed file only;
   - duplicate nothing;
   - answer the command where mrman can reply (ADO), or report it unsupported and carry on (GitLab).
5. **Cleanup** in an exit trap.

## Per platform
| | GitHub Actions | Azure Pipelines | GitLab CI |
|---|---|---|---|
| trigger | `pull_request` | build validation policy on the base branch | `merge_request_event` |
| posting identity | `github-actions[bot]` (`GITHUB_TOKEN`) | `<Project> Build Service (<org>)` (`System.AccessToken`) | the bot user of a Reporter project access token |
| executor | GitHub-hosted runner | self-hosted agent in podman ([ADR-0007](/decisions/adr-0007-azure-pipelines-runs-on-a-throwaway-self-hosted-podman-agent--01a1cf4af8d2.md)) | gitlab-runner, docker executor, in podman ([ADR-0008](/decisions/adr-0008-gitlab-ci-runs-on-a-throwaway-self-managed-gitlab-ce-in-podman--01a1cf4af8e3.md)) |
| template changes | the stub | the stub; pool `Default` | the stub |
| checks | 13 | 13 | 15 |

## What they found
- **GitHub, first run:** garmr needs a newer Go than CI images ship with, so `install.sh` sets `GOTOOLCHAIN=auto` (Vizzini 517e434).
- **Azure, first run:** the build service needs *Contribute to pull requests* (`TF401027`). The setup step documents it, and mrman v0.1.5 names the missing permission in the error.
- **GitLab, first run:** a self-managed instance needs a mrman `[[forge.hosts]]` entry, because mrman reads `GITLAB_TOKEN` for gitlab.com only. The template now writes that entry (Vizzini 1dfff26).

[ISSUE-002](/issues/issue-002-ci-template-coverage-gaps--01a1cf4af927.md) lists what is not yet covered.
