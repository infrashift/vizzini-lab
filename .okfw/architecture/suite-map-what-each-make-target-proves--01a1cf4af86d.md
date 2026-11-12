---
id: "01a1cf4a-f86d-7a3f-a87d-b07f173ad73c"
title: "Suite map: what each make target proves"
type: "Architecture"
tags:
  - "architecture"
  - "overview"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "The vizzini-uat suites, what each one exercises, what it needs, and what it touches outside this machine."
---

# Suite map: what each make target proves

| target | proves | model | needs | touches remotely |
|---|---|---|---|---|
| `make uat-stub` | the harness itself: build, fixtures, SARIF, okfw, Vizzini review, garmr, scoring | stubllm | podman | nothing |
| `make uat-vizzini` | review, describe, improve and plan quality on both fixtures and the real-world commits; garmr decisions | live | LiteLLM | Anthropic, through LiteLLM |
| `make uat` | everything in `uat-vizzini`, plus mrman showing and posting the findings on ADO after a human grant ([flow](/architecture/uat-flow-one-c-pr-through-vizzini-garmr-okf-wiki-and-mrman--01a1caeb8cb9.md)) | live | LiteLLM, ADO, a person | ADO PRs and threads |
| `make uat-bot` / `uat-bot-stub` | vizzini-bot unattended under a garmr policy: memory, incremental review, commands, suppression ([ADR-0004](/decisions/adr-0004-the-unattended-leg-authorizes-by-policy-deny-first--01a1cbfe4052.md), [ADR-0005](/decisions/adr-0005-memory-legs-rerun-and-fix-on-the-same-pr--01a1cc2b9471.md)) | live or stub | ADO | one ADO PR, left open |
| `make uat-ci-github` | Vizzini's GitHub Actions template, end to end | stub in the job | gh | a PR and branches in infrashift/vizzini-uat |
| `make uat-ci-ado` | the Azure Pipelines template | stub in the job | ADO PAT | pipeline, policy, permission, agent, PR (all removed) |
| `make uat-ci-gitlab` | the GitLab CI template on a self-managed instance | stub in the job | podman socket | nothing |
| `make uat-webhook` | the experimental webhook receiver: authentication, filtering, an answer with no push, answer-once, commands only, policy denial ([TS-HOOK](/test-suites/webhook/ts-hook-webhook-receiver-experimental--01a1cf9317e2.md), [ADR-0012](/decisions/adr-0012-the-webhook-test-delivers-locally-with-events-built-from-real-azure-devops-data--01a1cf935aa6.md)) | stub (or live) | ADO PAT | one ADO PR (abandoned at the end) |
| `make uat-workflow` | the full review workflow: a person or an agent fixes, defends or disputes; a person settles; the agent cannot resolve, approve or grant itself ([TS-WF](/test-suites/workflow/ts-wf-full-review-workflow--01a1cfa4f447.md)) | stub | ADO PAT (optional second account) | one ADO PR (abandoned at the end) |
| `make lint` | scripts, `score.py` and this wiki are well formed | — | shellcheck, okfw | nothing |

The CI tests share one sequence; see [CI template tests](/architecture/ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md). How to run each suite: [live UAT](/runbooks/runbook-run-the-live-uat--01a1cf4af7f5.md), [bot](/runbooks/runbook-run-the-unattended-bot-test--01a1cf4af807.md), [CI templates](/runbooks/runbook-run-the-ci-template-tests--01a1cf4af818.md).

Test cases a tester can do step by step, with the observable results, are in the [UAT test plan](/test-suites/uat-test-plan--01a1cf70a5f6.md).
