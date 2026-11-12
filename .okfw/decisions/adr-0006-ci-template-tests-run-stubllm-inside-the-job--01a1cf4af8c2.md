---
id: "01a1cf4a-f8c2-7226-853f-8c8ba8ad97c6"
title: "ADR-0006: CI template tests run stubllm inside the job"
type: "ADR"
tags:
  - "adr"
  - "ci"
created: "2026-11-12T04:25:59-06:00"
timestamp: "2026-11-12T04:25:59-06:00"
description: "The CI template tests replace the model with Vizzini's stubllm started inside the job, because hosted runners cannot reach the local LiteLLM and the template's wiring, not model quality, is under test."
---

# ADR-0006: CI template tests run stubllm inside the job

**Status:** Accepted
**Date:** 2026-11-11
**Related:** [CI template tests](/architecture/ci-template-tests-one-onboarding-sequence-on-three-platforms--01a1cf4af8a0.md); Vizzini ADR-0021

## Context
Vizzini's CI templates call a LiteLLM proxy through `VIZZINI_LITELLM_URL`. The UAT's proxy listens on 127.0.0.1 of this machine, which GitHub's hosted runners cannot reach. What the tests have to prove is the templates' wiring, not the model's judgment:
- install;
- the grant policy read from the base branch;
- the posting identity;
- markers, deduplication and incremental review.

The model's judgment is already measured by `make uat` and `make uat-bot` ([ADR-0010](/decisions/adr-0010-seeded-fixtures-per-language-only-must-catch-defects-are-hard--01a1cf4af906.md)).

## Decision
- Each test changes the template in one place: a step that builds Vizzini's `stubllm` from the pinned clone and starts it on `127.0.0.1:18765` with `-finding-per-file`, and points `VIZZINI_LITELLM_URL`, `VIZZINI_MODEL` and `VIZZINI_API_KEY` at it.
- The test records the exact change (`workflow.diff` or `pipeline.diff`) in the run directory.
- Changes a platform forces are listed in the script's header and the run summary. Azure needed the self-hosted `Default` pool ([ADR-0007](/decisions/adr-0007-azure-pipelines-runs-on-a-throwaway-self-hosted-podman-agent--01a1cf4af8d2.md)). GitLab first needed a mrman host entry, which has since moved into the template.

## Consequences
- **Free and deterministic:** the tests spend no tokens, and every job's findings are predictable. `-finding-per-file` gives one finding per changed file, so posting and deduplication are exact.
- **Model behavior in CI is untested.** A model-specific failure inside a CI job, such as a timeout or a long response, would surface only in a real adopter's pipeline.
