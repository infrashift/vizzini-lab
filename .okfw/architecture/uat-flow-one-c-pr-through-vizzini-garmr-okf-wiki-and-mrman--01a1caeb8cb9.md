---
id: "01a1caeb-8cb9-7491-b359-6d26b3148510"
title: "UAT flow: one C# PR through Vizzini, garmr, okf-wiki and mrman"
type: "Architecture"
tags:
  - "architecture"
  - "overview"
created: "2026-11-11T08:03:17-06:00"
timestamp: "2026-11-11T08:03:17-06:00"
description: "What the UAT runs, in order, and which tool each step proves."
---

# UAT flow: one C# PR through Vizzini, garmr, okf-wiki and mrman

# UAT flow

`uat/run.sh` drives one seeded C# change through all four tools, once per model in `MODELS` (`versions.env`):

1. **Build**: `uat/build.sh` clones Vizzini, mrman, garmr and okf-wiki at their pinned SHAs into `.cache/src` and builds static binaries. mrman is built against the pinned Vizzini through `go.work`. See [ADR-0001](/decisions/adr-0001-a-dedicated-uat-repo-that-builds-every-tool-from-a-pinned-sha--01a1caeb8cd0.md).
2. **Model**: the LiteLLM proxy in podman (`litellm/`) fronts Anthropic. `--stub` swaps in Vizzini's `stubllm` instead.
3. **Fixture**: `uat/fixture.sh` turns `fixtures/csharp-seeded/{base,change}` into a two-commit repository, a patch, and real Roslyn SARIF from `dotnet build` in the .NET SDK container.
4. **okf-wiki**: `okfw validate` runs over the fixture's `.okfw/`, the knowledge base Vizzini grounds on (two ADRs that apply, one runbook that must never be selected).
5. **Vizzini**: review (with Roslyn SARIF and `--knowledge`), describe, improve, and plan (`--okf-index`).
6. **garmr**: validates and tests Vizzini's policy pack, then evaluates each review locally. A review with Critical or Major findings must be denied by VZ-001.
7. **Forge**: an Azure DevOps PR per model. mrman opens it headlessly with the Vizzini report, and the findings are posted as review threads after a human grants submit. See [ADR-0002](/decisions/adr-0002-the-mrman-submit-grant-stays-a-human-step--01a1caeb8ce7.md).
8. **Real-world commits**: the pins in `fixtures/csharp-oss.txt` (serilog, Polly) go through review, describe and garmr.
9. **Score**: `uat/score.py` writes `summary.md` and `scores.json`. Hard checks fail the run; quality metrics are only reported.

This is `make uat`. The other suites (the unattended bot test and the CI template tests) are in the [suite map](/architecture/suite-map-what-each-make-target-proves--01a1cf4af86d.md); how to run this one is in [run the live UAT](/runbooks/runbook-run-the-live-uat--01a1cf4af7f5.md).
