# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Configuration Struct Design and Compatibility](configuration-struct-design-and-compatibility--01a1d1757bb3.md) - Rules for defining component configuration structs and for changing configuration options without breaking users.
* [Feature Gates for User-Facing Breaking Changes](feature-gates-for-user-facing-breaking-changes--01a1d1757bfa.md) - When and how to use feature gates to roll out end-user breaking changes through the alpha, beta and stable stages.
* [Go API Compatibility, Deprecation and Interface Evolution](go-api-compatibility-deprecation-and-interface-evolution--01a1d1757b8a.md) - How exported Go APIs in the Collector modules may change, including the two-step deprecation rule and the sealed versus open interface patterns.
* [Module Layout and Naming Conventions](module-layout-and-naming-conventions--01a1d1757c8f.md) - How code is split into Go modules and how components, functions, types and enumerations must be named.
* [Resource Limits, Shutdown, Logging and Internal Telemetry](resource-limits-shutdown-logging-and-internal-telemetry--01a1d1757b5c.md) - Rules for bounding resource use, shutting down within a time limit, logging sparingly and defining internal metrics through metadata.yaml.
* [Robustness and Error Handling](robustness-and-error-handling--01a1d1757b30.md) - How Collector code must handle errors, bad input and failures so that a long-running process never crashes or loses buffered data.
* [Security Rules for Components](security-rules-for-components--01a1d1757c52.md) - Security requirements component developers must meet for configuration, secrets, network connections, privileges, extensions and external processes.
* [Testing and Change Scope Expectations](testing-and-change-scope-expectations--01a1d1757cc1.md) - What tests a change must carry and how narrowly a pull request must be scoped in the Collector repository.
* [pdata Ownership and API Rules](pdata-ownership-and-api-rules--01a1d1757c25.md) - Who may read or modify pipeline data at each point in a pipeline, and the structural rules every pdata type must follow.

