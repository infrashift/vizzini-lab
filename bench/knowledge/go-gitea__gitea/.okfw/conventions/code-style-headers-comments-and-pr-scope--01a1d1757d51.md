---
id: "01a1d175-7d51-7178-a159-13f68695f57b"
title: "Code Style, Headers, Comments and PR Scope"
type: "Guideline"
tags:
  - "style"
  - "formatting"
  - "comments"
  - "pull-requests"
  - "review"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Project-stated style rules a reviewer can check on any change: make fmt and lint, the MIT copyright header on new files, comment preservation and style, Conventional Commits titles, and small single-purpose PRs."
x:
  paths: ["cmd/**", "models/**", "modules/**", "routers/**", "services/**", "web_src/js/**"]
  source: ["CONTRIBUTING.md", "AGENTS.md", ".github/pull_request_template.md", "docs/community-governance.md"]
---

# Code Style, Headers, Comments and PR Scope

## Formatting and linting

- Always run `make fmt` before committing "to conform to Gitea's styleguide". AGENTS.md repeats this for `.go` files and adds `make lint-go` for Go and `make lint-js` for TypeScript.
- CONTRIBUTING.md lists `make lint` (everything), `make lint-frontend` and `make lint-backend`.
- Edited files must not contain trailing whitespace.

## Copyright header

New code files must use the standard header, with the current year:

```
// Copyright <current year> The Gitea Authors. All rights reserved.
// SPDX-License-Identifier: MIT
```

After that, the copyright line should only be modified when the copyright author changes. A reviewer should flag new `.go` files without this header, and edits that bump the year on existing files without an author change.

## Comments

AGENTS.md states:

- Preserve existing code comments; do not remove or rewrite comments that are still relevant.
- Keep comments short, prefer same-line comments, explain *why*, and never narrate code.

## PR scope and titles

- Make small pull requests, and split big ones into several smaller ones.
- "Don't make changes unrelated to your PR." Typo fixes or refactors outside the PR's purpose belong in another PR.
- PR titles follow Conventional Commits, `type(scope)!: subject`, because PRs are squash-merged and the title becomes the commit message. Allowed types: `build`, `ci`, `chore`, `docs`, `feat`, `enhance`, `fix`, `perf`, `refactor`, `revert`, `style`, `test`. Test-only changes use `test`.
- The title describes the problem being fixed, not how it is fixed.
- PRs that change the UI must include "after" screenshots (and "before" screenshots unless it is a new feature). Feature PRs need a usage description and a testing description.
- PRs target `main`; release branches are for backports only.
- Significant changes such as new features should go through the change proposal process first; "Pull requests should not be the place for architecture discussions."

## AI-assisted contributions

CONTRIBUTING.md requires that AI assistance be disclosed, that AI-generated code be reviewed and manually tested by the contributor, and that the contributor be able to explain and defend the change. Maintainers may close PRs that do not disclose AI use or that the author cannot defend.

## For reviewers

The governance guide asks reviewers to verify that the PR description accurately reflects the changes, that tests and documentation are complete and aligned with the implementation, and to give actionable feedback that separates required changes from optional suggestions.
