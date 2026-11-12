---
id: "01a1d175-bf25-751b-8551-56810c241350"
title: "CLI command structure and where settings live"
type: "Guideline"
tags:
  - "cli"
  - "api-compatibility"
  - "configuration"
created: "2026-11-12T14:31:57-06:00"
timestamp: "2026-11-12T14:31:57-06:00"
description: "Guidelines for adding tailscale CLI surface: keep configurability low, prefer noun-verb subcommands and set/get preferences, keep up closed, and treat daemon flags and env vars as last resorts."
x:
  paths: ["cmd/tailscale/**", "cmd/tailscaled/**", "ipn/prefs.go"]
  source: ["docs/cli.md"]
---

# CLI command structure and where settings live

`docs/cli.md` gives guidance for growing the `tailscale` CLI (and, where relevant, `tailscaled`). It calls itself "defaults and tie-breakers, not laws," and says it does not require retrofitting older commands. CLI surface is described as "long-lived and hard to change once shipped," so CLI changes may get more design discussion than a typical bug fix.

## Keep configurability low

The project aims to keep the client's overall configurability low. It prefers getting the default right over "the easy 'now' work of adding another option," because wide configuration surfaces increase support load, multiply test combinations and "ossify into compatibility obligations." New options should be added deliberately and in the right place.

## Command structure

- The top-level command surface is "precious"; additions are effectively permanent. `set` and `get` are top-level because they are used so often.
- New feature-oriented designs should generally use `tailscale <noun> <verb>` (for example `tailscale <feature> status`), unless there is wide agreement that this is awkward.
- Prefer **singular** nouns (`tailscale cert`, `tailscale ip`).
- **`tailscale up` is closed for extension.** New configuration features should go into `set`, because `up` flags describe a complete desired state and a later call must repeat earlier flags or risk resetting them.
- Extend an existing command only in its spirit (for example, new target types for `tailscale ip`). Do not grow a command to match an external tool: `tailscale ssh` will not copy the full `ssh` flag surface.

## Debug commands

`debug` subcommands are "explicitly **not** subject to our usual compatibility promises." If one becomes load-bearing, it should be promoted and stabilized on purpose.

## Where settings live

- Most configuration should be **profile-local preferences** set and read with `set`/`get` and changeable at runtime.
- `tailscaled` flags are a last resort: only for settings that are truly process-global and immutable after launch. They are also "almost Linux-only" in practice, since GUI platforms make launch flags hard to change.
- Prefer preferences over environment variables, which are "hard to discover, hard to deprecate, and tend to leak into permanence."
- `TS_DEBUG`-style env knobs may be added freely for development, but are development-only and should not be documented or encouraged for public use.
