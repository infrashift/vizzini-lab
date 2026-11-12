---
id: "01a1d175-7e7f-786e-ab35-1890d5fb2e36"
title: "Test Expectations for Changes"
type: "Guideline"
tags:
  - "testing"
  - "tests"
  - "ci"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Every fix and feature needs a focused test in test/ that follows the common-module conventions and avoids sources of flakiness."
x:
  paths: ["test/**"]
  source: ["doc/contributing/writing-tests.md", "test/common/README.md", "test/README.md", "doc/contributing/collaborator-guide.md", "doc/contributing/pull-requests.md", "doc/contributing/using-internal-errors.md"]
---

# Test Expectations for Changes

**When tests are required**

- Bug fixes and features should always come with tests. "All fixes must have a test case which demonstrates the defect": it should fail before the change and pass after.
- Every commit should keep all tests passing. Code changes must pass CI.

**Placement and naming**

- Put a new test in a new file rather than appending to an existing one, unless there is strong motivation. When unsure where it goes, use `test/parallel/`; tests that cannot run in parallel belong in `test/sequential/`. Tests in `test/known_issues/` are expected to fail.
- Names are kebab-case: `test-<module>-<method-or-event>[-detail].js`.

**Structure**

- Require `../common` first, before any other module, even if unused (`require('../common')`). It detects leaked globals, sets the umask, and re-spawns the test with the flags from a `// Flags:` comment.
- Start with a comment describing what the test checks; sort requires in ASCII order; use strict mode unless the test needs otherwise.
- Use port `0` unless the test is about a specific port.
- Close servers and resources so the process exits with code 0.

**Assertions and callbacks**

- Wrap expected callbacks in `common.mustCall()`; for error-first callbacks use `common.mustSucceed()`, since `mustCall` ignores the error. Wrap promise `onFulfilled` handlers in `mustCall` so a never-resolving promise fails the test.
- Prefer `assert.strictEqual` and `assert.deepStrictEqual`. With `assert.throws`, give the full message regex, except for internal errors, where you should match only `{ code }`.

**Flakiness**

- Avoid timers unless timers are under test; if one is needed, use `common.platformTimeout()`.
- Keep console output modest, especially in loops, and comment when output is part of what is asserted.
- Use the `tmpdir` helper for temporary files; `refresh()` is usually called once per test file.

Tests may use ES.Next features available unflagged in all maintained branches, to make backporting easier. C++ unit tests use Google Test in `test/cctest/`.
