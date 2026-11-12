---
id: "01a1d175-0187-71fa-8d96-70db76915fd1"
title: "Coding style and PR scope"
type: "Guideline"
tags:
  - "style"
  - "review"
  - "pull-requests"
created: "2026-11-12T14:31:08-06:00"
timestamp: "2026-11-12T14:31:08-06:00"
description: "Avalonia follows the .NET Core coding style, bans #region, wants XML docs on public methods, and rejects unrelated or formatting-only changes inside a PR."
x:
  paths: ["src/**", "tests/**"]
  source: ["CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md"]
---

# Coding style and PR scope

## Style rules stated in CONTRIBUTING.md

- The codebase uses the **.NET Core coding style** (the dotnet/runtime coding-style guidelines).
- Keep lines at about **120 characters** or fewer. This is not a hard limit; being a few characters over is fine.
- **Public methods should have XML documentation.** The PR template checklist also asks whether XML documentation was added to related classes.
- Prefer terseness to verbosity, but don't try to be too clever.
- **DO NOT USE `#region`**, "full stop". Any `#region` in a change should be flagged.
- Test methods use sentence-style underscore names instead of the usual naming convention (see [Testing expectations](./testing-expectations-for-bug-fixes-and-features--01a1d1750163.md)).

## Keep the diff focused

The contribution guide is explicit that a PR should only contain changes for its bug fix or feature:

- **Do not** change code unrelated to the bug fix or feature.
- **Do not** introduce spurious formatting or whitespace changes.
- Don't fix style issues you happen to see. The guide gives three reasons: they distract the reviewer, they make blame and bisect harder when tracking down later problems, and style issues get resolved anyway as the code churns.
- Separate PRs that only fix style may be accepted, but only if agreed with the core team in advance.

## Commits and description

- Rebase to remove extraneous commits so the history tells a clean story of how the change was built, and write meaningful commit messages.
- A good PR description is required. Without one the PR will at least be delayed and may be closed. The template sections (what the PR does, current and expected behaviour, how it was implemented, breaking changes, obsoletions) are guidance and can be dropped when they don't apply.
- Behavioural breaking changes must be called out in the description (see [API compatibility](./api-and-binary-compatibility-within-a-major-version--01a1d1750140.md)).

## Features need agreement first

Features should be discussed with the core team in an issue before a PR is opened, so the team is on board before work starts. A large feature PR with no prior discussion is worth pointing out.
