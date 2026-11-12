---
id: "01a1d174-858c-7079-b610-c0dd0459f3bc"
title: "Concurrency verification with loom, miri and fuzzing"
type: "Guideline"
tags:
  - "concurrency"
  - "testing"
  - "unsafe"
  - "rust"
created: "2026-11-12T14:30:36-06:00"
timestamp: "2026-11-12T14:30:36-06:00"
description: "Tokio's concurrent and unsafe internals are checked with loom model tests, miri and cargo-fuzz harnesses, each run with specific flags."
x:
  paths: ["tokio/src/**", "tokio-util/src/**", "tokio/fuzz/**", "tokio-stream/fuzz/**", "tokio/src/loom/**"]
  source: ["CONTRIBUTING.md", "README.md"]
---

# Concurrency verification with loom, miri and fuzzing

Tokio describes itself as leveraging "Rust's ownership, type system, and concurrency model to reduce bugs and ensure thread safety" (`README.md`). Beyond normal tests, `CONTRIBUTING.md` documents three tools used to check concurrent and low-level code. A reviewer looking at changes to synchronization primitives, the scheduler, intrusive data structures or other unsafe code should expect them to keep passing, and new concurrent logic to be covered by them where it fits.

**loom**

Loom tests run under the `loom` cfg, from inside the `tokio` crate:

```
cd tokio
LOOM_MAX_PREEMPTIONS=1 RUSTFLAGS="--cfg loom" \
    cargo test --lib --release --features full -- --test-threads=1 --nocapture
```

The loom tests are part of the library test suite (`--lib`) and are enabled only by `--cfg loom`, so code paths gated on that cfg must keep compiling.

**miri**

```
MIRIFLAGS="-Zmiri-disable-isolation -Zmiri-tag-raw-pointers" \
    cargo +nightly miri test --features full --lib
```

**Fuzzing**

"Some of our crates include a set of fuzz tests, this will be marked by a directory `fuzz`. It is a good idea to run fuzz tests after each change." Fuzzing uses `cargo-fuzz`; `cargo fuzz list` shows the harnesses (for example `fuzz_linked_list` in the `tokio` crate) and `cargo fuzz run <name>` runs one. A harness runs until interrupted or until it finds a bug.

**Conditional compilation**

All of these depend on `--cfg` flags passed through `RUSTFLAGS`. The guide notes that Tokio uses conditional compilation attributes "throughout the codebase", so a reviewer should check that new code compiles and behaves correctly under the relevant cfgs (`loom`, `tokio_unstable`, `docsrs`) as well as with `--all-features`.

The docs give commands but no further policy on when each tool is mandatory; treat them as the project's expected way to verify concurrency-sensitive changes.
