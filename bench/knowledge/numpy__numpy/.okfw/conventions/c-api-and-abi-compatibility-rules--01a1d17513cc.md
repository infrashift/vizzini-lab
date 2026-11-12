---
id: "01a1d175-13cc-7aed-99b9-14b0fa407fd2"
title: "C-API and ABI compatibility rules"
type: "Guideline"
tags:
  - "c-api"
  - "abi"
  - "backward-compatibility"
created: "2026-11-12T14:31:13-06:00"
timestamp: "2026-11-12T14:31:13-06:00"
description: "Additions to NumPy's public C-API must stay ABI compatible with older versions, using version guards on struct fields and MinVersion annotations on API-table entries."
x:
  paths: ["numpy/_core/include/**", "numpy/_core/code_generators/**", "numpy/_core/src/**"]
  source: ["doc/source/dev/reviewer_guidelines.rst", "doc/TESTS.rst", "doc/source/dev/index.rst", "doc/neps/nep-0023-backwards-compatibility.rst", "doc/source/dev/development_workflow.rst"]
---

# C-API and ABI compatibility rules

The reviewer guidelines contain a dedicated "API changes" section. Most public API changes should be discussed ahead of time with a wider audience: on the mailing list, or even through a NEP.

## ABI rules for the public C-API

"The NumPy C-API is backwards compatible so that any addition must be ABI compatible with previous versions. When it is not the case, you must add a guard."

- New struct fields go at the end of the struct and are wrapped in a feature-version guard. The documented example is `PyUnicodeScalarObject`, whose `buffer_fmt` field sits inside `#if NPY_FEATURE_VERSION >= NPY_1_20_API_VERSION ... #endif`, because the field was appended in that version while all earlier fields stayed ABI compatible.
- Any function added to the API table in `numpy/_core/code_generators/numpy_api.py` must use the `MinVersion` annotation, for example `'PyDataMem_SetHandler': (304, MinVersion("1.22"))`.
- Header-only additions, such as a new macro, typically do not need a guard.

When reviewing a change under `numpy/_core/include/` or the code generators, check that new public symbols carry these guards and that existing fields and slots were not reordered or changed.

## Testing the C-API

The testing guidelines state that the C-API is tested with C-extension modules written "as-if" they know nothing about NumPy internals, using only the official C-API interfaces. Examples are the user-defined `rational` dtype in `_rational_tests` and the ufunc machinery tests in `_umath_tests`. Tests can also compile small C snippets locally with `numpy.testing.extbuild.build_and_import_extension`.

## Deprecations in C

When C code deprecates behaviour, NEP 23 applies here too: emit a `DeprecationWarning` via `PyErr_WarnFormat`, check its return value (`< 0` means the warning was turned into an error and the function must return failure), and mark the site with a dated `/* DEPRECATED ... */` comment.

Like other API changes, C-API changes need a release-note fragment in `doc/release/upcoming_changes/`.
