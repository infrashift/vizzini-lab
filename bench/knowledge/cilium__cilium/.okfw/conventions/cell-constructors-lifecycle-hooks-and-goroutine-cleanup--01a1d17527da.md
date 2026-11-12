---
id: "01a1d175-27da-7075-9a0d-e1c3921c6c00"
title: "Cell constructors, lifecycle hooks and goroutine cleanup"
type: "Guideline"
tags:
  - "lifecycle"
  - "concurrency"
  - "resource-management"
  - "hive"
created: "2026-11-12T14:31:18-06:00"
timestamp: "2026-11-12T14:31:18-06:00"
description: "Constructors only validate and allocate; goroutines and I/O start in Start hooks, and Stop hooks must block until everything the cell created is cleaned up."
x:
  paths: ["pkg/**/*.go", "daemon/**/*.go", "operator/**/*.go"]
  source: ["Documentation/contributing/development/hive.rst"]
---

# Cell constructors, lifecycle hooks and goroutine cleanup

The hive guide sets rules for how a cell manages work and resources.

**Constructors have no side effects.** "A constructor function should only do validation and allocation. Spawning of goroutines or I/O operations must not be performed from constructors, but rather via the Start hook." The reason given is that the object graph is inspected (for example with `hive.PrintObjects` or the `hive` command), and side-effectful constructors would cause unwanted effects. A reviewer should flag a constructor that starts a goroutine, opens a socket or file, or calls the API server.

**Lifecycle hooks.** A lifecycle is a list of start and stop hook pairs. Hooks are appended in dependency order and run in that order on start and in reverse on stop. Hooks receive a `HookContext` so a start or stop can be aborted on Ctrl-C or on timeout. By default hive has a 5 minute start timeout and a 1 minute stop timeout, plus 5 seconds of grace before forced termination.

**Stop must fully clean up.** "Stop functions should make sure to block until all resources (goroutines, file handles, …) created by the module have been cleaned up (with e.g. `sync.WaitGroup`)." This keeps independent tests in the same suite from affecting each other. The docs say to use `goleak` to check that goroutines are not leaked.

**Fatal errors.** If a `Start()` hook hits a fatal error, it returns the error and aborts the start. After start, a component that cannot continue uses `hive.Shutdowner` (for example `ShutdownWithError`) to shut the hive down gracefully instead of crashing on its own.

**Background work via jobs.** The `job` package manages units of work in job groups and handles the lifecycle boilerplate:
- `OneShot` runs its callback once. Use it for post-start initialization, long-running routines, or anything you would otherwise start as a plain goroutine.
- `Timer` runs periodically (and can be triggered externally), for synchronization or garbage collection.
- `Observer` runs for each message of a `stream.Observable`.

When reviewing new background loops, check that they are tied to the cell lifecycle (a job or a Start/Stop pair) rather than started ad hoc. The code overview also names `pkg/controller` as the base controller for background operations that need retries or interval-based invocation, and `pkg/trigger` for event-driven functionality.
