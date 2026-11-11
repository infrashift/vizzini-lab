---
id: "01a1cb22-389c-7d56-bb22-00d672f96dec"
title: "ADR-0002: Secrets come only from the environment"
type: "ADR"
tags:
  - "adr"
  - "security"
  - "secrets"
created: "2026-11-11T09:02:59-06:00"
timestamp: "2026-11-11T09:02:59-06:00"
description: "API tokens, signing keys and passwords are read from the environment or the secret store at startup; never committed, and never defaulted to an empty value."
x:
  paths: ["src/**/*.ts"]
---

# ADR-0002: Secrets come only from the environment

**Status:** Accepted

## Decision
- Tokens, signing keys and passwords come from `process.env` (populated from the secret store), validated at startup.
- No secret literals in source, not even "temporary" ones.
- A missing secret fails startup. Never fall back to `""` or a default: an empty HMAC key verifies forged signatures.
- Compare secrets and MACs with `crypto.timingSafeEqual`, never `===`.
