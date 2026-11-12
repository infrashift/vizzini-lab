---
id: "01a1d173-318c-7b50-9306-99f724483994"
title: "CLI, chart and file-format compatibility"
type: "Guideline"
tags:
  - "cli"
  - "compatibility"
  - "charts"
created: "2026-11-12T14:29:09-06:00"
timestamp: "2026-11-12T14:29:09-06:00"
description: "Commands, flags, arguments, file formats such as Chart.yaml, chart behaviour and chart repository functionality must stay backward compatible within a major version."
x:
  paths: ["cmd/helm/**", "pkg/cmd/**", "pkg/chart/**", "pkg/repo/**", "pkg/registry/**", "pkg/engine/**"]
  source: ["AGENTS.md", "CONTRIBUTING.md"]
---

# CLI, chart and file-format compatibility

Beyond the Go SDK, Helm's compatibility promise covers everything a user or a script relies on. `CONTRIBUTING.md` says "all of our changes to protocols and formats are backward compatible from one major release to the next" and "no features, flags, or commands are removed or substantially modified (unless we need to fix a security issue)."

**What must stay compatible** (from the summary of the guidelines in `CONTRIBUTING.md`):

- Command line commands, flags and arguments MUST be backward compatible. `AGENTS.md` puts it as: "CLI commands and parameters should not be removed or changed in a way that would break existing scripts or workflows."
- File formats, such as `Chart.yaml`, MUST be backward compatible.
- Any chart that worked on a previous version MUST work on a new version, barring cases where Kubernetes itself changed or the chart only worked because it exploited a bug.
- Chart repository functionality MUST be backward compatible.

**Exception**

As for the Go API, minimal breaking changes are allowed when they are needed to fix a security vulnerability.

**What a reviewer should look for**

- Removed or renamed flags, changed flag defaults, or changed argument handling in `pkg/cmd/` or `cmd/helm/`.
- Changes to how charts are parsed, validated or rendered (`pkg/chart`, `pkg/engine`) that would reject or render differently a chart that worked before.
- Changes to repository index handling or OCI registry interaction (`pkg/repo`, `pkg/registry`) that could break existing repositories.
- User-facing changes should be documented. Docs live in a separate website repository; small user-facing PRs get a `docs needed` label (it does not block merging), and the pull request template asks whether the PR "contains user facing changes".

Helm v3 is maintained on a separate `dev-v3` branch that no longer accepts new features; bugs are fixed on v4 first and then backported where applicable.
