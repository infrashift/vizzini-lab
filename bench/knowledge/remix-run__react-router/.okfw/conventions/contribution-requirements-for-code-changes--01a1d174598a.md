---
id: "01a1d174-598a-71d3-a723-8ef78d757e71"
title: "Contribution Requirements for Code Changes"
type: "Guideline"
tags:
  - "testing"
  - "docs"
  - "changesets"
  - "process"
created: "2026-11-12T14:30:25-06:00"
timestamp: "2026-11-12T14:30:25-06:00"
description: "Every bug fix or feature needs tests, API changes must update docs and examples, and code changes need a changeset and target the dev branch."
x:
  paths: ["packages/**", "integration/**", ".changeset/*.md"]
  source: ["CONTRIBUTING.md", "docs/community/contributing.md", "DEVELOPMENT.md", ".changeset/fetcher-reset.md"]
---

# Contribution Requirements for Code Changes

These are the rules React Router's contributing guide states for any pull request that touches code.

## Tests are mandatory

- "All commits that fix bugs or add features need one or more tests." The guide is blunt: "Do not merge code without tests!"
- For bugs, the preferred form of a report is a pull request with a failing test, using the integration bug-report test (`integration/bug-report-test.ts`) as the starting point. A reviewer should expect a fix to come with a test that would have failed before it.
- Tests run after a full build (`pnpm build` then `pnpm test`); packages are built together because they depend on one another. A single package can be tested with `pnpm test packages/<package-name>/`.

## Docs and examples move with the API

- "All commits that change or add to the API must be done in a pull request that also updates all relevant examples and docs." Documentation lives in `docs/`. A PR that adds or changes a public API without touching the relevant docs is incomplete by this rule.

## Changesets

- DEVELOPMENT.md says that when changes are made to the codebase, "an accompanying changeset file should be included to document the change". Changesets drive package versioning and changelog content.
- A changeset names the affected package(s) and bump type and gives a one-line user-facing description, for example `"react-router": patch`. Unstable additions are described with an `[UNSTABLE]` prefix in the changeset text.

## Branch and tooling

- New features, bug fixes, and anything touching `react-router` code branch from and target `dev`; documentation-only changes and new examples target `main`.
- The repo uses pnpm workspaces; installing with npm generates unnecessary `package-lock.json` files, so such files should not appear in a PR.

## New features start as proposals

"Please do not start with a PR for a new feature." New or changed API goes through the governance proposal process first (see the API stability concept). A feature PR without a prior proposal is not the expected path.
