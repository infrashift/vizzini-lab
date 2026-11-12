---
id: "01a1d174-7a3d-7125-be75-20959a8cd600"
title: "Pull request requirements: changelog, docs and public API"
type: "Guideline"
tags:
  - "pull-requests"
  - "changelog"
  - "api"
  - "docs"
created: "2026-11-12T14:30:34-06:00"
timestamp: "2026-11-12T14:30:34-06:00"
description: "User-facing changes need a changelog_unreleased entry, API or CLI changes need docs updates, and the public API stays asynchronous."
x:
  paths: ["changelog_unreleased/**", "docs/**", "src/index.js", "src/index.d.ts", "src/cli/**", "src/document/public.js"]
  source: ["CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md", "docs/api.md", "docs/rationale.md"]
---

# Pull request requirements: changelog, docs and public API

## Checklist from the PR template

The PR template lists what a pull request should contain, and CONTRIBUTING.md warns that PRs that do not follow the template "may be closed without review":

- tests that confirm the change works;
- if the API or CLI changes, documentation of those changes in the `docs/` directory;
- if the change is user-facing, a `changelog_unreleased/*/XXXX.md` entry following `changelog_unreleased/TEMPLATE.md`.

## Changelog entries

The entry goes in the folder for the language the PR affects (`javascript/`, `typescript/` for TypeScript-only syntax, and so on); if it spans languages, pick one and say which languages it covers. The file is named after the PR number. It has a title of the form `#### Title (#XXXX by @user)`, an optional description, and a code block, marked `prettier-ignore`, showing the input, the output of "Prettier stable" and the output of "Prettier main", using the comment syntax and fence language of the affected language. `yarn generate-changelog` can generate the file.

## Linting and formatting

The project lints with ESLint and formats itself with Prettier. `yarn fix` lints and formats everything from the command line.

## Public API expectations

- "Our public APIs are all asynchronous." Synchronous use is delegated to the separate `@prettier/sync` package, so a change should not introduce synchronous variants of the public functions.
- `resolveConfig` and `resolveConfigFile` reject their promise if a configuration file fails to parse.
- The old custom parser API was removed; custom parsing goes through the Plugin API.
- Support for non-standard syntax (early proposals, Markdown extensions not in any spec) is "best-effort and experimental", and incompatibilities there "should not be viewed as breaking changes."

## AI usage policy

CONTRIBUTING.md states that contributors must only submit code they fully understand and have tested, be ready to explain it, and not ignore the issue and PR templates. "Low-quality AI content will be closed immediately." The PR template asks authors to state whether AI was used and, if so, that they reviewed the generated content.
