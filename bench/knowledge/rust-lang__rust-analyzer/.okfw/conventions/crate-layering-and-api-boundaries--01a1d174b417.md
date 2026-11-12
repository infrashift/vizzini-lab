---
id: "01a1d174-b417-7314-9d04-950e5569649d"
title: "Crate Layering and API Boundaries"
type: "Guideline"
tags:
  - "architecture"
  - "boundaries"
  - "crates"
  - "layering"
created: "2026-11-12T14:30:48-06:00"
timestamp: "2026-11-12T14:30:48-06:00"
description: "Which rust-analyzer crates are API boundaries and what each layer is forbidden to know about."
x:
  paths: ["crates/**", "lib/**"]
  source: ["docs/book/src/contributing/architecture.md", "docs/book/src/contributing/style.md", "docs/book/src/security.md"]
---

# Crate Layering and API Boundaries

rust-analyzer is organized in layers, and the architecture doc marks several **Architecture Invariants** that are about what is deliberately *absent*. A reviewer should flag code that adds a dependency or concept a layer is not supposed to have.

- **`parser`** is independent of the tree structure and token representation: it turns one flat stream of events into another, so it can parse both source text and `tt` macro input.
- **`syntax`** is "completely independent from the rest of rust-analyzer. It knows nothing about salsa or LSP." It is an **API boundary**. Syntax trees are value types: no global context (such as an interner) and no semantic info stored on the tree. A tree is built for a single file, which enables parallel parsing.
- **`base-db`** knows nothing about Cargo (cfg flags belong here, Cargo features do not) and nothing about the file system: files are opaque `FileId`s with no way to get a `std::path::Path` out.
- **`hir-expand`, `hir-def`, `hir-ty`** are the compiler core, ECS-flavored, working with raw ids. They "are not, and will never be, an api boundary."
- **`hir`** is an **API boundary**: an OO-flavored facade that presents a static, fully resolved, inert view of the code.
- **`ide`** (with `ide-db`, `ide-assists`, `ide-completion`, `ide-diagnostics`, `ide-ssr`) is an **API boundary** built from POD types with public fields, in editor terms (offsets, labels), conceptually serializable. Syntax trees and hir types are generally absent from its API. LSP must *not* shape its design.
- **`rust-analyzer`** is the only crate that knows about LSP and JSON serialization.
- **`mbe`, `tt`, `proc-macro-*`** are independent from the rest of the code.
- **`vfs`** does not assume a single unified file system; path APIs take an existing path as a "file system witness".
- **`stdx`** holds general utilities that are not rust-analyzer specific.

The style guide adds that new dependencies between components (a `pub use` re-export from another crate, or a new `[dependencies]` line) should be rare, and that "adding an innocent-looking `pub use` is a very simple way to break encapsulation". The security page notes the syntax tree library uses a lot of `unsafe` that has not been audited, so changes there deserve care.
