---
id: "01a1d175-b35d-7190-bd09-60f8dc469f75"
title: "Hooks and IPN extensions: per-backend state, not globals"
type: "Guideline"
tags:
  - "architecture"
  - "concurrency"
  - "hooks"
  - "ipn"
created: "2026-11-12T14:31:54-06:00"
timestamp: "2026-11-12T14:31:54-06:00"
description: "Rules for feature.Hook, feature.Hooks and ipnext extensions, including keeping state per LocalBackend and designing hooks for multiple writers."
x:
  paths: ["feature/feature.go", "feature/hooks.go", "ipn/ipnext/**", "ipn/ipnlocal/**", "feature/**/*.go"]
  source: ["feature/README.md", "tsnet/README.md"]
---

# Hooks and IPN extensions: per-backend state, not globals

## feature.Hook and feature.Hooks

- `feature.Hook[Func]` is a single-writer, single-reader hook. The extension point declares `var HookX feature.Hook[func(...)]`, the feature package `Set`s it once from `init`, and callers use `GetOk`/`GetOrNil`/`IsSet`. **`Set` panics if called twice.**
- `feature.Hooks[Func]` is a slice of hooks for extension points that "may legitimately have multiple registrants."
- Common cross-feature hooks live in `feature/hooks.go`. Add hooks there "only sparingly": every hook in that package is loaded by every consumer of `feature`, so its signature must not reference types from heavy packages (for example `net/http`, `crypto/tls`, `golang.org/x/crypto/ssh`, `k8s.io/...`, or packages using `reflect`-based registration). Prefer primitives, small `types/...` packages, or interfaces. If a hook needs a wide type, keep the hook and its dispatcher in the caller's package.

## IPN extensions

Features that need state and behavior attached to `LocalBackend` use `ipn/ipnext`. A feature registers a factory from `init` with `ipnext.RegisterExtension(name, newExtension)`. `LocalBackend.Start` creates one extension per backend and calls its `Init(host ipnext.Host) error`, where the extension adds its hooks on `host.Hooks()`. To get back to the extension from a LocalAPI or C2N handler, use `ipnlocal.GetExt[*yourExtType](b)`. The docs name `feature/taildrop/ext.go` and `feature/acme/acme.go` as canonical examples.

## State must be per backend

One process can host several `LocalBackend`s at once, because a `tsnet` program can run many `tsnet.Server` nodes concurrently. Package-global variables in a feature package would be shared across all of them, "which should be avoided unless it is otherwise infeasible." Hook registration is still process-global today, but the docs say not to rely on that: "keep state on the extension instance, not in globals." A reviewer should question new package-level mutable state in feature code.

## Hooks run synchronously and may conflict

Extension hooks "run synchronously with the triggering `LocalBackend` operation and can influence its outcome." Because several extensions may touch the same shared state (prefs, active profile, exit node), new hooks should be "designed with a clear conflict-resolution story rather than assuming a single writer."

The `ipnext` mechanism is a work in progress and not all of `LocalBackend` uses hooks yet; a new extension point is something to ask about before adding.
