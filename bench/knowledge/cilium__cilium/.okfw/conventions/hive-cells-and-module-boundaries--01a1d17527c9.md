---
id: "01a1d175-27c9-78c5-aa6f-e930cd4ec4a7"
title: "Hive cells and module boundaries"
type: "Guideline"
tags:
  - "architecture"
  - "hive"
  - "dependency-injection"
  - "go"
created: "2026-11-12T14:31:18-06:00"
timestamp: "2026-11-12T14:31:18-06:00"
description: "Cilium components are wired as hive cells through dependency injection, with interfaces as module APIs and no global state."
x:
  paths: ["pkg/**/*.go", "daemon/**/*.go", "operator/**/*.go"]
  source: ["Documentation/contributing/development/hive.rst", "Documentation/contributing/development/codeoverview.rst"]
---

# Hive cells and module boundaries

Cilium uses dependency injection via `pkg/hive` to wire up the initialization, starting and stopping of its components. Constructors declare their dependencies as function parameters; the hive builds the object graph. The docs give the reasons: it removes the need for centralized initialization and "reduces the inclination to use global variables over explicit passing of objects, which is often a source of bugs (due to unexpected initialization order) and difficult to deal with in tests."

Building blocks a reviewer will see:

- `cell.Module(id, title, ...)` groups cells under a short identifier (used in logging as `module=<id>`) and a one-line description.
- `cell.Provide` registers constructors. They are lazy: they run only if an `Invoke` references them, directly or indirectly. `ProvidePrivate` scopes a constructor to its module.
- `cell.Invoke` always runs and is used to instantiate and initialize objects.
- `cell.Decorate`, `cell.Config`, and metric cells round out the API.

Guidelines from the hive guide that apply to code review:

- "Use `Provide()` when you want to expose an object or an interface to the application. If there is nothing meaningful to expose, consider instead using `Invoke()`."
- Utility cells should not `Invoke()`. Utility cells should stay lazy so they are only instantiated when used.
- For large cells, provide interfaces, not struct pointers. Hive works with type names, so interfaces should be injected into the object graph. Large interfaces should be split into smaller ones; interfaces also make mock-based integration tests possible.
- Use parameter (`cell.In`) and result (`cell.Out`) structs freely; if a constructor takes more than two parameters, consider a parameter struct.
- The hive should be as static as possible: "the set of constructors and invoke functions should be determined at compile time and not be dependent on runtime configuration." Hive is built on reflection (uber/dig), so missing dependencies only show up at runtime. A static hive can be validated by a simple unit test (`daemon/cmd/cells_test.go`).

Logging is provided to every cell as `*slog.Logger`, tagged with the module id.

The code overview places shared Go packages in `pkg/`, the agent in `daemon/`, centralized tasks in `operator/`, and the eBPF datapath in `bpf/`. Datapath interaction is abstracted behind `pkg/datapath` and `pkg/bpf`, and Kubernetes interaction lives in `pkg/k8s`.
