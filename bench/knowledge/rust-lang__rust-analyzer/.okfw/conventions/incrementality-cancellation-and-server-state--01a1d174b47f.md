---
id: "01a1d174-b47f-715d-8cfe-eb1a14cbb4d3"
title: "Incrementality, Cancellation and Server State"
type: "Guideline"
tags:
  - "salsa"
  - "incremental"
  - "cancellation"
  - "concurrency"
  - "lsp"
created: "2026-11-12T14:30:48-06:00"
timestamp: "2026-11-12T14:30:48-06:00"
description: "The salsa-based invariants that changes to hir, ide and the language server must preserve: incremental invalidation, unwinding-based cancellation, a stateless server, and no IO in the analysis core."
x:
  paths: ["crates/base-db/**", "crates/hir/**", "crates/hir-def/**", "crates/hir-expand/**", "crates/hir-ty/**", "crates/ide/**", "crates/ide-db/**", "crates/rust-analyzer/**", "crates/vfs/**", "crates/project-model/**"]
  source: ["docs/book/src/contributing/architecture.md", "AGENTS.md", "docs/book/src/contributing/syntax.md"]
---

# Incrementality, Cancellation and Server State

**Inputs and derived data.** The analyzer keeps all input (file texts plus the `CrateGraph`) in memory and "never does any IO". `base-db` defines the salsa input queries, and everything else is strictly derived from them and computed lazily.

**The core incrementality invariant.** The `hir-*` crates "explicitly care about being incremental". The rule is: "typing inside a function's body never invalidates global derived data". If the body of `foo` changes, all facts about `bar` should stay intact. `ItemTree` exists to give a per-file summary that stays stable when function bodies change. HIR exists only for a particular crate instance with specific cfg flags, so the same syntax can produce several HIR instances.

**Cancellation requires unwinding.** When a change is applied, salsa bumps a global revision counter and waits for other threads to finish. A thread that notices the bump panics with a special value (`Cancelled`). `ide` is the boundary where that panic is caught and turned into `Result<T, Cancelled>`. Code must therefore not break unwinding through salsa computations.

**Threading in the server.** In `main_loop`, requests that modify state or might block the user's typing are handled on the main thread, and all other requests run in the background. The event loop is deliberately explicit: it accepts a closed `enum` of events instead of spawning futures or scheduling callbacks. The syntax doc adds that tree traversals run on a single thread. To send a syntax node to another thread, send the root `GreenNode` plus a range.

**Stateless server.** The server is stateless, like HTTP. When a follow-up request needs earlier context (for example, resolving a completion item), the request itself must carry enough information to rebuild that context from scratch, usually all the original parameters.

**Partial availability.** rust-analyzer should stay partially usable when the build is broken. The reload process (configuration and `Cargo.toml` changes) must not stop IDE features from working.

**Paths and cwd.** One process can serve many projects, so the project-model and toolchain crates use `crates/paths` (`AbsPathBuf`/`AbsPath`) instead of `std::path`, to avoid leaking the server's current directory.
