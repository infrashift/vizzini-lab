---
id: "01a1cae2-6846-7678-9ddb-239ab0fe4ec5"
title: "ADR-0002: Async all the way, no async void and no blocking on tasks"
type: "ADR"
tags:
  - "adr"
  - "async"
created: "2026-11-11T07:53:17-06:00"
timestamp: "2026-11-11T07:53:17-06:00"
description: "Asynchronous code returns Task, is awaited end to end, and never blocks with .Result or .Wait()."
x:
  paths: ["src/Services/**", "src/Controllers/**"]
---

# ADR-0002: Async all the way, no async void and no blocking on tasks

**Status:** Accepted

## Decision
- Methods that await return `Task`/`Task<T>`; `async void` is allowed only for UI event handlers, which this service has none of.
- Never block on a task with `.Result`, `.Wait()` or `GetAwaiter().GetResult()`; make the caller async instead.
- `HttpClient` instances come from `IHttpClientFactory` or one shared static instance; never `new HttpClient()` per call.
- Disposable resources (`StreamReader`, `DbCommand`, ...) are scoped with `using` / `await using`.
