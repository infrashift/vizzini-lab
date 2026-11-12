---
id: "01a1cf70-a616-74b7-8c14-eeba2e620399"
title: "TS-CIADO: Azure Pipelines template"
type: "Test Suite"
tags:
  - "uat"
  - "test-suite"
  - "ts-ciado"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Vizzini's Azure Pipelines template as PR build validation on a throwaway self-hosted agent: denied, allowed with the build service permission, then incremental with a /vizzini command."
---

# TS-CIADO: Azure Pipelines template

- **Command:** `make uat-ci-ado`
- **Tokens:** No (stubllm in the job)
- **Attended:** No
- **Plan:** [UAT test plan](/test-suites/uat-test-plan--01a1cf70a5f6.md)

## Scope
The template's install step, the grant policy from the base branch, `System.AccessToken` as the posting identity, incremental review and a `/vizzini` command.

## Remote changes
A pipeline, a branch policy, a repository permission, two `ci/` branches, a PR and an agent registration. The script removes them.

> **CAUTION:** The run gives `<Project> Build Service (<org>)` the *Contribute to pull requests* permission on the repository. If the run stops before its cleanup, remove the permission manually. See [cleanup](/runbooks/runbook-clean-up-after-an-interrupted-run--01a1cf4af83a.md).

## Preconditions
- The ADO PAT can create pipelines, policies, permissions and agents.
- The ADO organization has a free self-hosted parallel job.
- You have a web browser signed in to Azure DevOps.

## Execution
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make uat-ci-ado`. | The output shows `run: <run>`, the pipeline, the policy and the permission grant. |
| 2 | Write down the `<run>` path. | You have the run directory for all cases in this suite. |
| 3 | Wait for the run to stop. | The output shows `result: PASS` or `result: FAIL`, then the cleanup lines. |

## Test cases
| ID | Title | Priority |
|---|---|---|
| [UAT-CIADO-001](/test-suites/ci-ado/uat-ciado-001-the-first-build-is-denied-and-names-the-identity--01a1cf70a71b.md) | The first build is denied and names the identity | High |
| [UAT-CIADO-002](/test-suites/ci-ado/uat-ciado-002-the-allowed-build-service-posts-threads--01a1cf70a724.md) | The allowed build service posts threads | High |
| [UAT-CIADO-003](/test-suites/ci-ado/uat-ciado-003-an-incremental-build-answers-a-vizzini-command--01a1cf70a72c.md) | An incremental build answers a /vizzini command | High |
| [UAT-CIADO-004](/test-suites/ci-ado/uat-ciado-004-the-organization-is-clean-after-the-run--01a1cf70a735.md) | The organization is clean after the run | High |

## After the run
Do UAT-CIADO-004. It makes sure that the organization is clean.

## Traces to
[ADR-0007](/decisions/adr-0007-azure-pipelines-runs-on-a-throwaway-self-hosted-podman-agent--01a1cf4af8d2.md), [CI template tests](/architecture/ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md), [Run the CI template tests](/runbooks/runbook-run-the-ci-template-tests--01a1cf4af818.md)
