---
id: "01a1cf70-a5f6-7318-afbd-0fe8571c851b"
title: "UAT test plan"
type: "Test Plan"
tags:
  - "uat"
  - "test-plan"
created: "2026-11-12T05:07:08-06:00"
timestamp: "2026-11-12T05:07:08-06:00"
description: "The vizzini-uat test plan: the six test suites, how a tester runs each one, how to record a result, and the entry and exit criteria."
---

# UAT test plan

This plan lists the UAT suites for vizzini-uat. A tester runs a suite, then does each test case and examines the observable results.

## Suites
| Suite | Name | Command | Cases | Tokens | Attended |
|---|---|---|---|---|---|
| [TS-REV](/test-suites/review/ts-rev-live-review--01a1cf70a5fc.md) | Live review | `make uat-vizzini` | 11 | Yes (live models) | No |
| [TS-FRG](/test-suites/forge/ts-frg-forge-and-mrman-attended--01a1cf70a603.md) | Forge and mrman (attended) | `make uat` | 6 | Yes (live models) | Yes |
| [TS-BOT](/test-suites/bot/ts-bot-unattended-bot--01a1cf70a609.md) | Unattended bot | `make uat-bot-stub` | 9 | No with `uat-bot-stub`. Yes with `uat-bot`. | No |
| [TS-CIGH](/test-suites/ci-github/ts-cigh-github-actions-template--01a1cf70a60f.md) | GitHub Actions template | `make uat-ci-github` | 4 | No (stubllm in the job) | No |
| [TS-CIADO](/test-suites/ci-ado/ts-ciado-azure-pipelines-template--01a1cf70a616.md) | Azure Pipelines template | `make uat-ci-ado` | 4 | No (stubllm in the job) | No |
| [TS-CIGL](/test-suites/ci-gitlab/ts-cigl-gitlab-ci-template--01a1cf70a61d.md) | GitLab CI template | `make uat-ci-gitlab` | 4 | No (stubllm in the job) | No |
| [TS-HOOK](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md) | Webhook receiver (experimental) | `make uat-webhook` | 10 | No (stubllm) | No (UAT-HOOK-010 is manual) |

## How to run a suite
1. Do the steps in the suite's *Execution* section.
2. Write down the run directory (`<run>`) that the first output line shows.
3. Do each test case of the suite in order.
4. Compare each result with the *Expected result*.
5. Write the result in the test case's *Record* table.

## Result values
| Value | Meaning |
|---|---|
| PASS | All expected results occur. |
| FAIL | One or more expected results do not occur. Write the step number and the observed result in *Notes*. |
| BLOCKED | A precondition is not true. Write the precondition in *Notes*. |

## Build identity
Write the build in each record as the short commit of vizzini-uat: `git rev-parse --short HEAD`. `.cache/bin/build-manifest.json` gives the tool commits for that build.

## Entry criteria
- The [first-time setup](/runbooks/runbook-first-time-setup--01a1cf4a8f24.md) is complete.
- `make lint` passes.
- `make uat-stub` passes. It needs no tokens.

## Exit criteria
- All High cases pass in each suite that the release touches.
- Each FAIL has an issue in `.okfw/issues/` or a fix.

## Defects
A FAIL is a defect in a tool or in the harness. Write an issue with the case ID, the build and the run directory. Do not change a case or a check to make it pass (CLAUDE.md rule 4).

## Related
- [Suite map](/architecture/suite-map-what-each-make-target-proves--01a1cf4af86d.md): what each suite proves.
- [Troubleshooting](/runbooks/runbook-troubleshooting--01a1cf4af84b.md): known failures and fixes.
- [Cleanup](/runbooks/runbook-clean-up-after-an-interrupted-run--01a1cf4af83a.md): what an interrupted run leaves.
