---
id: "01a1d175-7b8a-760c-b409-b497e4260b76"
title: "Go API Compatibility, Deprecation and Interface Evolution"
type: "Guideline"
tags:
  - "api"
  - "backward-compatibility"
  - "deprecation"
  - "interfaces"
created: "2026-11-12T14:31:39-06:00"
timestamp: "2026-11-12T14:31:39-06:00"
description: "How exported Go APIs in the Collector modules may change, including the two-step deprecation rule and the sealed versus open interface patterns."
x:
  paths: ["component/**", "consumer/**", "pdata/**", "confmap/**", "config/**", "featuregate/**", "pipeline/**", "client/**", "receiver/**", "processor/**", "exporter/**", "connector/**", "extension/**", "scraper/**", "service/**", "otelcol/**"]
  source: ["docs/coding-guidelines.md", "VERSIONING.md", "CONTRIBUTING.md", "docs/rfcs/component-interfaces.md"]
---

# Go API Compatibility, Deprecation and Interface Evolution

Component developers and library users depend on the Go API of modules such as `pdata`, `component`, `consumer`, `confmap`, `exporterhelper` and `config*`, so API changes need the same care as behaviour changes. Modules at `v1` or above follow the Go 1 compatibility promise.

**Two-step deprecation.** API breaking changes happen in two releases:
- To remove something, it MUST be deprecated in one version and MAY be removed in a later one.
- To rename or refactor, the new name MUST be added and the old one deprecated in the same version; for simple renames the old name SHALL call the new one.
- Changing a return type or arguments goes through a new function first (for example a `MustGetFoo` or `GetFooWithContext` variant) while the old one is deprecated.
- The deprecation godoc should name the version: `// Deprecated: [v0.45.0] Use MustDoFoo instead.` Add a `//go:fix inline` directive where applicable.
- Exception for modules below `v1`: adding a variadic parameter (functional options) without changing behaviour may skip deprecation, but only when the function is not commonly passed as a value. It is still a breaking change for the changelog.

**What is not guaranteed** (VERSIONING.md): unkeyed struct literals, dot imports, method conflicts from embedding, `String`/`Error` output, and experimental methods exposed through optional interfaces in experimental modules.

**Interface evolution.** Exported interfaces MUST follow one of two patterns:
- **Sealed** interfaces (for example `receiver.Factory`, `component.Host`) contain an unexported method so only package constructors create them. They grow by adding methods together with `<Method>Func` types and functional options. Major interfaces SHOULD use functional options even with no options yet.
- **Open** (optional) interfaces (for example `extensionmiddleware.GRPCClient`, `extensionauth.Client`) are discovered with type assertions. They MUST NOT change until a major version; new capabilities go into new companion interfaces.

A reviewer should flag any added method on an open interface, any removal or signature change without a prior deprecation, and new exported interfaces that are neither sealed nor clearly optional. Changes to exported elements also need a `.chloggen` entry.
