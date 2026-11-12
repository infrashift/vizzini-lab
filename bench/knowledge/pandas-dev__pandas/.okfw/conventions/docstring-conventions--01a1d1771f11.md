---
id: "01a1d177-1f11-7464-ab0c-c303965ce56c"
title: "Docstring conventions"
type: "Guideline"
tags:
  - "documentation"
  - "docstrings"
  - "style"
created: "2026-11-12T14:33:27-06:00"
timestamp: "2026-11-12T14:33:27-06:00"
description: "pandas docstrings follow the numpydoc convention plus pandas-specific rules, and their examples are doctests that must pass."
x:
  paths: ["pandas/**/*.py"]
  source: ["doc/source/development/contributing_docstring.rst", "doc/source/development/contributing_documentation.rst", "doc/source/development/contributing_codebase.rst"]
---

# Docstring conventions

pandas follows PEP-257 and the NumPy (numpydoc) docstring convention, with extra pandas rules. Validation, including pandas-specific checks, is enforced during the Sphinx build through `numpydoc_validation_checks`, and a failing doctest blocks merging a PR.

## Layout

- Use three double quotes. No blank line before or after the docstring; text starts on the line after the opening quotes, and the closing quotes sit on their own line.
- Inline code goes in double backticks: parameter names, Python objects, literals. Link pandas objects with `:class:`, `:meth:` and `:func:` roles.
- **Short summary**: one line, starts with a capital letter, ends with a dot; for functions and methods it starts with an infinitive verb.
- **Extended summary**: what the function does and why it is useful, not parameter details or implementation notes.
- **Parameters**: every parameter in the signature must be documented, including `*args` and `**kwargs` (but not `self`), as `name : type` with the space before the colon. Types are required except for `*args`/`**kwargs`. Descriptions start with a capital letter and end with a dot.
- Defaults are written `int, default 0`. When `None` means "not used", write `str, optional`; when `None` is a real value, write `str, int or None, default None`.
- Types: built-in names (`int`, `str`); `list of int`, `dict of {str : int}`; allowed values in braces; module-qualified external types (`numpy.ndarray`); `pandas.` prefix for pandas types except `Series` and `DataFrame`; alternatives joined with commas and a final `or`; `None` always last. For axis: `{0 or 'index', 1 or 'columns', None}, default None`.
- Further sections: Returns/Yields, See Also, Notes, Examples.

## Examples

- Must be valid, deterministic Python that users can copy and run, shown as a `>>>` session. `numpy` and `pandas` are pre-imported as `np` and `pd`; import anything else explicitly, one per line, without aliases.
- Name a single Series `ser`, a DataFrame `df`, an index `idx`; keep data compact (around four rows) and meaningful; prefer keyword arguments such as `head(n=3)`.
- Avoid random data; if needed, use a fixed seed.

## Versioning directives

New functions, methods and keyword arguments get a `.. versionadded::` directive in the docstring; deprecated ones get `.. deprecated::`, which is replaced by `.. versionchanged::` when the deprecation is enforced (see the [deprecation policy](./backward-compatibility-and-deprecation-policy--01a1d1770a8f.md)).
