---
id: "01a1d175-ef2d-7cae-8a34-af6f518a1cb8"
title: "SQL injection protection and parameterization"
type: "Guideline"
tags:
  - "security"
  - "sql"
  - "relational"
  - "migrations"
created: "2026-11-12T14:32:09-06:00"
timestamp: "2026-11-12T14:32:09-06:00"
description: "Values in LINQ queries and the update pipeline must always be parameterized or escaped, raw SQL must use parameters, and migrations APIs are only designed for trusted input."
x:
  paths: ["src/EFCore.Relational/**", "src/EFCore.SqlServer/**", "src/EFCore.Sqlite.Core/**", "src/EFCore.Analyzers/**", "src/EFCore.Design/**"]
  source: ["docs/security.md", "src/EFCore.Analyzers/AnalyzerReleases.Shipped.md"]
---

# SQL injection protection and parameterization

`docs/security.md` records "the security guarantees that we make in EF Core" and is meant for "designing, reviewing, and verifying Entity Framework to ensure it meets the agreed upon security principles." The document itself notes it was written while EF Core was pre-release, so not every guarantee may have been verified at the time; it still states the intended design.

**Guarantees relational providers must keep**

- **LINQ queries use parameterization and escaping.** "Any values supplied in a LINQ query will be appropriately parameterized or escaped to protect from SQL injection attacks," because values may come from an end user. A query filtering on a user-supplied last name must produce SQL like `WHERE [c].[LastName] = @p0`, not a literal.
- **The update pipeline uses parameterization and escaping.** "Any values that come from instance data (i.e. values stored in entity properties) will be parameterized or escaped." An insert of user-supplied names must use `VALUES (@p0, @p1)`.

A reviewer should treat any change in query translation, SQL generation or the update pipeline that inlines a value into SQL text without escaping as a violation of these guarantees.

**Raw SQL**

"Always use parameterization for any values used in a raw SQL query/command." If any part of a query string is built by string concatenation, the code doing so is responsible for validating the input. The shipped analyzer rules support this: `EF1002` (Security, Warning) is the `InterpolatedStringUsageInRawQueriesDiagnosticAnalyzer`, which points to the documentation on passing parameters.

**Migrations**

"The migrations APIs are designed to accept trusted values that are compiled into your application as part of migration code files." Most values are escaped, but some APIs, such as `Sql(string)` and the `defaultValueSql` parameter, are "pass-thru in nature and do not perform any validation or escaping." Changes should not present these APIs as safe for untrusted input.

**General assumptions** the document says to review when it changes: EF executes in the security context of the calling code and "cannot be used to do anything the calling code could not already do"; it uses existing .NET APIs for all I/O and "does not implement any protocols, file parsing, etc." A change that adds protocol or file-parsing code departs from these assumptions.
