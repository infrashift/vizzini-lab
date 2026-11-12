---
id: "01a1d175-929e-708b-96a1-2c8b3ef516fa"
title: "Test Expectations for Changes"
type: "Guideline"
tags:
  - "testing"
  - "review"
  - "quality"
created: "2026-11-12T14:31:45-06:00"
timestamp: "2026-11-12T14:31:45-06:00"
description: "What Django expects of tests in a change: a failing-first regression test for bugs, full coverage of new code, precise assertions, and isolated model definitions."
x:
  paths: ["tests/**", "django/test/**"]
  source: ["docs/internals/contributing/writing-code/unit-tests.txt", "docs/internals/contributing/writing-code/submitting-patches.txt", "docs/internals/contributing/writing-code/coding-style.txt"]
---

# Test Expectations for Changes

Django's policy is that "all tests pass at all times". The test suite lives in `tests/`, and each directory there is a test module. Tests for contrib apps usually go in `<app_name>_tests` (for example, `tests/auth_tests`).

**What a change must include**
- A bug fix needs a regression test that fails before the fix is applied.
- A new feature needs tests that "exercise" all of the new code.
- If tickets are relevant to the change, the submission guide asks for their numbers in comments in the test so the discussion can be traced later. The style guide limits ticket references in docstrings to obscure cases, placed at the end of a sentence, for example `(#123456)`.
- A deprecation needs a test that the warning is raised (see the deprecation concept).

**Assertion style**
- Use `assertRaisesMessage` and `assertWarnsMessage` rather than `assertRaises` and `assertWarns`, so the message is checked too. Use `assertRaisesRegex` and `assertWarnsRegex` only when a regex is really needed.
- Use `assertIs(..., True)` and `assertIs(..., False)` rather than `assertTrue` and `assertFalse`, so the actual boolean is checked, not just truthiness.
- A test docstring states the expected behavior. It doesn't start with preambles like "Tests that" or "Ensures that".

**Isolation**
- A model defined inside a test method must be bound to a temporary `Apps` registry with `@isolate_apps("app_label", ...)`. This avoids polluting the global `apps` registry and creating tables unnecessarily. Pass every app label the test's models use.
- Tests run in parallel and may be shuffled or reversed. A test that passes alone but fails in the full suite indicates side effects between tests (`--bisect` and `--pair` help find them).

**Backends and coverage**
- Backend-specific tests are skipped on other backends. Per-backend skips and expected failures are declared in `DatabaseFeatures.django_test_skips` and `django_test_expected_failures`.
- The test settings define a `default` database and a second database named `other`, used for multi-database routing tests.
- CI posts a diff-coverage report on pull requests. It runs on SQLite on Windows, so code for other databases or platforms shows as uncovered. Treat missing coverage as "a warning rather than a blocker", and judge test quality beyond the coverage numbers.
