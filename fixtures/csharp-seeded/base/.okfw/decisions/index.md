# decisions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [ADR-0001: Data access only through repositories with parameterized queries](adr-0001-data-access-only-through-repositories-with-parameterized-queries--01a1cae26830.md) - All SQL lives in src/Repositories and is parameterized; controllers and services never build or run SQL.
* [ADR-0002: Async all the way, no async void and no blocking on tasks](adr-0002-async-all-the-way-no-async-void-and-no-blocking-on-tasks--01a1cae26846.md) - Asynchronous code returns Task, is awaited end to end, and never blocks with .Result or .Wait().

