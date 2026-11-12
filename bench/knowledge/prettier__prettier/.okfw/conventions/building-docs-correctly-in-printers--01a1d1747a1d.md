---
id: "01a1d174-7a1d-7d36-a4bb-f043c41e9909"
title: "Building Docs correctly in printers"
type: "Guideline"
tags:
  - "printer"
  - "doc"
  - "performance"
created: "2026-11-12T14:30:34-06:00"
timestamp: "2026-11-12T14:30:34-06:00"
description: "Printers build a Doc intermediate representation with the builder commands, and commands.md states rules and limits for using them correctly and efficiently."
x:
  paths: ["src/document/**", "src/language-*/print/**", "src/language-*/printer-*.js", "src/language-*/embed.js", "src/language-*/embed/**"]
  source: ["commands.md", "docs/technical-details.md", "docs/plugins.md"]
---

# Building Docs correctly in printers

## Architecture

Prettier's printer is a fork of recast's printer using the algorithm from Wadler's "A prettier printer". A printer takes an AST and returns an intermediate representation, the `Doc`; the core then measures the Doc to decide where lines break. The core algorithm lives in `src/document/{printer,builders,utilities}/`. Language printers should express layout through Doc commands, not by computing line lengths themselves.

A Doc is a string, an array of Docs (concatenation), or a command such as `group`, `indent`, `line`, `softline`, `hardline`, `fill`, `ifBreak`, `lineSuffix`, `align`, `label` and others.

## Rules stated in commands.md

- **Strings must not contain line breaks.** Strings are printed as-is, "however for the algorithm to work properly they shouldn't contain line break characters." Use `hardline` / `literalline` instead.
- **Hard breaks propagate.** `hardline`, `literalline` and `breakParent` force every enclosing group to break. This is intended for consistency (for example an array containing a function always breaks).
- **`conditionalGroup` is a last resort.** It "triggers an exponential complexity when nested." New uses deserve scrutiny for performance.
- **`fill` expects alternating content and separators**: elements at odd indices must be line breaks.
- **`ifBreak` with hard breaks.** A `hardline` or `breakParent` inside either branch breaks the parent groups even if that branch is not printed. This is a known design limitation; in the rare case a hard line is truly needed, use `hardlineWithoutBreakParent`.
- **`indentIfBreak` requires a `groupId`**; applying it to the current group makes no sense because that is what `indent` does.
- **`align` and tabs.** With `useTabs`, middle alignments become tabs. In whitespace-sensitive contexts such as Markdown, pass spaces to `align` as a string to prevent tab replacement.
- **`lineSuffix` / `lineSuffixBoundary`** implement trailing comments; use the boundary so comments cannot escape embedded code into surrounding text.
- **`label`** marks a Doc for later introspection (for example detecting a printed method chain) without changing output.

## Debugging aid

The Playground has a `doc-explorer` parser value for exploring how Docs print, which the docs recommend for understanding the IR.
