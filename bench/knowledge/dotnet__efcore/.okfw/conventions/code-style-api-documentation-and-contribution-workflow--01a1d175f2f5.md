---
id: "01a1d175-f2f5-726f-a9c6-668eb02b4134"
title: "Code style, API documentation and contribution workflow"
type: "Guideline"
tags:
  - "style"
  - "documentation"
  - "process"
  - "csharp"
created: "2026-11-12T14:32:10-06:00"
timestamp: "2026-11-12T14:32:10-06:00"
description: "EF Core changes must follow the patterns and style of existing code, document every public member, and start from an issue discussed with the team."
x:
  paths: ["src/**", "test/**"]
  source: [".github/CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md", "docs/getting-and-building-the-code.md", "src/EFCore/PACKAGE.md"]
---

# Code style, API documentation and contribution workflow

The EF Core docs state few explicit style rules. What they do require:

**Follow existing patterns**

"Make appropriate code and test changes. Follow the patterns and code style that you see in the existing code." The pull request template repeats this as a checkbox: "Code follows the same patterns and style as existing code in this repo." The docs do not spell out a separate style guide, so a reviewer should compare new code with its neighbours.

**Public API documentation is required**

"By default, the EF build requires API documentation for all public members." Contributors can switch this off locally with a `DeveloperBuild` property while working, but the normal build enforces it. New or changed public members without XML documentation will fail the build. API documentation lives in this repository; conceptual documentation lives in a separate docs repository.

**Build with the expected SDK**

The `build` script installs a preview .NET SDK so that EF Core "is being built with the expected SDK and msbuild version." Code may depend on SDK changes newer than the latest public preview.

**Start from an issue**

- "All contributions should address an open issue." PRs "that don't get merged are often those that are created without any prior discussion with the team."
- Contributors should comment on the issue describing their approach and, per the PR template, get approval from a team member before contributing.
- "The bigger the enhancement, the more important it is to communicate with the EF Team." Issues labelled `needs-design` have no agreed approach yet and are much harder to implement from outside.
- Typo fixes in documentation do not need an issue.

**Commit messages** follow the format in the PR template: a summary line, a list of details, and a `Fixes #<bug>` line.

**Package versions**

EF Core packages ship together: users must install the same version of all `Microsoft.EntityFrameworkCore.*` packages (`src/EFCore/PACKAGE.md`). Code in one package may therefore rely on the matching version of the others.
