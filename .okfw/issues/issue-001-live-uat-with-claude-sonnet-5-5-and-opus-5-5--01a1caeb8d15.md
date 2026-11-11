---
id: "01a1caeb-8d15-7d35-a43a-48f18a171ef0"
title: "ISSUE-001: Live UAT with Claude Sonnet 5.5 and Opus 5.5"
type: "issue"
tags:
  - "issue"
  - "closed"
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
- [x] Vizzini `pkg/risk` exposes typed findings (Vizzini ISSUE-017, b8c014e)
- [x] mrman shows Vizzini findings and can promote one to a draft comment (`--vizzini-report`, mrman 836f5b3 on feature/vizzini-findings)
- [x] Forge leg scripted (uat/forge.sh) and run against ADO: PR per model, mrman headless session, human-granted submit, threads verified over REST
- [x] `litellm.sh smoke` passes for both models
- [x] `make uat` passes all hard checks for Sonnet 5.5 and Opus 5.5; the comparison is recorded here

## Resolution (2026-11-11, run 20261111T142959Z)
**86/86 hard checks passed** for `claude-sonnet-5-5` and `claude-opus-5-5` through LiteLLM v1.99.4 in podman. The forge leg ran on Azure DevOps (`scratch/vizzini-scratch`, PRs #4 and #5): mrman's headless session carried every finding, a person granted submit in the TUI, and every finding was posted as an inline thread. The full summary is in vizzini-uat `results/2026-11-11-live-sonnet-opus-5-5.md`.

| | Sonnet 5.5 | Opus 5.5 |
|---|---|---|
| Seeded defects caught | 9/9 | 9/9 |
| Category agreement | 100% | 100% |
| Findings (Critical/Major/Minor/Trivial) | 12 (4/6/1/1) | 14 (4/6/3/1) |
| Architecture findings citing the right ADR | 3 | 4 |
| Findings on the clean decoy | 0 | 0 |
| Risk (final/diff/model) | 95/49/95 | 95/49/95 |
| garmr | deny VZ-001, VZ-002, VZA-001 | same |
| Review / describe / improve / plan | 34s / 10s / 26s / 20s | 26s / 8s / 16s / 24s |
| ADO inline threads | 12 | 14 |

- **Real-world commits.** The large serilog commit took 2 chunks with both models. Both independently flagged a real bug: `SelfLogFailureListener` passes an interpolated string to `string.Format` with no arguments, so braces in the message or the exception text throw `FormatException`. Opus reported more Major findings (4 vs 1). The small serilog fix got 0 findings from both models, and the Polly change got 1–2 Minor/Trivial findings.
- **Unmatched findings.** The only finding outside the ground truth was CA1822 (Trivial), which echoes Roslyn.
- **Transport.** The repair loop never gave up. JSON mode through LiteLLM came back as bare JSON for both models.
- **Ground-truth fix.** The fixture now also accepts Architecture for `async void`, `.Result` and disposal, because the fixture's own ADR-0002 governs those rules.

### Follow-ups
- The risk score's complexity term is Go-only: C# files report `complexity_delta: 0`.
- Knowledge grounding matches only Go `package` clauses. C# namespaces need `x.paths` globs.
- Before mrman's branch can merge, Vizzini must be pushed and mrman's `go.mod` bumped.

## TypeScript fixture (2026-11-11, run 20261111T150647Z)
The seeded TypeScript fixture (Vizzini ISSUE-018) passed **46/46 hard checks**. Sonnet 5.5 and Opus 5.5 each caught 10/10 defects with 0 decoy findings, posting 11 and 15 ADO threads (PRs #6 and #7). Results are in `results/2026-11-11-live-typescript-sonnet-opus-5-5.md`.
