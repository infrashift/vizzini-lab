---
id: "01a1d175-edbf-7b34-a8fe-06d7b517888f"
title: "EventSource and EventCounter conventions"
type: "Guideline"
tags:
  - "diagnostics"
  - "tracing"
  - "performance"
created: "2026-11-12T14:32:09-06:00"
timestamp: "2026-11-12T14:32:09-06:00"
description: "Naming, visibility, payload and enablement-check rules for EventSource tracing and EventCounters in ASP.NET Core libraries."
x:
  paths: ["src/**/*EventSource*.cs", "src/**/*EventSource*Tests.cs"]
  source: ["docs/EventSourceAndCounters.md"]
---

# EventSource and EventCounter conventions

`docs/EventSourceAndCounters.md` sets the following rules for adding `EventSource` and `EventCounter` tracing to an ASP.NET Core library.

## Type shape

- The event source name matches the containing assembly name with `.` replaced by `-` (for example `Microsoft-AspNetCore-Authentication`).
- Event sources are always `internal`.
- They declare a `private` parameterless constructor.
- They expose a `public static readonly` instance named `Log`.
- Type names end in `EventSource`.
- Keep all `[Event]` methods together, sorted by `eventId`. The `eventId` in the attribute must match the id passed to `WriteEvent`.

## Events

- Add `ILogger` tracing everywhere you add `EventSource` tracing "unless there's a really good reason not to."
- Name events `NounVerb` (`ConnectionStart`, not `StartConnection`), using present-tense verbs.
- Use the suffixes `Start`, `Stop` and `Failure`. Do not use `Begin`, `Started`, `Stopped`, `End` or `Ended`.
- Fire `Stop` even when `Failure` is also fired: "Treat `Stop` as a `finally` block."
- `Start`/`Stop` pairs share at least one correlating payload value, such as a request ID.
- `Stop` events include `double durationInMilliseconds`.
- Error events use `EventLevel.Error`.
- Payloads can only be primitives. Expand rich objects first, or use a `[NonEvent]` wrapper.
- Exceptions become three string payloads: `exceptionType` (assembly-qualified name), `exceptionMessage` and `exceptionDetails` (`ToString()`).
- Use descriptive payload names, such as `durationInMilliseconds` rather than `duration`.

## Performance rules

- Check `IsEnabled()` before doing work. Check `IsEnabled(level, keywords)` before computing payloads and writing the event.
- Use `ValueStopwatch` for timing, because it avoids a heap allocation. The `Start` method returns `default(ValueStopwatch)` when the event is disabled, and the `Stop` method checks `.IsActive`, so a disabled event pays nothing.
- Use keywords for events that should fire only when the listener explicitly asks for them.

## Counters

EventCounters are written whenever the source is enabled, without level or keyword checks.

- Count-style counters use `WriteMetric(1.0f)` and have plural-noun-plus-adjective names, such as `RequestsStarted`.
- Metrics use singular nouns, such as `RequestBodySize`.
- Durations are in milliseconds and end in `Duration`.
