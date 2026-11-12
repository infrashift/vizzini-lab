---
id: "01a1d174-2ff0-739c-b6c8-fbcdd42c1b8f"
title: "Code style, runtime constraints and PR scope"
type: "Guideline"
tags:
  - "style"
  - "scope"
  - "refactoring"
  - "runtime"
created: "2026-11-12T14:30:15-06:00"
timestamp: "2026-11-12T14:30:15-06:00"
description: "Vue core expects boring, focused changes that follow existing style, avoid optional chaining in runtime source, and never bundle unrelated refactors."
x:
  paths: ["packages/*/src/**", "packages-private/**/*.ts"]
  source: [".github/contributing.md", ".github/maintenance.md", "AGENTS.md"]
---

# Code style, runtime constraints and PR scope

Formatting and linting are automated: a pre-commit hook formats staged JS/JSON and runs `lint --fix` plus formatting on staged TS/TSX (oxlint and oxfmt), and the whole project is type-checked on commit. Note that `nr build` does not type-check; `nr check` does. So reviewers should not spend effort on mechanical formatting, but should check the following stated rules.

**Runtime-specific rule**

- Do not use optional chaining (`?.`) in runtime source code. Use explicit guards or local variables instead. Test files are exempt.

**Implementation style**

- Follow the established conventions of the surrounding code. Maintainers chose the current style deliberately and do not want to debate it.
- Prefer code that is "boring but easy to understand" over clever code.
- Do not add error handling, fallbacks or validation for situations that cannot happen; trust internal code and framework guarantees and validate only at system boundaries such as user input or external APIs.
- Do not create helpers or abstractions for one-time operations or for hypothetical future needs; a few similar lines are preferred over a premature abstraction.
- Do not add docstrings, comments or type annotations to code that was not changed; comment only where logic is not self-evident.
- Avoid backwards-compatibility hacks for internal code, such as renaming unused variables with `_`, re-exporting removed types, or leaving "removed" comments. Unused code should simply be deleted.

**PR scope**

- A PR should change only what is needed for its stated problem. A fix should not clean up surrounding code, rename things, or reformat unrelated lines.
- Large stylistic refactors are discouraged. They are accepted only if they improve performance or come with an objective explanation of why they improve quality, such as enabling a related feature. Large style diffs add history noise and merge conflicts.
- Prefer the smallest sufficient fix.

**Review etiquette** described in the docs: go file by file, focus on correctness, edge cases and regression risk rather than style, label blocking issues separately from nits, and do not flag pre-existing problems unrelated to the change unless they are a significant risk.
