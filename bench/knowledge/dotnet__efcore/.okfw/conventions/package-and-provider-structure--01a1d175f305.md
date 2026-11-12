---
id: "01a1d175-f305-7b01-9de7-c7426f9a8276"
title: "Package and provider structure"
type: "Guideline"
tags:
  - "architecture"
  - "providers"
  - "packages"
created: "2026-11-12T14:32:10-06:00"
timestamp: "2026-11-12T14:32:10-06:00"
description: "EF Core is split into a core package, a shared relational layer for ADO.NET-based providers, provider packages, lightweight abstractions packages and design-time tooling."
x:
  paths: ["src/EFCore/**", "src/EFCore.Relational/**", "src/EFCore.Abstractions/**", "src/EFCore.SqlServer/**", "src/EFCore.SqlServer.Abstractions/**", "src/EFCore.Sqlite.Core/**", "src/EFCore.Cosmos/**", "src/EFCore.InMemory/**", "src/EFCore.Design/**", "src/EFCore.Analyzers/**", "src/Microsoft.Data.Sqlite.Core/**"]
  source: ["README.md", "src/EFCore/PACKAGE.md", "src/EFCore.Relational/PACKAGE.md", "src/EFCore.Abstractions/PACKAGE.md", "src/EFCore.SqlServer.Abstractions/PACKAGE.md", "src/EFCore.Design/PACKAGE.md", "src/EFCore.Analyzers/PACKAGE.md", "src/EFCore.Sqlite.Core/PACKAGE.md", "src/EFCore.InMemory/PACKAGE.md", "docs/security.md"]
---

# Package and provider structure

The repository holds Entity Framework Core and Microsoft.Data.Sqlite (`README.md`). EF Core "works with SQL Server, Azure SQL Database, SQLite, Azure Cosmos DB, MySQL, PostgreSQL, and other databases through a provider plugin API." The package descriptions show how responsibilities are split, which tells a reviewer where code belongs.

- **`Microsoft.EntityFrameworkCore`** (`src/EFCore`): the core: `DbContext`, LINQ queries, change tracking, updates. It pulls in the abstractions and analyzers packages automatically.
- **`Microsoft.EntityFrameworkCore.Relational`** (`src/EFCore.Relational`): "common code for relational database providers that are based on ADO.NET." It is a dependency of each relational provider. Behavior shared by all relational providers belongs here rather than in one provider.
- **Providers**: `src/EFCore.SqlServer`, `src/EFCore.Sqlite.Core` (with `src/EFCore.Sqlite` supplying the default native SQLite binary), `src/EFCore.Cosmos` and `src/EFCore.InMemory`, plus spatial (`*.NTS`) and `HierarchyId` extensions. The docs discourage using the in-memory provider for testing applications.
- **Abstractions packages** (`src/EFCore.Abstractions`, `src/EFCore.SqlServer.Abstractions`): installed "in places where it is undesirable to use the main package", for example to use mapping attributes or `HierarchyId` on POCO entity types that are otherwise independent of EF Core. Adding a dependency from these packages on the main packages would defeat that purpose.
- **Design-time tooling**: `src/EFCore.Design` is required by the command-line (`dotnet-ef`) and Package Manager Console (`EFCore.Tools`) tooling and installs with `PrivateAssets="All"` so it is not shipped with published apps. `src/EFCore.Tasks` provides build-time context optimization.
- **Analyzers** (`src/EFCore.Analyzers`): Roslyn rules shipped with the main package, including `EF1001` (`InternalUsageDiagnosticAnalyzer`) and the security rule `EF1002` for interpolated strings in raw queries.
- **Microsoft.Data.Sqlite** (`src/Microsoft.Data.Sqlite.Core`): the ADO.NET provider for SQLite.

All Microsoft-shipped `Microsoft.EntityFrameworkCore.*` packages must be installed at the same version. `docs/security.md` adds that EF "uses existing .NET APIs for all I/O operations and does not implement any protocols, file parsing, etc."
