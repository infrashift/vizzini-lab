---
id: "01a1d174-3010-707f-a97c-108605f2eb19"
title: "Testing expectations for changes"
type: "Guideline"
tags:
  - "testing"
  - "vitest"
  - "regression"
  - "snapshots"
  - "types"
created: "2026-11-12T14:30:15-06:00"
timestamp: "2026-11-12T14:30:15-06:00"
description: "Fixes need a test that fails without the fix, tests use the minimal API and the right runtime, snapshot tests need explicit assertions, and type changes need dts tests."
x:
  paths: ["packages/**/__tests__/**", "packages-private/dts-test/**", "packages-private/dts-built-test/**", "packages-private/vapor-e2e-test/**", "packages/runtime-test/src/**"]
  source: [".github/contributing.md", ".github/maintenance.md", "AGENTS.md", "packages/runtime-test/README.md", "packages-private/dts-test/README.md", "packages-private/dts-built-test/README.md"]
---

# Testing expectations for changes

Unit tests use Vitest and live next to the code in each package's `__tests__` directories. A reviewer should expect:

**Fixes and features**

- A bug fix should, in most cases, include a test case that fails without the fix. The suggested workflow is to write or extend the test first, confirm it fails, then change the implementation.
- A new feature needs accompanying test cases.
- When a reviewer suspects a scenario is broken or uncovered, the guidance is to prove it with a concrete test rather than by reasoning alone, and to keep such tests as regression protection.
- New tests and helpers usually go near the end of the existing test file unless locality argues otherwise.

**How tests should be written**

- Use the minimal API needed. If a test can avoid the reactivity system or a component, it should, so it is not exposed to unrelated changes.
- Use `@vue/runtime-test` for platform-agnostic behavior and low-level virtual DOM operations; it renders to plain JS objects, is DOM-agnostic and faster than JSDOM. Use a platform-specific runtime only when asserting platform-specific behavior.
- `runtime-vapor` tests should stay close to template-compiled output and real usage paths, not hand-written `setup` edge cases.
- Do not add tests that only raise coverage without exercising a meaningful use case.

**Snapshot and compiler tests**

- Take extra care with snapshots: CI can pass while the snapshotted generated code contains bugs. Accompany snapshot tests with explicit `expect(code).toMatch(...)` assertions.
- For compiler changes, check generated output against expected patterns, using a snapshot test or the template explorer.

**Type tests**

- Type tests live in `packages-private/dts-test`. They are checked against source via the root `tsconfig.json`, and against the actually built declarations with `nr test-dts` (which builds `.d.ts` first). `packages-private/dts-built-test` verifies that libraries building their own types on top of Vue's types keep working.

**Other suites**: `test-unit` runs against source, `test-e2e` against built files in real browsers, and `test-e2e-vapor` for Vapor. Run at least the validation matching the change's scope, and the broader suites when public behavior, compiler output, hot paths, type declarations or bundle size are affected.
