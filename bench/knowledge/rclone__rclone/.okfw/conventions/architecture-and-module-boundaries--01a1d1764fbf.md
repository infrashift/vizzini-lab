---
id: "01a1d176-4fbf-703e-9191-fbf0df1b3d4d"
title: "Architecture and module boundaries"
type: "Guideline"
tags:
  - "architecture"
  - "modules"
  - "backends"
created: "2026-11-12T14:32:34-06:00"
timestamp: "2026-11-12T14:32:34-06:00"
description: "How rclone is split into fs core, backends, commands, lib and vfs, and why core code must stay backend-agnostic."
x:
  paths: ["rclone.go", "fs/**", "vfs/**", "backend/all/**", "cmd/all/**", "lib/**"]
  source: ["AGENTS.md", "CONTRIBUTING.md"]
---

# Architecture and module boundaries

Rclone is organised into a small number of top-level directories with modules beneath them (CONTRIBUTING.md, "Code Organisation"):

- `backend/` holds one Go package per cloud provider; `backend/all` is imported to load them all.
- `cmd/` holds one package per command; `cmd/all` is imported to load them all. Commands use cobra via `cmd.Main()`.
- `fs/` holds the main rclone definitions and is meant to contain "minimal amount of code". Subpackages cover accounting, config, filter, fserrors, fshttp, fspath, hash, list, log, march, operations, sync and walk.
- `lib/` holds libraries used by the backends: atexit, dircache, oauthutil, pacer, readers, rest, encoder and others.
- `vfs/` is the virtual filesystem layer used by mount and the serve commands.
- `fstest/` is the integration test framework, and `librclone/` exposes rclone's API for embedding.

## Registration

`rclone.go` is the entry point. It imports `backend/all` and `cmd/all`, which use Go `init()` functions to register everything. Each backend calls `fs.Register()` with an `fs.RegInfo` (name, config options, NewFs constructor) during init. A new backend or command must be added to the matching `all/all.go` file with a blank import.

## Core interfaces

`fs.Fs` and `fs.Object` in `fs/types.go` are the interfaces every backend implements (List, NewObject, Put, Mkdir, Rmdir; Open, Update, Remove, SetModTime). `fs.Features` in `fs/features.go` declares optional capabilities as function pointers, and nil means the backend does not support that operation.

## Boundary rule for reviewers

AGENTS.md says it plainly: the core parts of rclone under `fs` and `vfs` must work with all backends, and **backend-specific hacks won't be merged**. A fix for one provider belongs in that backend. If new behaviour really is needed in the core, it should be expressed through a new Feature flag rather than by checking for a particular backend. Changes "should consider both known and unknown backends". CONTRIBUTING.md also notes that rclone "was designed to be modular", so backends and commands can be kept out of tree or loaded as plugins.

When reviewing a change to `fs/` or `vfs/`, check that it does not name or special-case a specific backend. Check also that new capability-dependent behaviour is keyed off `fs.Features`, and that it falls back sensibly when the feature is nil.
