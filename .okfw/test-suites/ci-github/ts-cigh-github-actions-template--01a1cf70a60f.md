---
id: "01a1cf70-a60f-7bd5-9590-349327efd491"
title: "TS-CIGH: GitHub Actions template"
type: "Test Suite"
tags:
  - "uat"
  - "test-suite"
  - "ts-cigh"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "Vizzini's GitHub Actions template on a throwaway PR in infrashift/vizzini-lab: the denied first run, the allowed identity, and the incremental second commit."
---

# TS-CIGH: GitHub Actions template

- **Command:** `make uat-ci-github`
- **Tokens:** No (stubllm in the job)
- **Attended:** No
- **Plan:** [UAT test plan](/test-suites/uat-test-plan--01a1cf70a5f6.md)

## Scope
The template's install step, the grant policy from the base branch, `GITHUB_TOKEN` as the posting identity, and incremental review.

## Remote changes
One PR and two `ci/` branches in infrashift/vizzini-lab. The script closes and deletes them.

## Preconditions
- `gh` is signed in with the `repo` and `workflow` scopes.
- `make build` completes without errors.

## Execution
| Step | Action | Expected result |
|---|---|---|
| 1 | Run `make uat-ci-github`. | The output shows `run: <run>` and `PR: <url>`. |
| 2 | Write down the `<run>` path and the PR URL. | You have the evidence for all cases in this suite. |
| 3 | Wait for the run to stop. | The output shows `result: PASS` or `result: FAIL`, then the cleanup lines. |

## Test cases
| ID | Title | Priority |
|---|---|---|
| [UAT-CIGH-001](/test-suites/ci-github/uat-cigh-001-the-first-run-is-denied-and-names-the-identity--01a1cf70a6fa.md) | The first run is denied and names the identity | High |
| [UAT-CIGH-002](/test-suites/ci-github/uat-cigh-002-the-allowed-identity-posts-review-comments--01a1cf70a702.md) | The allowed identity posts review comments | High |
| [UAT-CIGH-003](/test-suites/ci-github/uat-cigh-003-a-second-commit-is-reviewed-incrementally--01a1cf70a70b.md) | A second commit is reviewed incrementally | High |
| [UAT-CIGH-004](/test-suites/ci-github/uat-cigh-004-the-run-leaves-no-pr-or-branch--01a1cf70a713.md) | The run leaves no PR or branch | Medium |

## After the run
None. The script closes the PR and deletes the branches.

## Traces to
[ADR-0006](/decisions/adr-0006-ci-template-tests-run-stubllm-inside-the-job--01a1cf4af8c2.md), [CI template tests](/architecture/ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md), [Run the CI template tests](/runbooks/runbook-run-the-ci-template-tests--01a1cf4af818.md)
