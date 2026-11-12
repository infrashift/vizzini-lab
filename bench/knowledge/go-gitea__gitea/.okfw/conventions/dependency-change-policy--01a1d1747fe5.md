---
id: "01a1d174-7fe5-7ee9-9e15-69a6a611426e"
title: "Dependency Change Policy"
type: "Guideline"
tags:
  - "dependencies"
  - "go-modules"
  - "frontend"
  - "review"
created: "2026-11-12T14:30:35-06:00"
timestamp: "2026-11-12T14:30:35-06:00"
description: "go.mod/go.sum and frontend package manifests may change only when tied to the PR's purpose or in dependency-only PRs, and every update must be justified and point at a real upstream commit or version."
x:
  paths: ["go.mod", "go.sum", "package.json", "pnpm-lock.yaml"]
  source: ["docs/guideline-backend.md", "docs/guideline-frontend.md", "AGENTS.md", "CONTRIBUTING.md"]
---

# Dependency Change Policy

The backend and frontend guidelines set the same policy for dependency manifests.

## Go dependencies

Go dependencies are managed with Go Modules. The backend guideline states:

- Pull requests should only modify `go.mod` and `go.sum` where it is related to the change, whether a bug fix or a feature.
- Apart from that, these files should only be modified by pull requests whose **only** purpose is to update dependencies.
- The `go.mod`/`go.sum` update must be justified in the PR description.
- Reviewers and/or the merger must verify that the update always references an existing upstream commit.

AGENTS.md adds a mechanical rule: run `make tidy` after any `go.mod` change. A reviewer can therefore expect `go.sum` to be consistent with `go.mod` in the same PR.

## Frontend dependencies

The frontend guideline says the same restrictions apply to frontend dependencies, with two differences: the files involved are the package manifest and lockfile (the guideline names `package.json` and `package-lock.json`; the repository tree contains `package.json` and `pnpm-lock.yaml`), and new versions must always reference an existing published version.

## What a reviewer should check

- A feature or fix PR that bumps unrelated modules or packages violates the policy; unrelated bumps belong in a separate dependency-only PR. This matches the general CONTRIBUTING.md rule "Don't make changes unrelated to your PR."
- Any manifest change needs a justification in the PR description.
- Replaced or pinned Go module versions should resolve to a real upstream commit, not a fork-only or nonexistent revision.
- Security-related dependency updates are titled with the `fix` type under the project's Conventional Commits list; general build or external-dependency changes use `build`.
