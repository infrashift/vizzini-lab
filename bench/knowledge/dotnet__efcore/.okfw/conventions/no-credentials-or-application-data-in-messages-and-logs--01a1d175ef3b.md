---
id: "01a1d175-ef3b-722b-9895-b0bc69fb0283"
title: "No credentials or application data in messages and logs"
type: "Guideline"
tags:
  - "security"
  - "logging"
  - "diagnostics"
  - "exceptions"
created: "2026-11-12T14:32:09-06:00"
timestamp: "2026-11-12T14:32:09-06:00"
description: "EF Core exception messages and log messages must never contain connection credentials, and by default must not contain application data unless sensitive data logging is enabled."
x:
  paths: ["src/EFCore/Diagnostics/**", "src/EFCore.Relational/Diagnostics/**", "src/EFCore.SqlServer/Diagnostics/**", "src/EFCore.Sqlite.Core/Diagnostics/**", "src/EFCore.Cosmos/Diagnostics/**", "src/EFCore.InMemory/Diagnostics/**", "src/**"]
  source: ["docs/security.md"]
---

# No credentials or application data in messages and logs

`docs/security.md` defines several guarantees about what EF Core writes into messages and logs. They apply to every place that builds an exception message or calls a registered `ILogger`, including command-line tools such as migrations, whose status output "use[s] standard `ILogger` functionality and conform[s] to the contents of this document."

**Definitions used by the document**

- *Logging*: data sent to the `Write` method of an `ILogger` registered with EF, including loggers from an external service provider.
- *Message*: any string that may be logged or displayed, including `Exception.Message`, `Exception.ToString()` and the message produced for `ILogger`.
- *Application data*: data from the data store or supplied by end users, such as query results, entity property values and constants used in LINQ expressions.

**Guarantees**

1. **Messages do not contain data store credentials.** Credentials from a connection string or other connection information are never included in a message. Other information, such as the database name, may be logged.
2. **Messages do not contain application data** by default, because messages may be shown to end users or written to logs with weaker permissions than the database.
3. **Logging state does not contain application data.** State passed to `ILogger.Write` (the state and exception parameters) must not reference application data "or objects from which application data can be obtained", since logging frameworks may persist that state.

Guarantees 2 and 3 no longer apply when the sensitive-data logging flag (`IncludeSensitiveDataInLog` in the document) is enabled. With it on, messages may contain application data and logger state may reference it; for example, the query model and its parameters may be included when EF logs that a query is about to be sent.

**Known exceptions to keep in mind**

- Exception *objects* may expose application data through properties even though their messages do not; `DbUpdateConcurrencyException.StateEntries` gives access to change-tracking entries.
- Messages may contain model and schema information, such as entity type names.

**Review checklist**: new log events and exception messages must not interpolate connection strings, passwords, parameter values or entity property values unless the output is gated on sensitive-data logging being enabled.
