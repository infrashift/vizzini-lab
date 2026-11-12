---
id: "01a1cf4a-f8d2-7644-aff0-77fb3dc248ca"
title: "ADR-0007: Azure Pipelines runs on a throwaway self-hosted podman agent"
type: "ADR"
tags:
  - "adr"
  - "ci"
  - "azure-devops"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "uat/ci-ado.sh runs the Azure Pipelines template on a self-hosted agent started in podman for the run, because the organization has no hosted parallelism, and grants and restores the build service's permission around it."
---

# ADR-0007: Azure Pipelines runs on a throwaway self-hosted podman agent

**Status:** Accepted
**Date:** 2026-11-12
**Related:** [CI template tests](/architecture/ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md), [cleanup](/runbooks/runbook-clean-up-after-an-interrupted-run--01a1cf4af83a.md)

## Context
- **No hosted agents:** the Azure DevOps organization has no Microsoft-hosted parallelism for private projects, and one free self-hosted parallel job.
- **A permission to grant:** the template's posting identity, `<Project> Build Service (<org>)`, cannot post on pull requests until it has *Contribute to pull requests*. That grant is part of the template's documented setup, and a test that skipped it would miss the template's real first-run failure.

## Decision
- **The agent:**
  - `ci/ado-agent` builds an agent image: Ubuntu 24.04 by digest, agent 5.281.1 checked against its published SHA-256.
  - The test starts it in podman as `vizzini-lab-<stamp>` in the `Default` pool. The PAT arrives as `VSTS_AGENT_INPUT_TOKEN` (name only on the command line).
  - The agent deregisters when stopped.
- **The pipeline:** created from the template, with the `Default` pool and the stub ([ADR-0006](/decisions/adr-0006-ci-template-tests-run-stubllm-inside-the-job--01a1cf4af8c2.md)), and authorized for that queue. A **non-blocking** build-validation policy on the throwaway base branch triggers it.
- **The permission:**
  - The test grants the build service *Contribute to pull requests* (bit 16384) on **this repository only**, through an access control entry. It saves the previous entry first.
  - The exit trap restores that entry, or deletes the new one if there was none.
- **Cleanup:** the exit trap also abandons the PR and deletes the policy, the pipeline, both branches and the agent.

## Consequences
- **Real organization state changes during a run.** The permission is the sensitive part: an interrupted run can leave it granted, so [cleanup](/runbooks/runbook-clean-up-after-an-interrupted-run--01a1cf4af83a.md) lists it first. Running the test needs the user's say-so, because it changes a permission in their organization.
- **The run is honest about the template's first run.** Without the grant, posting fails with `TF401027`; mrman v0.1.5 turns that into a hint naming the permission.
- **The PAT needs far more than *Code*:** pipelines, policies, security and agent pools.
