---
id: "01a1caeb-8d15-7d35-a43a-48f18a171ef0"
title: "ISSUE-001: Live UAT with Claude Sonnet 5.5 and Opus 5.5"
type: "issue"
tags:
  - "issue"
  - "open"
  - "uat"
  - "live"
created: "2026-11-11T08:03:17-06:00"
timestamp: "2026-11-11T08:03:17-06:00"
description: "Run the full UAT against both models through LiteLLM and an Azure DevOps project, and record the comparison."
---

# ISSUE-001: Live UAT with Claude Sonnet 5.5 and Opus 5.5

## Acceptance criteria
- [x] Harness: pinned builds, LiteLLM in podman, seeded C# fixture with ground truth, Roslyn SARIF, okfw, garmr, real-world commits, scoring
- [x] `make uat-stub` passes all hard checks
- [ ] Vizzini `pkg/risk` exposes typed findings (Vizzini ISSUE-017)
- [ ] mrman shows Vizzini findings and can promote one to a draft comment (`--vizzini-report`)
- [ ] Forge leg: ADO PR per model, mrman headless session, human-granted submit, threads verified over REST
- [ ] `litellm.sh smoke` passes for both models
- [ ] `make uat` passes all hard checks for Sonnet 5.5 and Opus 5.5; the comparison is recorded here
