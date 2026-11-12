---
id: "01a1d175-7c8f-7bca-bc66-79a23de866f1"
title: "Module Layout and Naming Conventions"
type: "Guideline"
tags:
  - "architecture"
  - "modules"
  - "naming"
  - "style"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "How code is split into Go modules and how components, functions, types and enumerations must be named."
x:
  paths: ["**/go.mod", "versions.yaml", "component/**", "consumer/**", "pdata/**", "confmap/**", "config/**", "pipeline/**", "receiver/**", "processor/**", "exporter/**", "connector/**", "extension/**", "scraper/**", "service/**", "otelcol/**"]
  source: ["docs/coding-guidelines.md", "docs/internal-architecture.md", "CONTRIBUTING.md"]
---

# Module Layout and Naming Conventions

**Module layout.** Related packages are grouped into modules so parts of the API can evolve independently:
- Each top-level directory is its own module, and each component the Builder can reference is its own module, named with the kind as suffix (`receiver/otlpreceiver`).
- Split modules when groups of packages evolve independently (`config/configgrpc` vs `config/confighttp`); sub-modules take the parent as prefix (`configauth`, `extensionauth`).
- Test helpers live in a `test`-suffixed submodule (`component/componenttest`); helpers shared across modules go in `internal/testutil`.
- Experimental code destined for a stable package goes in an `x`-prefixed submodule (`config/confighttp/xconfighttp`); experimental packages destined for another module get their own module named as they will be after integration (`pdata/pprofile`).
- A new module needs a changelog note, an entry in `versions.yaml`, `make crosslink` replaces, and updates to the otelcorecol manifest and builder tests.

**Architecture.** Each component kind has a `Factory` interface and `NewFactory` function used to register the component; the service builds a graph from configuration and starts components in reverse topological order. A new component implements `component.Component`, provides a config struct, and normally uses the helper factory structs.

**Component names.** Component identifiers in configuration MUST be `lower_snake_case` (`memory_limiter`, `otlp_http`); Go package names stay lowercase without underscores. Only `lower_snake_case` components should be marked stable; renamed components may keep the old name as a deprecated alias and MUST document the migration.

**Go API naming**
- Constructors using zero values or passed-in values are `New...`; constructors returning business-relevant defaults are `NewDefault...`; preconfigured package variables are `Default...`.
- Getters have no `get` prefix (`Name()`); setters use `Set` (`SetName`).
- A function acting on input must do only what its name says.
- Signal-specific types use the signal as adjective (`TracesSink`); multi-signal types describe the relation (`TracesToTracesFunc`); signal functions use the signal as object (`ConsumeTraces`).

**Enumerations** use a type definition over `int` or `string`, do not repeat the package name (`component.Type`), convey categorization (`pcommon.ValueType`, `component.Kind`), and prefix constants with the type name (`pmetric.MetricTypeGauge`).

New code should use `hash/fnv` for non-cryptographic hashing.
