---
id: "01a1d175-f2e5-7201-9971-fbb6dd38c96c"
title: "Testing expectations and SQL baselines"
type: "Guideline"
tags:
  - "testing"
  - "xunit"
  - "sql-baselines"
created: "2026-11-12T14:32:10-06:00"
timestamp: "2026-11-12T14:32:10-06:00"
description: "EF Core changes need tests that fail without the change, all existing tests must pass, and SQL assertions record the exact SQL expected for each scenario."
x:
  paths: ["test/**", "src/**"]
  source: [".github/CONTRIBUTING.md", "docs/getting-and-building-the-code.md", ".github/PULL_REQUEST_TEMPLATE.md", "test/EFCore.Specification.Tests/PACKAGE.md", "test/EFCore.Relational.Specification.Tests/PACKAGE.md", "test/EFCore.TrimmingTests/readme.md", "test/EFCore.NativeAotTests/readme.md"]
---

# Testing expectations and SQL baselines

**What a PR must include**

`CONTRIBUTING.md` asks contributors to "add tests that fail without the change and then pass with the change," and to "consider other scenarios where your change may have an impact and add more testing. We always prefer having too many tests to having not enough of them." When done, "make sure _all_ existing tests are still passing." The pull request template asks for confirmation that tests were added for bug fixes and features and that the code builds and tests pass locally. Tests are also the main defence against behavioral breaking changes.

**How tests are written and run**

- Tests use xUnit.net and run with the `test` script after `build`.
- SQL Server tests need a local SQL Server (LocalDb, or another edition with `Test__SqlServer__DefaultConnection` set). Cosmos tests need the Cosmos emulator and are skipped if it is not available; CI runs them otherwise.

**SQL assertions**

"EF Core tests contain many 'SQL assertions' - these verify that the precise expected SQL is generated for all scenarios." A change can ripple through many expected SQL strings. Setting `EF_TEST_REWRITE_BASELINES=1` and running the tests rewrites the assertions in the source with the new SQL. A reviewer should read rewritten baselines as part of the change: every changed SQL string is a change in generated SQL and may be a behavioral change for users.

**Specification tests**

`EFCore.Specification.Tests` and `EFCore.Relational.Specification.Tests` contain tests "that can be implemented and then used in database provider repos to test EF Core against that provider." They are shipped for external providers, so changes to them affect provider authors, not only this repository.

**Trimming and Native AOT tests**

`test/EFCore.TrimmingTests` and `test/EFCore.NativeAotTests` work differently from normal test projects: when `dotnet test` runs, a temporary project is generated for each file directly in the folder, published and executed, and return code 100 signals success. Source files in subfolders are added to all temporary projects.
