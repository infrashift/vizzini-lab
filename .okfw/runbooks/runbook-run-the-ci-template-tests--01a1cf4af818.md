---
id: "01a1cf4a-f818-77d8-b894-356f795324dc"
title: "Runbook: run the CI template tests"
type: "Runbook"
tags:
  - "runbook"
  - "ci"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "Run Vizzini's GitHub Actions, Azure Pipelines and GitLab CI templates live with make uat-ci-github, uat-ci-ado and uat-ci-gitlab, and confirm each platform is left clean."
---

# Runbook: run the CI template tests

Each test plays the onboarding of Vizzini's `deploy/ci/README.md` through one template, on throwaway infrastructure, with stubllm as the model ([architecture](/architecture/ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md), [ADR-0006](/decisions/adr-0006-ci-template-tests-run-stubllm-inside-the-job--01a1cf4af8c2.md)). None of them spends model tokens.

## The three tests
| | GitHub Actions | Azure Pipelines | GitLab CI |
|---|---|---|---|
| target | `make uat-ci-github` | `make uat-ci-ado` | `make uat-ci-gitlab` |
| runs on | GitHub's runners, throwaway branches of infrashift/vizzini-lab | a self-hosted agent in podman, your ADO project ([ADR-0007](/decisions/adr-0007-azure-pipelines-runs-on-a-throwaway-self-hosted-podman-agent--01a1cf4af8d2.md)) | GitLab CE and a runner in podman, nothing remote ([ADR-0008](/decisions/adr-0008-gitlab-ci-runs-on-a-throwaway-self-managed-gitlab-ce-in-podman--01a1cf4af8e3.md)) |
| needs | `gh` auth (repo, workflow) | the ADO PAT (see [setup](/runbooks/runbook-first-time-setup--01a1cf4a8f24.md)) and the agent image `ci/ado-agent` | the podman socket, about 4 GB of images, about 3 GB of RAM for tmpfs |
| changes outside this machine | a PR and two `ci/` branches | a pipeline, a branch policy, the build service's *Contribute to pull requests*, two `ci/` branches, a PR, an agent registration | nothing |

All three can run at the same time; they share nothing.

## Read the result
- The checklist ends with `result: PASS` or `FAIL`. Evidence is in `.cache/runs/<UTC>-ci-<platform>/`.
- `workflow.diff` or `pipeline.diff` shows exactly how the test changed the template.
- The job logs are there too: `run1.log`, `build1.log` or `job1.log`, and so on.

## Confirm the platform is clean
Each script removes what it made in an exit trap and prints each removal. After an ADO run, check independently that the organization is clean:
- no pipelines, policies or `ci/` branches;
- no agents in the self-hosted pools;
- no active test PR.

The REST calls are in `uat/ci-ado.sh`. If a run was killed, follow [cleanup](/runbooks/runbook-clean-up-after-an-interrupted-run--01a1cf4af83a.md).

## Record
Copy the checklist to `results/YYYY-MM-DD-live-ci-<platform>.md`, with the run stamp, the template's Vizzini commit and the PR or MR number. Vizzini's `deploy/ci/README.md` and its ADR-0021 cite these runs; update them when the outcome changes.
