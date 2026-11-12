---
id: "01a1d174-85a0-7cb4-b089-e4f6889d5717"
title: "Formatting, lints and commit conventions"
type: "Guideline"
tags:
  - "style"
  - "rust"
  - "lint"
  - "commits"
created: "2026-11-12T14:30:36-06:00"
timestamp: "2026-11-12T14:30:36-06:00"
description: "Tokio code is formatted with rustfmt for edition 2021 (not cargo fmt), linted with the CI's pinned clippy version, and committed with crate-prefixed lowercase messages."
x:
  paths: ["tokio/src/**", "tokio-util/src/**", "tokio-stream/src/**", "tokio-macros/src/**", "tokio-test/src/**", "tokio/tests/**", "examples/**", "benches/**"]
  source: ["CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md"]
---

# Formatting, lints and commit conventions

**Formatting**

"The `cargo fmt` command does not work on the Tokio codebase." Formatting is checked with rustfmt directly over all tracked Rust files:

```
rustfmt --check --edition 2021 $(git ls-files '*.rs')
```

Without `--check`, rustfmt rewrites the files. A diff with formatting that this command would change is not ready to merge.

**Lints**

Lint with clippy across all crates, tests and features. "Ideally, you should use the same version of clippy as the one used in CI (defined by `env.rust_clippy` in ci.yml), because newer versions might have new lints":

```
cargo +<ci version> clippy --all --tests --all-features
```

Because features are used extensively, `cargo build`, `cargo check` and `cargo test` all need `--all-features` to cover the whole codebase.

**Commits**

Keep changes logically grouped in commits; squash "checkpoint" commits that are not a single logical change. Once a PR is open, do not rebase or squash commits added during review; they may be squashed when landed. A commit message should describe what changed and why:

1. First line: a short description (preferably 50 characters or fewer, no more than 72), entirely lowercase except proper nouns, acronyms and code identifiers, prefixed with the sub-crate name without `tokio-` (omit the prefix for `tokio` itself), starting with an imperative verb. Example: "timer: introduce `Timeout` and deprecate `Deadline`".
2. Second line blank.
3. Other lines wrapped at 72 columns, except long URLs.
4. Issue references go at the end as `Fixes:` or `Refs:` lines.

**Review priorities**

The guide tells reviewers not to "micro-optimize and make everything about relative performance, perfect grammar, or exact style matches." Focus first on whether the change makes sense for Tokio, whether it makes Tokio better even incrementally, whether there are clear bugs or larger issues, and whether the commit message is correct and clear about breaking changes. "Only incremental improvement is needed to land a PR." Mark non-essential comments clearly as nits, e.g. "Nit: change foo() to bar(). But this is not blocking." Large changes should first be discussed in an issue.
