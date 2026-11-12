---
id: "01a1d175-0163-7f25-b286-7e92d5d1ff56"
title: "Testing expectations for bug fixes and features"
type: "Guideline"
tags:
  - "testing"
  - "review"
  - "pull-requests"
created: "2026-11-12T14:31:08-06:00"
timestamp: "2026-11-12T14:31:08-06:00"
description: "Bug fixes should come with a failing test committed before the fix, features need unit or integration tests, and each kind of problem has its own test project."
x:
  paths: ["tests/**", "src/**"]
  source: ["CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md", "tests/Avalonia.IntegrationTests.Appium/readme.md", "tests/Avalonia.LeakTests/Readme.txt", "tests/BuildTests/readme.md"]
---

# Testing expectations for bug fixes and features

`CONTRIBUTING.md` sets different test expectations for bug fixes and features. The PR template checklist also asks "Added unit tests (if possible)?".

## Bug fixes

A bug fix should ideally come with a test. It is not always feasible, but a test speeds up review. The commits in a bug-fix PR **should follow this pattern**:

1. a commit that adds a failing test, then
2. a commit that fixes the issue.

This lets the reviewer check out the first commit, confirm the problem, and then confirm the fix.

## Features

Features should always include unit tests or integration tests where possible. The one stated exception is DevTools, which has no tests. A new control whose behaviour is hard to unit test should get an integration test.

## Where tests belong

- **Unit tests** cover issues not tied to platform features. They live under `tests/`, grouped by the assembly under test (for example `tests/Avalonia.Controls.UnitTests`, `tests/Avalonia.Base.UnitTests`).
- **Integration tests** cover platform features, such as window resizing. They live in `tests/Avalonia.IntegrationTests.Appium` and should be run on Windows (WinAppDriver) and macOS (Appium). They drive `samples/IntegrationTestApp`.
- **Render tests** cover rendering problems. They live in `tests/Avalonia.RenderTests` and are imported into the `Avalonia.Skia.RenderTests` project.
- **Memory leak tests** in `tests/Avalonia.LeakTests` use JetBrains dotMemory Unit. In a normal test runner they always pass; they only check for leaks when run under dotMemory Unit, so a green run there proves nothing about leaks.
- `tests/BuildTests` holds projects built by the `VerifyXamlCompilation` target. They are not in the main solution because they need locally built Avalonia NuGet packages.

## Test naming

Tests do not use the usual method naming convention. Name them as an English sentence separated by underscores that says what is being tested, for example `Calling_Foo_Should_Increment_Bar`. Render test names describe the image produced, for example `Rectangle_2px_Stroke_Filled`.
