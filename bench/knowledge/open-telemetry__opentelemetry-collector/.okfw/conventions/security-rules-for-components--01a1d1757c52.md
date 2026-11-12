---
id: "01a1d175-7c52-7dd1-bb11-4057b11e938d"
title: "Security Rules for Components"
type: "Guideline"
tags:
  - "security"
  - "configuration"
  - "networking"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Security requirements component developers must meet for configuration, secrets, network connections, privileges, extensions and external processes."
x:
  paths: ["receiver/**", "exporter/**", "extension/**", "config/configtls/**", "config/configopaque/**", "config/configgrpc/**", "config/confighttp/**", "config/configauth/**"]
  source: ["docs/security-best-practices.md", "docs/coding-guidelines.md", "CONTRIBUTING.md"]
---

# Security Rules for Components

The Collector "defaults to operating in a secure manner but is configuration driven". The security guide for component developers sets these rules.

**Configuration and secrets**
- The Collector has no embedded default configuration and MUST NOT start without a configuration file. The file MUST be validated before loading, and an invalid one MUST stop startup.
- Components MUST take configuration from the Collector's configuration file, and SHOULD use the shared configuration helpers under `config/`.
- Fields that may hold sensitive data must use `configopaque.String`, which masks the value when serialized. CONTRIBUTING repeats this for every new component.

**Network connections**
- Receivers and exporters, push or pull, SHOULD use a secure and authenticated channel.
- Components MUST default to encrypted connections (`insecure: false`) and SHOULD use the `configgrpc` and `confighttp` helpers rather than building transports by hand.

**Privileges**
- The Collector SHOULD NOT run as root/admin and, for most cases, SHOULD NOT need privileged access.
- Component developers SHOULD minimize privileged access and MUST document what needs privileged access (including network access or RBAC) and why.

**Extensions**
- Extensions SHOULD NOT expose health or telemetry data outside the Collector by default.

**Executing external processes** (coding guidelines)
Components should avoid running arbitrary external processes with arguments derived from user input, network input or the configuration file, since this can lead to remote code execution. If a process must run:
- hard-code and limit where the executable may live, instead of letting input set the full path;
- if possible, pick the executable name from a compile-time list;
- never pass user input directly as arguments; compose arguments indirectly and keep the space of possible values small.

**CGO** is prohibited for portability reasons. A package that must use it has to say so in its README with install instructions, and MUST still compile and run in a no-op mode or report a clear warning that CGO is required.

Reviewers should flag plaintext defaults, secrets stored as plain `string`, new listeners or endpoints that expose internal state by default, and `exec` calls driven by input.
