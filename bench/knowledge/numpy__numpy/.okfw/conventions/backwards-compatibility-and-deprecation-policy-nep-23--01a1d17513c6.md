---
id: "01a1d175-13c6-76dc-ad5f-4316725e2a07"
title: "Backwards compatibility and deprecation policy (NEP 23)"
type: "Guideline"
tags:
  - "api"
  - "backward-compatibility"
  - "deprecation"
created: "2026-11-12T14:31:13-06:00"
timestamp: "2026-11-12T14:31:13-06:00"
description: "NumPy treats breaking changes as harmful by default and requires a formal deprecation path, with specific warning and documentation rules, before removing or changing public behaviour."
x:
  paths: ["numpy/**/*.py", "numpy/**/*.pyi"]
  source: ["doc/neps/nep-0023-backwards-compatibility.rst", "doc/source/dev/index.rst", "doc/source/dev/development_workflow.rst", "doc/source/dev/reviewer_guidelines.rst"]
---

# Backwards compatibility and deprecation policy (NEP 23)

NEP 23 (status: Active) is the policy a reviewer applies to any change that alters public behaviour.

## Principles

- Changes must benefit users more than they harm them.
- "NumPy is widely used, so breaking changes should be assumed by default to be harmful." Decisions are based on how users and downstream packages are affected, even if that usage contradicts the documentation.
- "The possibility of an incorrect result is worse than an error or even crash."
- Fixes for clear bugs are exempt, but even a bug fix may be delayed if it would break downstream builds or give incorrect results there.

## Deprecations

Only deprecate what will actually be removed; otherwise discourage it in the docs. A deprecation:

- includes the version in which the functionality was deprecated;
- names the alternative, or the reason if there is none;
- uses `DeprecationWarning` by default (`VisibleDeprecationWarning` for things needing extra attention);
- sets a `stacklevel` so the warning points at the caller;
- is mentioned in the function's documentation (for example with `.. deprecated::`) and in the release notes;
- is never introduced in a bug-fix (micro) release.

The NEP shows a standard comment above the warning so deprecations can be grepped, e.g. `# NumPy 1.15.0, 2018-09-02` in Python and `/* DEPRECATED 2020-05-13, NumPy 1.20 */` in C, where the C form checks `PyErr_WarnFormat(...) < 0` and returns an error.

Removal happens no sooner than two releases (at least one year) after deprecation, only in a feature release, and is listed in the release notes. A behaviour change that is not a removal uses `FutureWarning` with the same version, `stacklevel` and release-note rules, plus a `.. versionchanged::` directive afterwards. Temporary keywords that force users to change their code twice are called out as "almost never the right thing to do".

All deprecations must be proposed on the mailing list; removals of already-deprecated code need not be. The dev guide adds that a PR introducing a deprecation should be discussed first and then follow NEP 23, and that maintainers check that new features and compatibility breaks were discussed on the mailing list before merging. API changes and function additions or modifications need a release-note fragment in `doc/release/upcoming_changes/`.

Stricter rules apply to `numpy.random` (see the separate random-compatibility concept) and to the `.npy`/`.npz` file format, which is versioned independently and whose existing versions must stay backwards compatible.
