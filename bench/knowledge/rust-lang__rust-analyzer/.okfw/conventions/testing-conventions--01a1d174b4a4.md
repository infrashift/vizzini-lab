---
id: "01a1d174-b4a4-72cc-b1a7-80a7e1f872ad"
title: "Testing Conventions"
type: "Guideline"
tags:
  - "testing"
  - "expect-test"
  - "fixtures"
  - "minicore"
created: "2026-11-12T14:30:48-06:00"
timestamp: "2026-11-12T14:30:48-06:00"
description: "rust-analyzer's data-driven snapshot tests: what a new or changed feature's tests should look like and which test patterns are forbidden."
x:
  paths: ["crates/**/tests/**", "crates/**/tests.rs", "crates/test-utils/**", "crates/test-fixture/**", "crates/parser/test_data/**", "crates/syntax/test_data/**"]
  source: ["docs/book/src/contributing/architecture.md", "docs/book/src/contributing/testing.md", "docs/book/src/contributing/style.md", "docs/book/src/contributing/README.md", "AGENTS.md"]
---

# Testing Conventions

**Where to test.** The architecture doc names three system boundaries. The `ide` boundary is "the middle, and most important" one, and `hir` is the innermost. Heavy LSP integration tests in the `rust-analyzer` crate touch Cargo and real files, so the project avoids writing too many of them. They run only with `RUN_SLOW_TESTS=1`.

**Data-driven tests, not API tests.** Tests "are data driven and do not test the API". Calling API functions directly from many tests makes refactoring harder. The pattern is one `#[track_caller] fn check(input, expect)` helper that calls the API, plus many tests that pass only input text and an `expect![[...]]` snapshot. Snapshots use `expect-test` and are updated with `UPDATE_EXPECT=1`.

**Fixtures.** Input is a single string in a fixture mini-language. `$0` marks the cursor, `$0...$0` a range, and `// ^^^` labels the line above. `//- /file.rs crate:name deps:a,b` declares files and crates.

**No real std.** Tests do not use libcore or libstd. Any library code a test needs must be part of the test, via `//- minicore: flags` (for example `sized`, `fn`). If a test uses a type or trait, it must be included from `minicore`. Missing items can be added to `minicore` under a flag.

**Rules from the style guide:**
- Keep snippets minimal. Remove everything from copied real code that can be removed. Write multiline fixtures as unindented raw strings.
- Use `cov_mark::hit!`/`check!` for specific conditions. Use one mark per test and per condition, and never reuse a mark across tests.
- No `#[should_panic]`. Check for `None`/`Err` explicitly.
- No `#[ignore]`. If behavior is wrong, assert the current wrong behavior and add a fixme explaining why.

**Reproducibility and CI.** Tests do not depend on external resources. Every code invariant, including formatting and tidy checks, is enforced by `#[test]` under `cargo test`, with no extra CI-only checks.

**Parser and generated tests.** Parser tests compare `.rs` files under `test_data/parser` to `.txt` trees. Inline `// test name` comments in the grammar are collected by `cargo test -p xtask`, which must be re-run after adding one. Generated code (the AST from ungrammar, manual sections, assist doc tests) is committed and kept current by `cargo test`.
