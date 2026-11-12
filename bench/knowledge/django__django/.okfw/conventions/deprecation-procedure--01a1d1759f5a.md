---
id: "01a1d175-9f5a-7db4-8ef6-2506bc1dcc81"
title: "Deprecation Procedure"
type: "Guideline"
tags:
  - "deprecation"
  - "compatibility"
  - "warnings"
created: "2026-11-12T14:31:49-06:00"
timestamp: "2026-11-12T14:31:49-06:00"
description: "How Django code deprecates a feature: RemovedInDjangoXXWarning over two feature releases, keeping Django itself warning-free, marking the shim code, and testing the warning."
x:
  paths: ["django/**/*.py", "django/utils/deprecation.py", "tests/**/*.py"]
  source: ["docs/internals/contributing/writing-code/submitting-patches.txt", "docs/internals/release-process.txt", "docs/internals/deprecation.txt"]
---

# Deprecation Procedure

**Timeline policy**
A feature deprecated in feature release A.x keeps working, with warnings, for every A.x release. It is removed in B.0, or in B.1 if it was deprecated in the last A.x release. Deprecations therefore always span at least two feature releases. The shims from X.0 and X.1 are dropped in Y.0, and the shims from X.2 LTS in Y.1. Deprecation warnings are silent by default.

Features are deprecated when they are improved or changed in a backwards-incompatible way, or when a bundled backport of a Python library is no longer needed.

**Code requirements**
- The first release that deprecates a feature raises `RemovedInDjangoXXWarning` when the feature is used, where XX is the version that removes it.
- Raise the warning with `warnings.warn(..., category=RemovedInDjangoXXWarning, skip_file_prefixes=django_file_prefixes())` so it points at the user's code.
- First remove every use of the deprecated behavior from Django itself. The suite runs with warnings turned into errors (`python -Wa runtests.py`), so any warning the change produces must be eliminated or silenced.
- Silence warnings only in tests that deliberately exercise the deprecated behavior, with `@ignore_warnings(category=RemovedInDjangoXXWarning)` on the test method or class.
- Add a test that uses `assertWarnsMessage(RemovedInDjangoXXWarning, msg)` and checks that `ctx.filename == __file__`, so the warning is attributed to the caller.
- Code that must change or be deleted when the deprecation ends but has no warning of its own (compatibility hooks, now-unused helpers) gets a `# RemovedInDjangoXXWarning.` comment above it.
- `django.utils.deprecation` provides helpers, such as the `@deprecate_posargs` decorator for converting positional-or-keyword arguments to keyword-only.

**Documentation requirements**
- Mark the documented feature with `.. deprecated:: A.B`, with a short description and the upgrade path.
- Describe the deprecation and upgrade path in the current release notes, under "Features deprecated in A.B".
- Add an entry to the deprecation timeline in `docs/internals/deprecation.txt` under the removal version.

In each feature release, all `RemovedInDjangoXXWarning` shims that match the new version are removed.
