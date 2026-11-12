---
id: "01a1d177-0a8f-7a8b-9ffb-46596387dc55"
title: "Backward compatibility and deprecation policy"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "deprecation"
created: "2026-11-12T14:33:22-06:00"
timestamp: "2026-11-12T14:33:22-06:00"
description: "Rules for changing public pandas behavior: deprecate first, warn with the right class, and only break in major releases."
x:
  paths: ["pandas/**/*.py", "pandas/errors/__init__.py", "pandas/util/_decorators.py", "pandas/util/_exceptions.py"]
  source: ["doc/source/development/policies.rst", "web/pandas/pdeps/0017-backwards-compatibility-and-deprecation-policy.md", "doc/source/development/contributing_codebase.rst"]
---

# Backward compatibility and deprecation policy

pandas has many users with a lot of existing code, so the contributing guide asks contributors to "try to maintain backward compatibility" and to clearly state in the pull request why a break is needed if they think one is.

## Versioning rules (policies.rst, PDEP-17)

- pandas uses a loose variant of semantic versioning, `MAJOR.MINOR.PATCH`.
- API-breaking changes happen only in **major** releases. Whenever possible a deprecation path is provided instead of an outright break.
- Deprecations are introduced in **minor** releases, never in patch releases. A deprecation keeps the existing behavior working while emitting a warning.
- Deprecated functionality should remain unchanged for at least two minor releases before it is changed or removed, and it is enforced (removed) only in the next major release.
- Breaking compatibility "should benefit more than it harms users".
- The policy covers the public API only. Anything not in the public API, or marked experimental, may change at any time.
- Some bug fixes may need to change behavior without a deprecation cycle; whether something is a bug fix or an API break is a judgement call, and high-impact fixes may be treated as breaking.

## Warning classes

A deprecation starts as a `PandasDeprecationWarning` (a `DeprecationWarning`, hidden by default outside `__main__`), and is promoted to `PandasFutureWarning` in the last minor release before the major release that removes it. All such warnings inherit from `pandas.errors.PandasChangeWarning`; version-specific classes such as `Pandas4Warning` and `Pandas5Warning` mark the major release in which a change is enforced. A reviewer should check that a new deprecation uses the appropriate pandas warning class.

## What a deprecation change must include

- A warning message saying what is changing and how to get similar behavior if an alternative exists (and, for large deprecations, the reason and a discussion link).
- The GitHub issue/PR number as a comment above the warning line.
- `stacklevel=find_stack_level()` (from `pandas.util._exceptions`) when calling `warnings.warn` manually, or `pandas.util._decorators.deprecate` when a replacement with the same arguments exists.
- A `.. deprecated::` directive in the docstring and a release-note entry.
- A new test asserting the warning is raised, and updates so existing pandas tests and code use the new argument.

When enforcing a deprecation, add a release-note entry and, for API changes, replace `.. deprecated::` with `.. versionchanged::`.
