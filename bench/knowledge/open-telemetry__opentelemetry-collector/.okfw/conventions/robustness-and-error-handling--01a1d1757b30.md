---
id: "01a1d175-7b30-7491-b7b7-6f8d62ea3e12"
title: "Robustness and Error Handling"
type: "Guideline"
tags:
  - "error-handling"
  - "robustness"
  - "reliability"
created: "2026-11-12T14:31:39-06:00"
timestamp: "2026-11-12T14:31:39-06:00"
description: "How Collector code must handle errors, bad input and failures so that a long-running process never crashes or loses buffered data."
x:
  paths: ["receiver/**", "processor/**", "exporter/**", "connector/**", "extension/**", "scraper/**", "service/**", "otelcol/**", "confmap/**"]
  source: ["docs/coding-guidelines.md", "docs/security-best-practices.md"]
---

# Robustness and Error Handling

The coding guidelines describe the Collector as software that "runs autonomously and continuously without direct interaction with a human", and set robustness rules accordingly. A reviewer should check every change against them.

**Startup: fail fast.** Configuration is verified during startup and the process should fail if it is invalid, with a reasonable log message and a non-zero exit code. The security guide repeats this: the configuration MUST be validated before it is loaded, and an invalid configuration MUST stop the Collector from starting.

**Never exit outside `main()`.** Do not call `log.Fatal`, `os.Exit` or similar from library packages, even during startup. Return detailed errors to the caller instead, because non-`main` packages "may be imported and used by third-party applications" that need full control over error handling and process termination.

**Never crash after startup.** A running Collector holds data that receivers have already acknowledged (queues, processors). Crashing loses that data because senders will not resend it.

**Never crash on bad input.** Crash-only behaviour is explicitly rejected for the pipeline: senders retry the same payload, so a crash on bad input becomes an infinite crash loop. Bad input detected in a receiver should be reported back to the sender; elsewhere in the pipeline it may be too late to respond. In both cases keeping a metric that counts bad input is recommended.

**Be rigorous with errors.** "Don't ignore errors." Decide whether each error is fatal or transient:
- Fatal errors should be logged or recorded in an internal metric so users can see them.
- Transient errors need a retry strategy, typically exponential back-off; connection and send retries should use jitter so a recovering destination is not overwhelmed.

**Review checklist**
- No `panic`, `log.Fatal` or `os.Exit` reachable from component or library code paths.
- Errors are returned or handled, never silently dropped.
- Malformed payloads produce an error response or a counted drop, not a crash.
- Retry loops back off with jitter.
