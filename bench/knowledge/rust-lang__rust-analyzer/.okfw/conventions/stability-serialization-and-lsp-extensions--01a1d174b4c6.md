---
id: "01a1d174-b4c6-794c-a9ba-639669a2c4e5"
title: "Stability, Serialization and LSP Extensions"
type: "Guideline"
tags:
  - "compatibility"
  - "serialization"
  - "lsp"
  - "stability"
  - "configuration"
created: "2026-11-12T14:30:49-06:00"
timestamp: "2026-11-12T14:30:49-06:00"
description: "Where rust-analyzer does and does not promise stability, why internal types must not be serializable, and how LSP protocol extensions are kept in sync with their documentation."
x:
  paths: ["crates/rust-analyzer/src/lsp/**", "crates/rust-analyzer/src/config.rs", "crates/project-model/**", "crates/ide/**", "crates/base-db/**", "editors/code/src/**"]
  source: ["docs/book/src/contributing/architecture.md", "docs/book/src/contributing/lsp-extensions.md"]
---

# Stability, Serialization and LSP Extensions

**No new stability guarantees.** rust-analyzer avoids creating new stability promises and leans on existing ones. The `ide` API is explicitly unstable. The LSP interface is stable, but it is managed by someone else. Rust and Cargo are stable inputs. Because rust-analyzer does not run on CI, changing runtime behavior is acceptable.

**Known exceptions that need care:**
- `rust-project.json` is a de facto stable format for non-Cargo build systems. Treat changes to it as compatibility-sensitive. The doc's lesson is that an API which could become a stability boundary should be stable, or explicitly opt-in, *before* its first user.
- The shipped LSP extensions are kept "somewhat stable" for a finite set of editor maintainers.

**Serialization is a compatibility commitment.** `#[derive(Serialize)]` is "often too easy". A serializable type becomes part of an IPC boundary whose other side you do not control. So types in `ide`, `base_db` and below are not serializable by design. To expose an `ide` data structure over LSP, do not make it serializable. Create a serializable counterpart in the `rust-analyzer` crate and convert manually. Likewise, `rust-project.json` builds a `CrateGraph` through constructor functions instead of serializing it directly.

**LSP extensions.** Extensions are documented in `lsp-extensions.md`. That file records a hash of `lsp/ext.rs`, and a test checks it. Anyone who changes `ext.rs` and must update the hash should also check whether the document needs updating. All extension capabilities are advertised through the `experimental` field of client or server capabilities. Requests the project hopes to upstream live under the `experimental/` namespace. Rust-specific ones live under `rust-analyzer/`.

**Configuration defaults.** rust-analyzer aims to be highly configurable with reasonable defaults. The rule of thumb is to enable most features by default unless they are buggy or degrade performance too much, so users can discover them, and to let users tweak or disable them.
