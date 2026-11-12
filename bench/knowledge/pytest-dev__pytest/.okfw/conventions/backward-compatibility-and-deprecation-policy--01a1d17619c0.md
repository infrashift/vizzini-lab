---
id: "01a1d176-19c0-7db2-99d0-0e37dd8dc702"
title: "Backward Compatibility and Deprecation Policy"
type: "Guideline"
tags:
  - "compatibility"
  - "deprecation"
  - "warnings"
  - "api"
created: "2026-11-12T14:32:20-06:00"
timestamp: "2026-11-12T14:32:20-06:00"
description: "pytest removes public behaviour only through a warning-backed deprecation period ending in a major release, and true breakage needs prior announcement and documentation in doc/en/deprecations.rst."
x:
  paths: ["src/_pytest/deprecated.py", "src/_pytest/warning_types.py", "src/_pytest/**/*.py", "src/pytest/__init__.py", "doc/en/deprecations.rst", "testing/deprecated_test.py"]
  source: ["doc/en/backwards-compatibility.rst", "doc/en/deprecations.rst", "doc/en/how-to/capture-warnings.rst"]
---

# Backward Compatibility and Deprecation Policy

pytest tries "to ensure an easy transition" and to avoid "unnecessary churn on our users and community/plugin authors". Any change that alters or removes public behaviour must fit one of three categories from the backwards compatibility policy.

## The three kinds of transition

1. **Trivial**: the old API translates directly to the new one. It is supported indefinitely; users are nudged to the new way through documentation only.
2. **Transitional**: old and new APIs can coexist. The old one keeps working but emits a warning for a long period.
   - Removal starts only in a **major** release, and a deprecation must live through at least two minor releases first.
   - The warning class is `PytestRemovedInXWarning`, a subclass of `pytest.PytestDeprecationWarning`, where X is the major version that removes it.
   - When X is released the feature is not removed at once: warning filters turn that warning into an **error** by default, and the feature is actually removed in the next minor release.
3. **True breakage**: only when a normal transition is "unreasonably unsustainable", and only for APIs with very few users (for example, only some plugins). It must first be announced in an issue with a detailed description, rationale and expected impact on users and plugin authors, then go through a proof-of-concept pull request.

## What a deprecating or breaking change must contain

- Deprecation warnings or errors that help users port their code. If a deprecation period can be added in the current series before the breakage, it goes in a separate pull request.
- A rationale and porting examples in `doc/en/deprecations.rst`. That page exists so users get "a clear rationale why a certain feature has been removed, and what alternatives should be used instead"; each entry is marked with `deprecated`, `versionremoved` or `versionchanged` directives.
- pytest's own warnings use its custom warning hierarchy (`PytestWarning` and subclasses), so users can filter them with the standard `-W` and `filterwarnings` mechanisms.

## Review checks

- Removing or renaming a public function, fixture, hook, option or argument without a prior deprecation is a policy violation unless it follows the true-breakage process.
- New deprecations should emit a pytest warning subclass, not a bare `DeprecationWarning`.
- A deprecation needs both the `deprecations.rst` entry and a `deprecation` changelog fragment (see [Changelog Fragments and AUTHORS Accompany Changes](./changelog-fragments-and-authors-accompany-changes--01a1d17485a0.md)).
- Python version support follows the actively maintained CPython versions at release time, so dropping a Python version is also a compatibility decision.
