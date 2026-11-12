---
id: "01a1cf70-a61d-73d9-bc50-dce95a7e5454"
title: "TS-CIGL: GitLab CI template"
type: "Test Suite"
tags:
  - "uat"
  - "test-suite"
  - "ts-cigl"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Vizzini's GitLab CI template on a throwaway self-managed GitLab CE in podman: denied, allowed for a Reporter token's bot user, then incremental with a /vizzini command answered and a removed file's discussion resolved."
---

# TS-CIGL: GitLab CI template

- **Command:** `make uat-ci-gitlab`
- **Tokens:** No (stubllm in the job)
- **Attended:** No
- **Plan:** [UAT test plan](/test-suites/uat-test-plan--01a1cf70a5f6.md)

## Scope
The template's install step, the self-managed host entry, the grant policy from the base branch, a project access token as the posting identity, and incremental review.

## Remote changes
None. GitLab CE and the runner run in podman on this machine.

## Preconditions
- The podman user socket is active: `systemctl --user is-active podman.socket` shows `active`.
- The disk has at least 6 GB free, and the machine has at least 8 GB of free memory.
- `make build` completes without errors.

## Execution
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make uat-ci-gitlab`. | The output shows `run: <run>`, then `GitLab gitlab-ce 19.5.1 ready`. |
| 2 | Write down the `<run>` path. | You have the run directory for all cases in this suite. |
| 3 | Wait for the run to stop. | The output shows `result: PASS` or `result: FAIL`, then the cleanup lines. |

## Test cases
| ID | Title | Priority |
|---|---|---|
| [UAT-CIGL-001](/test-suites/ci-gitlab/uat-cigl-001-the-first-job-is-denied-and-names-the-bot-user--01a1cf70a73e.md) | The first job is denied and names the bot user | High |
| [UAT-CIGL-002](/test-suites/ci-gitlab/uat-cigl-002-the-allowed-bot-user-posts-a-discussion--01a1cf70a748.md) | The allowed bot user posts a discussion | High |
| [UAT-CIGL-003](/test-suites/ci-gitlab/uat-cigl-003-an-incremental-job-answers-the-command-and-resolves-a-removed-file--01a1cf70a753.md) | An incremental job answers the command and resolves a removed file's finding | High |
| [UAT-CIGL-004](/test-suites/ci-gitlab/uat-cigl-004-the-run-leaves-nothing-in-podman--01a1cf70a760.md) | The run leaves nothing in podman | Medium |

## After the run
None. The script removes the containers, volumes and network.

## Traces to
[ADR-0008](/decisions/adr-0008-gitlab-ci-runs-on-a-throwaway-self-managed-gitlab-ce-in-podman--01a1cf4af8e3.md), [CI template tests](/architecture/ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md), [Run the CI template tests](/runbooks/runbook-run-the-ci-template-tests--01a1cf4af818.md)
