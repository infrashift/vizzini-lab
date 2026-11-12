---
id: "01a1d175-ed15-78a2-8a9f-e28a4d5b9ec7"
title: "C# coding style and nullability rules"
type: "Guideline"
tags:
  - "style"
  - "csharp"
  - "nullability"
created: "2026-11-12T14:32:08-06:00"
timestamp: "2026-11-12T14:32:08-06:00"
description: "The C# formatting, nullable-reference-type and file-protection rules the repository's own coding instructions state."
x:
  paths: ["src/**/*.cs", "global.json", "NuGet.config", "package.json"]
  source: [".github/copilot-instructions.md", "CONTRIBUTING.md"]
---

# C# coding style and nullability rules

The repository's coding instructions (`.github/copilot-instructions.md`) and CONTRIBUTING.md give the style rules below. CONTRIBUTING.md also requires that "your code matches the existing syntax conventions within the codebase" and links to an external engineering-guidelines wiki page that is not part of these docs. The coding instructions also say: "Make only high confidence suggestions when reviewing code changes."

## Formatting

- Follow the style defined in `.editorconfig`.
- Use the latest C# language version.
- Prefer file-scoped namespace declarations and single-line `using` directives.
- Put the opening curly brace of any code block (`if`, `for`, `while`, `foreach`, `using`, `try`, and so on) on a new line.
- Put the final `return` statement of a method on its own line.
- Use pattern matching and switch expressions wherever possible.
- Use `nameof` instead of string literals when referring to member names.
- Write XML doc comments for any public API, with `<example>` and `<code>` where they apply.

## Nullable reference types

- Declare variables non-nullable and check for `null` at entry points.
- Always use `is null` / `is not null` instead of `== null` / `!= null`.
- Trust the C# null annotations: do not add null checks when the type system says a value cannot be null.

A change to an API's nullability annotations is also a public API change and must be recorded in `PublicAPI.Unshipped.txt`.

## Files not to touch

Unless a change explicitly asks for it, do not modify:

- `global.json`
- `package.json` or `package-lock.json`
- `NuGet.config` files

## Scope of style changes

CONTRIBUTING.md says PRs that are "mostly about refactoring existing code or code style" are less likely to be merged. Style should match nearby code rather than be changed broadly in unrelated places.
