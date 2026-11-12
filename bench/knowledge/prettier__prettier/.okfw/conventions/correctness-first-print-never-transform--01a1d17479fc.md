---
id: "01a1d174-79fc-7b6c-96dc-111d6e0c94f0"
title: "Correctness first: print, never transform"
type: "Guideline"
tags:
  - "correctness"
  - "printer"
  - "scope"
created: "2026-11-12T14:30:33-06:00"
timestamp: "2026-11-12T14:30:33-06:00"
description: "Formatted output must be valid code with exactly the same behavior as the input, and Prettier only reprints code; it never rewrites or reorders it."
x:
  paths: ["src/main/**", "src/language-*/**", "packages/plugin-*/*.js"]
  source: ["docs/rationale.md", "docs/api.md"]
---

# Correctness first: print, never transform

## The first requirement

The rationale document states that "the first requirement of Prettier is to output valid code that has the exact same behavior as before formatting." Any input where Prettier breaks this rule is treated as a bug that must be fixed. A reviewer should treat any printer change that could alter program semantics as the most serious kind of defect, ahead of any aesthetic concern.

## Prettier prints, it does not transform

"Prettier only _prints_ code. It does not transform it." This limits scope so the project can focus on printing well. The docs list examples that are explicitly out of scope, and a change that introduces any of them should be questioned:

- turning single- or double-quoted strings into template literals or the reverse;
- using `+` to split long string literals so they fit the print width;
- adding or removing optional `{}` and `return`;
- turning `?:` into `if`/`else`;
- sorting or moving imports, object keys, class members, JSX keys, CSS properties or anything else. Sorting is called out as "potentially unsafe because of side effects (for imports, as an example)" and it makes the correctness goal hard to verify.

Prettier also does not repair existing bugs. The semicolon section shows code with a missing semicolon before `(`: Prettier keeps the behavior and reformats it so that the real behavior becomes visible, rather than "fixing" it.

## Preserve what the author wrote where it carries meaning

- Prettier "maintains the way your string is escaped" (for example `"🙂"` is not rewritten as a `\u` escape, and vice versa). Quote choice minimizes escapes, with double quotes on a tie unless `singleQuote` is set.
- Comment _content_ is left as-is, since comments can hold prose, code or diagrams. The only exception is JSDoc-style block comments, whose indentation Prettier may fix.

## AST location data

The API docs warn that Prettier "uses the location data of AST nodes for many things like preserving blank lines and attaching comments", and that modifying an AST after parsing often desynchronizes that data and gives unpredictable results. Changes that mutate parsed ASTs should be checked with this in mind.
