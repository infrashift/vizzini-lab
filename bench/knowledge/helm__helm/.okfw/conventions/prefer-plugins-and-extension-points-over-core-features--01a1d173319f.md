---
id: "01a1d173-319f-72e1-a281-ed4b8c583f41"
title: "Prefer plugins and extension points over core features"
type: "Guideline"
tags:
  - "architecture"
  - "extensibility"
  - "plugins"
  - "scope"
created: "2026-11-12T14:29:09-06:00"
timestamp: "2026-11-12T14:29:09-06:00"
description: "New functionality should be added through plugins and extension points where possible, and larger features need a Helm Improvement Proposal."
x:
  paths: ["internal/plugin/**", "pkg/storage/**", "pkg/engine/**", "pkg/postrenderer/**", "pkg/getter/**", "pkg/action/**"]
  source: ["AGENTS.md", "CONTRIBUTING.md"]
---

# Prefer plugins and extension points over core features

Helm's docs set limits on what goes into the core codebase. A reviewer should consider not just whether a change is correct, but whether it belongs in Helm at all.

**Plugins first**

`AGENTS.md` lists this as a key pattern: "Enabling additional functionality via plugins and extension points, such as custom template functions or storage backends is preferred over incorporating into Helm's codebase." When a PR adds a new storage backend, new template functions or similar optional functionality directly to core, check whether an existing extension point could carry it instead.

The extension points named in the docs include custom template functions (template rendering lives in `pkg/engine`) and storage backends (release backends live in `pkg/storage`, which ships Secrets, ConfigMaps and SQL backends).

**Features need a proposal**

`CONTRIBUTING.md` says issues labeled `feature` or `proposal` must have a Helm Improvement Proposal (HIP), a design document with "a concise technical specification and rationale for the feature." Smaller quality-of-life enhancements are exempt. The final word on whether a feature needs a proposal lies with the core maintainers. A large new feature that arrives as a PR without a design discussion is a reason to ask for one.

**Where changes land**

- Development happens against the `main` branch (Helm v4).
- Helm v3 (`dev-v3`) "is no longer accepting new features". Bugs should be fixed on v4 first and then backported to v3; security and bug fixes are backported where applicable.

**Review rules from the contribution guide**

- PRs from community members labeled `size/S` or larger need approval from two core maintainers; PRs by a core maintainer need one additional maintainer.
- Work-in-progress PRs must be titled "WIP: ...".
- All commits must carry a DCO `Signed-off-by` line (`git commit -s`) whose identity matches the commit author; otherwise the automated DCO check rejects the PR.
