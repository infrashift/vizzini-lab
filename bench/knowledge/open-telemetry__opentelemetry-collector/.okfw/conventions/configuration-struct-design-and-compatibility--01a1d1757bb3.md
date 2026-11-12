---
id: "01a1d175-7bb3-7d8a-9b90-51d0f52f3305"
title: "Configuration Struct Design and Compatibility"
type: "Guideline"
tags:
  - "configuration"
  - "backward-compatibility"
  - "api"
created: "2026-11-12T14:31:39-06:00"
timestamp: "2026-11-12T14:31:39-06:00"
description: "Rules for defining component configuration structs and for changing configuration options without breaking users."
x:
  paths: ["config/**", "confmap/**", "receiver/**/config.go", "processor/**/config.go", "exporter/**/config.go", "extension/**/config.go"]
  source: ["docs/coding-guidelines.md", "VERSIONING.md", "docs/component-stability.md", "docs/security-best-practices.md", "CONTRIBUTING.md"]
---

# Configuration Struct Design and Compatibility

**Struct design** (coding guidelines):
- Keep end-user YAML configuration and developer-set values in separate structs: end-user structs end in `Config` (`configgrpc.ClientConfig`), developer-set ones end in `Settings` (`component.TelemetrySettings`).
- Avoid prefixes the package already implies (`configgrpc.ClientConfig`, not `GRPCClientConfig`).
- Avoid embedded (anonymous) struct fields; use named fields with `mapstructure` tags. Embedding can break custom `Unmarshal` logic and cause field-name collisions. `mapstructure:",squash"` on a named field is allowed to keep an existing flat YAML layout, but new components should prefer nested configuration.
- Configuration packages should provide `NewDefault<Config>` functions that set defaults, and users should start from them.
- Configuration must come from the Collector's configuration file. Sensitive fields must use `configopaque.String` so they are masked when serialized.

**Compatibility** (VERSIONING.md). Configuration structs are public API:
- Adding fields and relaxing validation are allowed.
- Changing serialization struct tags (`yaml:`, `mapstructure:`) is breaking unless the result is functionally equivalent.
- Making `Validate` stricter is breaking, unless the config would already fail in its intended use.

**Changes by stability level** (component-stability.md):
- Alpha: options can change with minimal notice and a changelog entry; new options MAY be required without defaults; renames MAY keep an alias that logs a WARN.
- Beta and stable: a new required option MUST come with a sensible default. A renamed or removed option MUST be deprecated first, should log a WARN with a link to the migration path, MUST be kept at least one more version, and the option and warning MUST NOT be removed before N+2 or 6 months, whichever is later. Stable components MUST stay compatible between minor versions except for critical security issues.
- Once a component is `1.x`, signal-specific options MUST NOT break Go API compatibility even for signals that are not stable.

Reviewers should check that config changes include a changelog entry and, for user-facing breaks, a documented migration path.
