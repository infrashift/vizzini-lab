---
id: "01a1d173-317b-7cfc-90df-aacf50f33bb3"
title: "Package layout and layering"
type: "Guideline"
tags:
  - "architecture"
  - "go"
  - "module-boundaries"
created: "2026-11-12T14:29:09-06:00"
timestamp: "2026-11-12T14:29:09-06:00"
description: "Helm splits code into a thin CLI entry point, public SDK packages under pkg/, and private implementations under internal/, with operations living in pkg/action."
x:
  paths: ["cmd/helm/**", "pkg/**", "internal/**"]
  source: ["AGENTS.md"]
---

# Package layout and layering

Helm is a Kubernetes package manager written in Go. The codebase serves two audiences at once: an SDK for advanced users and a CLI for end users. `AGENTS.md` describes how the layers fit together, and a reviewer should check that a change puts code in the right layer.

**Layers**

- `cmd/helm/` is the CLI entry point. It only wires CLI flags to the commands in `pkg/cmd/`.
- `pkg/cmd/` holds the Cobra command implementations. They bridge CLI flags to `pkg/action/`.
- `pkg/action/` holds the core operations (install, upgrade, rollback). The docs describe high-level operations as living here, "typically using a shared Configuration".
- `pkg/` as a whole is the **public API**. Besides `action` and `cmd` it includes `chart/v2` (the stable chart format), `engine` (template rendering with Go templates and Sprig), `kube` (the Kubernetes client abstraction layer), `registry` (OCI support), `release` (release types and interfaces, `v1/` and `common/`), `repo` (chart repository indexing) and `storage` (release backends: Secrets, ConfigMaps, SQL).
- `internal/` holds private implementations, including `internal/chart/v3` (the next-generation chart format, still under development) and `internal/release/v2` (the release package for chart v3 support).

**What to check in review**

- Business logic for an operation belongs in `pkg/action/`, not in a Cobra command or in `cmd/helm/`. Commands should translate flags and call actions.
- Kubernetes access should go through the `pkg/kube` abstraction, which is also what lets action tests use mock Kubernetes clients.
- Anything placed in `pkg/` becomes public API covered by the backward-compatibility promise (see [Backward compatibility of the Go SDK](./backward-compatibility-of-the-go-sdk--01a1d1733183.md)). Code that does not need to be public belongs in `internal/`, which may change between releases without notice.
- Chart v2 is the stable format in `pkg/chart/v2`; work on chart v3 lives in `internal/chart/v3` while it is under development.

**Main dependencies** named by the docs are `k8s.io/client-go` for Kubernetes interaction, `github.com/spf13/cobra` for the CLI and `github.com/Masterminds/sprig` for template functions.
