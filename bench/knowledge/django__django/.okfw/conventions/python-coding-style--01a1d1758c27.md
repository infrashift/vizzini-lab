---
id: "01a1d175-8c27-715b-9eed-a6194e47c47d"
title: "Python Coding Style"
type: "Guideline"
tags:
  - "style"
  - "formatting"
  - "python"
created: "2026-11-12T14:31:44-06:00"
timestamp: "2026-11-12T14:31:44-06:00"
description: "Django's stated Python style rules: black formatting, PEP 8 with an 88-character limit, readable string interpolation, and naming conventions."
x:
  paths: ["django/**/*.py", "tests/**/*.py"]
  source: ["docs/internals/contributing/writing-code/coding-style.txt", "docs/internals/contributing/writing-code/submitting-patches.txt"]
---

# Python Coding Style

Django's coding style guide states these rules for Python code. The contribution checklist asks reviewers to confirm the change follows them and has no `black`, `blacken-docs`, `flake8`, `isort` or `zizmor` errors. The `pre-commit` hooks catch most of these automatically.

**Formatting**
- Format all files with `black`. Python uses 4-space indentation, HTML uses 2 spaces (`.editorconfig`).
- Otherwise follow PEP 8, checked with `flake8`. The docs call PEP 8 "only a guide": matching the style of the surrounding code comes first.
- Code lines may be up to 88 characters, the `black` limit. Documentation, comments and docstrings wrap at 79 characters.
- Remove trailing whitespace.

**String interpolation**
- %-formatting, f-strings and `str.format()` are all allowed. Choose whichever reads best.
- f-strings should contain only plain variable or attribute access, such as `f"hello {self.user.name}"`. Assign anything more complex to a local variable first. `f"hello {get_user()}"` is not allowed.
- Never use f-strings for strings that may need translation, including error and logging messages.
- Don't refactor unrelated existing code just to change its formatting method.

**Naming and comments**
- Use `lower_case_with_underscores` for variables, functions and methods, never camelCase. Use `InitialCaps` for classes and for factory functions that return classes.
- Comments avoid "we" (write "Loop over", not "We loop over").
- Docstrings follow PEP 257 and the style of existing docstrings.
- Where they apply, use PEP 448 unpacking generalizations (`{**x, **y}`, `[*a, *b]`).

**Hygiene**
- Remove imports the change no longer uses. An unused import kept for backwards compatibility is marked with `# NOQA`.
- Don't put contributor names in the code. Credit belongs in the `AUTHORS` file.
- Mark all user-facing strings for internationalization.
