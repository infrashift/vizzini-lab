---
id: "01a1d174-b45b-7ded-8730-bad0a3b026ad"
title: "Error Handling and Panic Resilience"
type: "Guideline"
tags:
  - "errors"
  - "panics"
  - "robustness"
  - "anyhow"
created: "2026-11-12T14:30:48-06:00"
timestamp: "2026-11-12T14:30:48-06:00"
description: "rust-analyzer treats broken code as data rather than an error, keeps core analysis infallible, and recovers from impossible conditions instead of asserting."
x:
  paths: ["crates/**"]
  source: ["docs/book/src/contributing/architecture.md", "docs/book/src/contributing/style.md", "AGENTS.md"]
---

# Error Handling and Panic Resilience

**Broken code is not an error.** The parser never fails: it returns `(T, Vec<Error>)` rather than `Result<T, Error>`. Analyses follow the same pattern. Syntax trees are incomplete by design and do not enforce well-formedness. If an AST method returns an `Option`, it *can* be `None` at runtime even when the grammar forbids that. Code that unwraps such options on the assumption that the grammar guarantees them is a review concern.

**The core cannot fail.** The core (`ide`/`hir`) does not interact with the outside world, so it cannot fail. "Only parts touching LSP are allowed to do IO." Look closely at IO or fallible external calls added to the analysis crates.

**Panics are contained, not relied on.** rust-analyzer is a long-running process that "will always have bugs and panics", but a panic in one feature must not bring down the whole process. Each LSP request runs inside `catch_unwind`. For impossible conditions, use the `stdx::never!` and `stdx::always!` macros instead of `assert!` so the code recovers gracefully. "Assert liberally", but prefer `never!`.

**Tests must not expect panics.** `#[should_panic]` tests are not allowed. Check explicitly for `None`, `Err`, and so on, because rust-analyzer "has to handle any user input without panics".

**Error type conventions** (from the style guide):
- Write `anyhow::Result` rather than a bare `Result`, so it is clear which result it is.
- Use `anyhow::format_err!` rather than `anyhow::anyhow`.
- Do not end error or context messages with `.`.
- Return an error with `return Err(err)`, not `Err(err)?`. `return` has type `!`, so the compiler can flag dead code.
- Use early returns to reduce cognitive load.

**Process isolation.** Proc macros can panic or segfault, so they run in a separate process (`proc-macro-srv-cli`) and the client recovers from fatal errors. Proc macros may also be non-deterministic, which conflicts with salsa, so changes there need special attention.
