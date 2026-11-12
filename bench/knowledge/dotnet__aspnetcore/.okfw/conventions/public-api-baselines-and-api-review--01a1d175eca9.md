---
id: "01a1d175-eca9-7c17-9730-18cbc584fc42"
title: "Public API baselines and API review"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "review"
created: "2026-11-12T14:32:08-06:00"
timestamp: "2026-11-12T14:32:08-06:00"
description: "Every public API addition, removal or change must be recorded in PublicAPI.Unshipped.txt and go through the API review process before it is implemented."
x:
  paths: ["src/**/PublicAPI.Unshipped.txt", "src/**/PublicAPI.Shipped.txt", "src/**/src/**/*.cs"]
  source: ["docs/APIBaselines.md", "docs/APIReviewProcess.md", "docs/APIReviewPrinciples.md", ".github/prompts/ApiReview.prompt.md", "docs/AddingNewProjects.md", ".github/copilot-instructions.md"]
---

# Public API baselines and API review

Public API analyzers are enabled by default for implementation (`src`) projects, so the public surface of every shipping assembly is tracked in two baseline files next to the project.

## The two baseline files

- **`PublicAPI.Shipped.txt`** lists APIs released in the last major version. It "should only be modified after a major release by the build team and should never be modified otherwise." A PR that edits a Shipped file is a red flag.
- **`PublicAPI.Unshipped.txt`** lists APIs added since the last major version. Every public API change in a PR should show up here:
  - A new API gets a new line.
  - A removed API gets a `*REMOVED*` line.
  - An updated API (including a change in nullability annotations) gets two lines: a `*REMOVED*` entry for the old signature and an entry for the new one.

New `src` projects must add both files (copied from `eng/PublicAPI.empty.txt`). Non-shipping or test-only projects instead set `<AddPublicApiAnalyzers>false</AddPublicApiAnalyzers>`.

## Suppressing analyzer warnings

When an API analyzer warning (for example RS0026 or RS0027) has to be suppressed, the docs ask for a `[SuppressMessage(...)]` attribute with a `Justification`, "not globally or with `#pragma`s because attributes make the justification obvious."

## API review comes first

The API review process starts as soon as an issue's owner sees that the work needs an API change or addition. The proposal is labeled `api-suggestion`, then `api-ready-for-review`, and the work is implemented only after it is `api-approved`. The proposal states the API in ref-assembly format and covers motivation, usage examples, alternative designs and risks: breaking changes, performance regressions, security concerns and potential for misuse. "In case during implementation changes to the original proposal are required, the review should become obsolete and the process should start from the beginning." So a PR whose `PublicAPI.Unshipped.txt` diff differs from the approved shape needs another review.

The repo's own API principles document is still a placeholder. For general guidance it points to the .NET Framework Design Guidelines.

## Docs on public APIs

The repo's coding instructions require XML doc comments on any public API, with `<example>` and `<code>` where they apply. The PR template also asks for inline docs where applicable.
