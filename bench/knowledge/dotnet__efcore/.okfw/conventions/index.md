# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Breaking changes to public API and behavior](breaking-changes-to-public-api-and-behavior--01a1d175ef21.md) - EF Core avoids source, binary and behavioral breaking changes; any break must be called out explicitly and only lands when its value greatly outweighs the pain to existing applications.
* [Code style, API documentation and contribution workflow](code-style-api-documentation-and-contribution-workflow--01a1d175f2f5.md) - EF Core changes must follow the patterns and style of existing code, document every public member, and start from an issue discussed with the team.
* [No credentials or application data in messages and logs](no-credentials-or-application-data-in-messages-and-logs--01a1d175ef3b.md) - EF Core exception messages and log messages must never contain connection credentials, and by default must not contain application data unless sensitive data logging is enabled.
* [Package and provider structure](package-and-provider-structure--01a1d175f305.md) - EF Core is split into a core package, a shared relational layer for ADO.NET-based providers, provider packages, lightweight abstractions packages and design-time tooling.
* [SQL injection protection and parameterization](sql-injection-protection-and-parameterization--01a1d175ef2d.md) - Values in LINQ queries and the update pipeline must always be parameterized or escaped, raw SQL must use parameters, and migrations APIs are only designed for trusted input.
* [Testing expectations and SQL baselines](testing-expectations-and-sql-baselines--01a1d175f2e5.md) - EF Core changes need tests that fail without the change, all existing tests must pass, and SQL assertions record the exact SQL expected for each scenario.

