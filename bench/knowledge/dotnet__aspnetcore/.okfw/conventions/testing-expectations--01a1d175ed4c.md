---
id: "01a1d175-ed4c-772d-a0d2-3fc361f016bb"
title: "Testing expectations"
type: "Guideline"
tags:
  - "testing"
  - "xunit"
  - "ci"
created: "2026-11-12T14:32:09-06:00"
timestamp: "2026-11-12T14:32:09-06:00"
description: "Every bug fix or feature needs tests that follow nearby patterns, written with xUnit v3 and Moq, and must keep the Helix CI pipelines green."
x:
  paths: ["src/**/test/**", "src/**/tests/**"]
  source: ["CONTRIBUTING.md", ".github/copilot-instructions.md", ".github/pull_request_template.md", "docs/Helix.md", "docs/ProjectProperties.md", "docs/ReferenceResolution.md"]
---

# Testing expectations

## When tests are required

CONTRIBUTING.md says:

- "Tests need to be provided for every bug/feature that is completed."
- Tests are only needed for issues that need to be verified by QA (for example, not tasks).
- A scenario that is "far too hard to test" may go without a test, but "'Too hard' is determined by the team as a whole."
- Contributors should "add test coverage following existing patterns within the codebase."

The PR template asks whether unit or integration tests were included where applicable.

## How tests are written

From the repository's coding instructions:

- Tests use the **xUnit SDK v3**.
- Use **Moq** for mocking.
- Do not write "Act", "Arrange" or "Assert" comments.
- Copy the existing style in nearby files for test method names and capitalization.

Per area, tests run through that area's `build.sh` script, for example `./src/Http/build.sh -test`.

## Project setup for tests

- Only test projects may use `<ProjectReference>`. Product projects use `<Reference>`.
- Test-only or non-shipping projects disable the public API analyzers with `<AddPublicApiAnalyzers>false</AddPublicApiAnalyzers>`.
- Product internals can be exposed to a test assembly with `InternalsVisibleTo` items in the `.csproj`.
- Tests that depend on SQL Server set `TestDependsOnMssql` to `true`, so Helix machines install LocalDB.

## CI and quarantined tests

Tests run on Helix. The required PR check (aspnetcore-ci) runs non-quarantined tests on the required queues (Windows, macOS and Ubuntu). A separate pipeline runs only quarantined tests. If a change is likely to have cross-platform impact beyond the required queues, the author should run the full helix-matrix pipeline before merging. If a change breaks that pipeline, "you must either immediately revert your changes, or quarantine the test, its never ok to leave this pipeline in a broken state."

Area-specific testing rules exist for Blazor/Components (E2E tests) and for trimming and Native AOT, which use publish-based test projects instead of normal xUnit tests.
