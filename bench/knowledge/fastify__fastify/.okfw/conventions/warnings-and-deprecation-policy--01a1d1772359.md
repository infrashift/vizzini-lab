---
id: "01a1d177-2359-7e3c-b79a-23dd99839daf"
title: "Warnings and Deprecation Policy"
type: "Guideline"
tags:
  - "fastify"
  - "deprecation"
  - "warnings"
  - "semver"
  - "compatibility"
created: "2026-11-12T14:33:28-06:00"
timestamp: "2026-11-12T14:33:28-06:00"
description: "How Fastify announces deprecated behaviour with FSTDEP and FSTWRN process warnings, documents them, and removes them only at the next major under semver and LTS."
x:
  paths: ["lib/warnings.js", "fastify.js", "lib/route.js", "lib/request.js", "lib/reply.js", "types/**"]
  source: ["docs/Reference/Warnings.md", "docs/Reference/Principles.md", "docs/Reference/LTS.md", "docs/Guides/Migration-Guide-V5.md", "CONTRIBUTING.md", "docs/Reference/TypeScript.md"]
---

# Warnings and Deprecation Policy

## Mechanism

- Fastify uses the Node.js process `warning` event "to notify users of deprecated features and coding mistakes."
- Warnings carry an `FSTWRN` prefix (coding mistakes, such as a missing route schema or a plugin mixing async and callback styles). Deprecations carry an `FSTDEP` prefix.
- Deprecation codes work with Node's `--no-deprecation`, `--throw-deprecation`, and `--trace-deprecation` flags, so they are emitted as Node.js deprecation warnings, not log lines.
- Each code is documented in `docs/Reference/Warnings.md` in a table with code, description, "how to solve", and discussion link. The current deprecation, `FSTDEP022`, tells users to use `options.routerOptions` instead of router options at the top level of server options. Every documented entry names the fix, so a reviewer can expect a new code to arrive with its row and replacement.

## Lifecycle of a deprecation

- Behaviour is deprecated in one major and removed in the next. The v5 migration guide says users must fix "all deprecation warnings from v4", because "All v4 deprecations have been removed and will no longer work after upgrading."
- The migration guide shows the pattern: an accessor kept working with an `FSTDEP` warning that names its replacement (for example `request.routeOptions.config` instead of the old `request.context`), then removed at the major.
- Removal happens at a major release, and SemVer-major changes must be merged by a lead maintainer (`CONTRIBUTING.md`). A minor or patch change that drops public behaviour with no prior deprecation does not follow this documented pattern.

## Semver and LTS

- Principle 9 is "Semantic versioning & Long Term Support."
- A major line is supported for at least six months after release and gets security updates for six more months after the next major ships.
- Each major is tested against every Node.js release line that is LTS during its support window. Plugins must keep Node.js compatibility in line with Fastify's main branch.
- Fixes for older lines go to that line's branch (`4.x` and older).

## Types

The TypeScript docs state that parts of the API may be untyped or typed incorrectly and invite pull requests to improve the typings in `types/` and `fastify.d.ts`. Type definitions have their own tests in `test/types/`.
