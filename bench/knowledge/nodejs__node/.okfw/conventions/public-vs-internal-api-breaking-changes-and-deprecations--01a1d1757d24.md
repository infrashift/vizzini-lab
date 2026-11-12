---
id: "01a1d175-7d24-79d2-94a2-6f50dbc01fbc"
title: "Public vs Internal API, Breaking Changes, and Deprecations"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "semver"
  - "deprecation"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Rules for what counts as public API, what makes a change semver-major, and how deprecations must progress."
x:
  paths: ["lib/**/*.js", "src/**", "doc/api/**"]
  source: ["doc/contributing/collaborator-guide.md", "lib/internal/README.md", "doc/contributing/internal-api.md", "doc/contributing/using-symbols.md", "doc/contributing/pull-requests.md", "doc/contributing/technical-values.md"]
---

# Public vs Internal API, Breaking Changes, and Deprecations

Stability (backward compatibility) is the project's second-highest technical value, after developer experience. Reviewers should identify whether a change touches public API and label it accordingly.

**What is public**

- Everything in the official documentation is public. Undocumented things are internal, but collaborators treat some widely relied-on undocumented behaviors as public.
- `lib/internal/**` is internal unless re-exported from `lib/*.js`. Internal modules may change at any time; `--expose-internals` exists only for maintainer debugging.
- Undocumented `process.binding(...)` functionality, non-exported `Symbol` properties, undocumented `_`-prefixed properties, and native APIs requiring `NODE_WANT_INTERNALS` are internal.
- Core uses local `Symbol('kName')` for private fields; global symbols use `Symbol.for('nodejs.<name>')` and are for deliberate, developer-facing customization hooks.

**Breaking changes (semver-major, two TSC approvals)**

Removing or redefining arguments, changing return values, changing options properties, adding or removing errors, altering event timing, or changing an API's side effects. Changes to internals may land as patch/minor but need care; if they break the ecosystem (check with CITGM) they are semver-major. Changing an existing API's return type is "quite likely a breaking change". A semver-major commit message should explain the reason for the break, what situation triggers it, and the exact change.

**Deprecations**

- Stable public APIs that change incompatibly must go through deprecation. Exceptions include adding/removing errors, emitting a runtime warning, changing messages of errors without codes, timing changes, and errors from dependencies such as V8.
- Levels: Documentation-only (no runtime effect, may warn under `--pending-deprecation`), Runtime (warns on first use; throws with `--throw-deprecation`), End-of-Life.
- Doc-only deprecations are not semver-major; Runtime and End-of-Life are.
- No API may reach End-of-Life without a Runtime deprecation cycle; doc-only cannot become Runtime until the next major.
- Each deprecation gets a unique, immutable identifier, used in docs, warnings and errors, and its documentation entry in `doc/api/deprecations.md` stays forever.
- Prefer an alias or stub/no-op over a Runtime deprecation when that suffices.
- Experimental and undocumented APIs can usually be removed without a cycle unless they have non-trivial adoption.
