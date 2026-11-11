---
id: "01a1cae2-6830-71f7-b6b5-4ab70d034cdb"
title: "ADR-0001: Data access only through repositories with parameterized queries"
type: "ADR"
tags:
  - "adr"
  - "persistence"
  - "security"
created: "2026-11-11T07:53:17-06:00"
timestamp: "2026-11-11T07:53:17-06:00"
description: "All SQL lives in src/Repositories and is parameterized; controllers and services never build or run SQL."
x:
  domain: "Shop"
---

# ADR-0001: Data access only through repositories with parameterized queries

**Status:** Accepted

## Context
The shop database holds customer and payment data. Ad-hoc SQL scattered across controllers made injection review impossible and duplicated query logic.

## Decision
- All SQL lives in `src/Repositories/`. Controllers and services call repository methods; they never take a `DbConnection`, create a `DbCommand`, or set `CommandText`.
- Every value reaches SQL as a `DbParameter`. Building `CommandText` by concatenation or interpolation of any input is forbidden, including `LIKE` patterns (pass `prefix + "%"` as the parameter value).
- Connection strings come from configuration (`IConfiguration` / environment), never from source.

## Consequences
A reviewer only has to audit one folder for SQL. A controller that touches `DbConnection` is an architecture violation even when its query is currently safe.
