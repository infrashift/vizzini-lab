---
id: "01a1d175-9f26-7a9f-a696-49ec5cf14681"
title: "API Stability and Backwards Compatibility"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "release-notes"
  - "documentation"
created: "2026-11-12T14:31:49-06:00"
timestamp: "2026-11-12T14:31:49-06:00"
description: "Django's promise that documented public APIs stay stable, what counts as internal, and the documentation and release notes a behavior change must include."
x:
  paths: ["django/**/*.py"]
  source: ["docs/misc/api-stability.txt", "docs/internals/contributing/writing-code/submitting-patches.txt", "docs/internals/release-process.txt"]
---

# API Stability and Backwards Compatibility

Django is "committed to API stability and forwards-compatibility". Code written against one version should keep working with future releases.

**What is public**
- Everything covered in the documentation, except the internals section, is a stable public API.
- Functions, methods and other objects whose names start with a single underscore are internal. So is anything the docs explicitly describe as internal. These may change without notice.
- The security policy adds that private and undocumented functions are not part of the public API.

**What "stable" requires of a change**
- A public API is never moved or renamed without a backwards-compatible alias.
- New features may be added to a stable API, but they must not break or change the meaning of existing methods.
- Removing or replacing a stable API requires a deprecation. The old API stays for at least two feature releases and issues warnings when called.
- Backwards compatibility may be broken without a deprecation only when a bug or security hole makes it "completely unavoidable". "Security trumps the compatibility guarantee."
- Django does not accept experimental features. Every feature follows the deprecation policy, which is why API design can take months or years. The docs suggest starting new public interfaces in a third-party package.
- New functionality that makes a design decision, and especially anything that deprecates or breaks behavior, needs wider community discussion (the new-features process, the Forum, or a DEP).

**Documentation and release notes (from the contribution checklist)**
- A new feature, or a change to an existing feature's behavior, must include documentation.
- New features need a release note in `docs/releases/A.B.txt` and must be annotated with `.. versionadded:: A.B` or `.. versionchanged:: A.B`.
- Any backwards-incompatible change, however small, needs a note in the release notes.
- A bug fix that qualifies for a backport to a stable branch needs a note in `docs/releases/A.B.C.txt`. Fixes that land only on main need no release note.
- The documentation must build without errors and pass the spelling check.
