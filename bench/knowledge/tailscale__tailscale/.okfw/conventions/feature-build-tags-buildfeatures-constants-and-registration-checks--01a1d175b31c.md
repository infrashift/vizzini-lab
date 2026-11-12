---
id: "01a1d175-b31c-704e-91fd-e26ab9ad1ccd"
title: "Feature build tags, buildfeatures constants and registration checks"
type: "Guideline"
tags:
  - "architecture"
  - "build-tags"
  - "features"
created: "2026-11-12T14:31:54-06:00"
timestamp: "2026-11-12T14:31:54-06:00"
description: "How ts_omit_* build tags, generated buildfeatures constants, condregister shims and feature.IsRegistered fit together, and the mistakes to look for."
x:
  paths: ["feature/featuretags/**", "feature/buildfeatures/**", "feature/condregister/**", "tsnet/*.go", "feature/feature.go"]
  source: ["feature/README.md"]
---

# Feature build tags, buildfeatures constants and registration checks

## Registry and generated constants

`feature/featuretags/featuretags.go` is "the single source of truth": a `Features` map recording, per lowercase feature tag, the exported symbol name, a description, and the features it depends on (a DAG). Feature `foo` maps to the opt-out build tag `ts_omit_foo`; the one exception is `cli`, which is opt-in via `ts_include_cli`. Internal plumbing features can be marked `ImplementationDetail: true`.

After editing `featuretags.go`, `./tool/go generate ./feature/buildfeatures` (or `make generate`) regenerates a `feature_<name>_enabled.go` / `feature_<name>_disabled.go` pair exporting a boolean constant such as `HasACME`. A reviewer should expect these generated files to change together with `featuretags.go`. The `featuretags` self-tests check that every `ts_omit_*` string anywhere in the tree is declared in the map.

## Constants versus build-tagged files

`if buildfeatures.HasFoo { ... }` is dead-code-eliminated when the feature is omitted. But "constants can eliminate *code* but they cannot remove *imports*"; removing an import still needs a build-tag-gated file. Use constants when moving code into `feature/<name>` is impractical (for example, code that must sit inside `LocalBackend`) or when a small conditional is clearer than splitting files. Separate packages are preferred when possible.

## condregister shims

`feature/condregister` is the package `tailscaled` empty-imports so that on-by-default features get registered. Each such feature has a `maybe_<name>.go` that is just a `//go:build !ts_omit_<name>` line and a blank import of `tailscale.com/feature/<name>`. Extra platform tags may be added (for example `!ios`).

**The `feature/<name>` package itself should not carry a `ts_omit_*` tag.** The omit tag lives only on the `maybe_<name>.go` shims, so any program can opt in with a blank import regardless of the top-level tags. OS-specific tags inside the feature package are fine and often desirable.

## tsnet is different

`tsnet` does not import `condregister`; it has its own `maybe_*.go` files and its own `depaware.txt`. Therefore `buildfeatures.HasFoo == true` does not mean feature `foo` was linked: it only means "not explicitly omitted by build tag." Whether the feature is present is `feature.IsRegistered("foo")`. The documented idiom is:

    buildfeatures.HasFoo && feature.IsRegistered("foo")

Code that checks `HasFoo` alone and then assumes the feature's hooks are installed is the mistake the docs warn about.
