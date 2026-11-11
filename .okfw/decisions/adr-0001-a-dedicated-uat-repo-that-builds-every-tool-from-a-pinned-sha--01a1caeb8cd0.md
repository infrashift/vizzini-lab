---
id: "01a1caeb-8cd0-7a8c-9bfb-0af6fcccd648"
title: "ADR-0001: A dedicated UAT repo that builds every tool from a pinned SHA"
type: "ADR"
tags:
  - "adr"
  - "build"
  - "reproducibility"
created: "2026-11-11T08:03:17-06:00"
timestamp: "2026-11-11T08:03:17-06:00"
description: "The UAT lives in its own repository and builds Vizzini, mrman, garmr and okfw from pinned commits, never from installed binaries or working trees."
---

# ADR-0001: A dedicated UAT repo that builds every tool from a pinned SHA

**Status:** Accepted

## Context
The suite crosses four repositories that change independently, and other agents are often editing them. Installed binaries drift from source; a working tree may hold half-finished edits.

## Decision
- `versions.env` pins a source and revision for each tool. `uat/build.sh` clones into `.cache/src` and builds with `CGO_ENABLED=0`. Every run records `build-manifest.json`.
- mrman uses the pinned Vizzini through a `go.work` in its clone, so unreleased Vizzini changes can be tested without editing mrman's `go.mod`.
- The LiteLLM image is pinned by tag and digest.

## Consequences
A run is reproducible from its manifest. Testing a branch means bumping one line in `versions.env`.
