---
id: "01a1d174-7a12-73f5-8530-6e175ba4a89e"
title: "Reversible output and the few input-dependent heuristics"
type: "Guideline"
tags:
  - "formatting"
  - "heuristics"
  - "rationale"
created: "2026-11-12T14:30:34-06:00"
timestamp: "2026-11-12T14:30:34-06:00"
description: "Prettier avoids formatting that depends on the original layout; the documented exceptions (objects, decorators, template literals, blank lines, certain long lines) are deliberate and should not be extended casually."
x:
  paths: ["src/language-js/**", "src/language-css/**", "src/language-markdown/**", "src/main/comments/**"]
  source: ["docs/rationale.md", "docs/option-philosophy.md"]
---

# Reversible output and the few input-dependent heuristics

## General strategy: avoid non-reversible formatting

The rationale page explains that "as a general strategy, Prettier avoids _non-reversible_ formatting." Reversible means that if you add something, run Prettier, remove it again and rerun Prettier, you get back the original output. Non-reversible formatting produces "useless" diffs that end up in commits, "which is exactly the kind of situation Prettier was created to prevent." By default the algorithm prints expressions on one line if they fit.

## Documented exceptions

The docs describe these places where the original source affects output. They are described as pragmatic workarounds, not features to copy:

- **Multi-line objects.** An object stays multi-line if there is a newline between `{` and the first key in the input. Long single-line objects expand; short multi-line ones are never collapsed. The docs call this "a workaround, not a feature", and the team is still looking for heuristics that would remove or reduce it. The `objectWrap` option can disable it.
- **Decorators.** Kept where the author put them if they fit on the line, except that class decorators always go on their own line.
- **Template literals.** An interpolation is only split across lines if it already contained a line break; otherwise it stays on one line regardless of width. "The team would prefer not to depend on the original formatting in this way."
- **Empty lines.** Preserved as in the source, but multiple blank lines collapse to one, and blank lines at the start and end of blocks and files are removed. Files end with a single newline.

## Print width is a guideline

`printWidth` "is more of a guideline to Prettier than a hard rule." Some things cannot be broken (long strings, regexps, comments, names), and some cases intentionally exceed the width: single-specifier `import` statements and `require` calls stay on one line, and calls to common test functions such as `describe`, `it` and `test` keep long descriptions on one line.

## Other documented behaviors

- In no-semicolon mode, Prettier adds a leading `;` before lines starting with `[` (and similar) so lines stay independent under ASI.
- JSX in conditionals and returns is wrapped in parentheses.
- Machine-generated files such as `package.json` are formatted with a `JSON.stringify`-based formatter to avoid conflicts with package managers; this is intended.

## Reviewer note

Since requests to preserve input formatting are treated as options in disguise, a change that adds a new dependence on original layout needs a strong justification.
