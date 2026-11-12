---
id: "01a1d174-b532-70aa-93d0-2a4f8121f74e"
title: "Code Style and Naming"
type: "Guideline"
tags:
  - "style"
  - "naming"
  - "imports"
  - "formatting"
created: "2026-11-12T14:30:49-06:00"
timestamp: "2026-11-12T14:30:49-06:00"
description: "rust-analyzer's stated conventions for imports, item order, naming, matching, and comments that reviewers check beyond rustfmt."
x:
  paths: ["crates/**", "lib/**", "xtask/src/**"]
  source: ["docs/book/src/contributing/style.md", "AGENTS.md"]
---

# Code Style and Naming

The project does not block PRs on style alone, but the style guide states these as the house conventions.

**Imports and item order**
- Separate import groups with blank lines, in this order: `std`, external crates (including other rust-analyzer crates), `crate::`, then `super::`. Use one `use` per crate. `mod` declarations come first.
- Qualify `hir` and `ast` items (`hir::Function`, `ast::Struct`) instead of importing the bare names.
- When implementing `std::fmt` or `std::ops` traits, import the module (`fmt::Display`), not the trait or a fully qualified path.
- Avoid local `use MyEnum::*`. Prefer `use crate::foo::bar` over `super::`/`self::`. Avoid re-exports by default.
- Put public items first, and types before functions and impls, ordered top-down.

**Naming**
- Use boring, long local names, by default the lowercased type name (`global_state: GlobalState`). Use only established short forms (`db`, `ctx`, `acc`). Use American spelling.
- Standard names: `res` for a function's result, `it` when the name does not matter, `n_foos` for counts, `foo_idx` for indices.
- Use mangled names for keywords instead of `r#`: `krate`, `enum_`, `func`, `imp`, `mac`, `module`, `strukt`, `trait_`, `ty`.
- Write tokens as `T![foo]`, not `SyntaxKind::FOO_KW`.

**Expressions**
- Use `match` instead of `if let ... else`.
- Do not use the `ref` keyword. Write intentionally empty match arms as `=> (),`.
- For comparisons, use `<`/`<=` and avoid `>`/`>=`.
- Prefer a type annotation (`let v: Vec<T> = ...`) over the turbofish, and avoid `_` in the annotation.
- Use combinators only when natural. Mostly avoid `bool::then` and `Option::filter`. Introduce helper variables freely, especially for multiline conditions.

**Comments and docs**
- Write inline comments as proper sentences: start with a capital letter and end with a period.
- In `.md` files, write one sentence per line without wrapping.

**Commits and PRs**
- Do not @mention people in commit messages or PR descriptions.
- Write PR titles from the user's perspective. A `feat:`/`fix:`/`internal:`/`minor:` prefix marks the changelog category.
