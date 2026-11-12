---
id: "01a1d174-302e-7bf6-ad72-123564c90357"
title: "Public API changes, compatibility and commit messages"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "breaking-changes"
  - "branches"
  - "commits"
created: "2026-11-12T14:30:15-06:00"
timestamp: "2026-11-12T14:30:15-06:00"
description: "New API surface targets the minor branch and needs strong justification, runtime behavior breakage is avoided above all else, and breaking changes are declared in the commit footer."
x:
  paths: ["packages/*/src/index.ts", "packages/*/src/**", "packages/vue/**", "scripts/verify-commit.js"]
  source: [".github/contributing.md", ".github/maintenance.md", "AGENTS.md", ".github/commit-convention.md"]
---

# Public API changes, compatibility and commit messages

**Which branch a change belongs on**

- `main`: bug fixes and refactors or chores that do not affect the public API.
- `minor`: new features and any change that affects public API or behavior.

A reviewer should flag a PR whose content does not match its branch, for example a fix that quietly adds API surface.

**Adding API surface**

- Vue already has a large API surface; new features must address a clearly explained, widely applicable use case. If the need is niche and can be solved in userland, it likely does not belong in core. Always ask whether existing APIs already cover it.
- Weigh added complexity against benefit: a small feature that needs changes spread across the codebase should be reconsidered.
- Significant additions need an RFC first: a new built-in component or directive definitely does; template syntax additions (a new `v-on` modifier, new `v-bind` sugar) ideally do, or at least need a detailed design rationale in the PR; small additions such as a new utility type or app config option still need clear context.
- Changes to public API, compiler output or type declarations should explain their trade-offs.

**Breakage**

- Avoiding runtime behavior breakage is the highest priority. When unsure, maintainers use ecosystem-ci to check impact on downstream projects.
- Some fixes inevitably change behavior; these are discussed case by case.
- Type-level breakage (for example from a TypeScript upgrade) is possible between minors.

**Commit messages** (validated by `scripts/verify-commit.js`)

- Header format `<type>(<scope>): <subject>`, matching the documented regex; types are `feat`, `fix`, `docs`, `dx`, `style`, `refactor`, `perf`, `test`, `workflow`, `build`, `ci`, `chore`, `types`, `wip`. Scope is optional and names the area (`core`, `compiler`, `ssr`, `v-model`, ...).
- Subject: imperative present tense, no capital first letter, no trailing period. The body explains the motivation and contrasts with previous behavior.
- `feat`, `fix` and `perf` appear in the changelog. Any breaking change must be described in the footer starting with `BREAKING CHANGE:` and then always appears in the changelog. Reverts use `revert: <original header>` with `This reverts commit <hash>.` in the body.
