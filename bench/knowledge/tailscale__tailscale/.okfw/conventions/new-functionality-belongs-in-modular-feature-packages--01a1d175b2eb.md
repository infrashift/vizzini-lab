---
id: "01a1d175-b2eb-726c-b9e4-de23f6027dab"
title: "New functionality belongs in modular feature packages"
type: "Guideline"
tags:
  - "architecture"
  - "modularity"
  - "features"
created: "2026-11-12T14:31:54-06:00"
timestamp: "2026-11-12T14:31:54-06:00"
description: "New client functionality should live in a self-contained feature/<name> package that installs itself via hooks from init, not be added to LocalBackend or ipn/ipnlocal."
x:
  paths: ["feature/**", "ipn/ipnlocal/**", "cmd/tailscaled/**"]
  source: ["feature/README.md"]
---

# New functionality belongs in modular feature packages

The `feature/` tree is Tailscale's modular feature system. Its stated purpose is to make individual features conditionally linkable, so resource-constrained builds can omit them, and so that "new code lives in small self-contained packages instead of being dumped into `LocalBackend`."

## Rules a reviewer should check

- **New functionality goes in `feature/<name>`.** The docs call this "the preferred home for new functionality." If any plausible user might not want the feature in their build ("which is almost always the case"), it should be modular from the start.
- **Wiring is done from the feature's own `init`.** A feature package installs itself into the rest of Tailscale through hooks, extensions and registrations from `init`, and calls `feature.Register("<name>")` there too.
- **No exported API for callers elsewhere.** A feature package "should not export API used by callers elsewhere in the tree; callers reach the feature through the hook, not by importing it." A change where core code imports a `feature/<name>` package directly to call its functions goes against this.
- **Code added to `ipn/ipnlocal` or similar needs justification.** The docs ask authors who believe their code is too core to be modular to imagine any user who might not want it, and to ask before "dumping code into `ipn/ipnlocal` or similar."

## The half-migrated tree

Much of the tree is half-migrated: a feature may have a `ts_omit_<name>` tag and some code in `feature/<name>/`, while significant code still lives in `ipn/ipnlocal`, `cmd/tailscaled` or elsewhere, behind a build-tag-gated file or an `if buildfeatures.HasFoo { ... }` block. When touching such a feature, prefer continuing to move code into its `feature/<name>` package rather than adding more to the old location. The docs say explicitly that one PR does not have to finish the migration.

## Checklist for a new feature (from the docs)

1. Add an entry to `Features` in `feature/featuretags/featuretags.go`, with any `Deps`.
2. Run `./tool/go generate ./feature/buildfeatures` (or `make generate`).
3. Create `feature/<name>/`, registering hooks, any `ipnext.Extension`, and `feature.Register` from `init`.
4. If on by default in `tailscaled`, add `feature/condregister/maybe_<name>.go`.
5. If `tsnet` should link it, add a `tsnet/maybe_<name>.go`.
6. Add a `deptest.DepChecker` test locking down what is not linked when omitted.
7. Regenerate depaware and review the diff.

For a new extension point, the docs ask contributors to ask first (a public GitHub issue for open-source contributors).
