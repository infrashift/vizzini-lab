---
id: "01a1d174-b4e9-796d-9a73-587a57451b96"
title: "Avoiding Premature Pessimization"
type: "Guideline"
tags:
  - "performance"
  - "allocation"
  - "compile-time"
  - "generics"
created: "2026-11-12T14:30:49-06:00"
timestamp: "2026-11-12T14:30:49-06:00"
description: "The runtime and compile-time performance rules rust-analyzer's style guide asks reviewers to enforce."
x:
  paths: ["crates/**", "lib/**"]
  source: ["docs/book/src/contributing/style.md", "docs/book/src/contributing/architecture.md"]
---

# Avoiding Premature Pessimization

The style guide's "Premature Pessimization" section asks contributors not to write code that is slower than it needs to be. It also treats compile time as a cost to minimize.

**Allocations**
- Do not allocate a `Vec` where an iterator would do, and do not allocate strings needlessly. For example, use `itertools::collect_tuple` instead of collecting words into a `Vec` and checking its length.
- If an allocation is unavoidable, push it to the caller. Take `s: String` rather than taking `&str` and calling `to_string()` inside. This shows the cost and avoids a copy when the caller already owns the data.
- In recursive functions that compute sets of things, pass an accumulator (`acc: &mut FxHashSet<_>`) as the *first* argument instead of returning and merging fresh collections.
- Use `Vec::new` rather than `vec![]`.

**Collections**
- Prefer `rustc_hash::FxHashMap`/`FxHashSet` over `std::collections` hash maps. They are faster, and using them consistently slightly reduces code size.

**Monomorphization and compile time**
- Avoid making a lot of code type-parametric, especially on boundaries between crates. A common pattern is a thin generic wrapper (`impl FnMut()`) that forwards to a non-generic `&mut dyn FnMut()` implementation.
- Avoid `AsRef` polymorphism (`impl AsRef<Path>`). Take `&Path`. The doc says that only 20% of the code is hot at runtime, but compile time "does not obey this rule": all code has to be compiled.
- The conservative crates.io dependency policy also exists partly to keep compile times low.

**Observability**
The architecture doc describes the built-in hierarchical profiler (`RA_PROFILE`, cheap enough for production) and live object counting (`RA_COUNT=1`, not cheap). For performance work, `analysis-stats` runs a batch analysis, and `benchmark_xxx` tests and the `metrics` xtask exist. The docs say performance testing guidance is still "TBA", so there is no stated rule requiring benchmarks for a change.
