---
id: "01a1d174-b43b-7729-a5f1-38042f88771c"
title: "Scope of Changes and Dependencies"
type: "Guideline"
tags:
  - "review"
  - "api"
  - "dependencies"
  - "process"
created: "2026-11-12T14:30:48-06:00"
timestamp: "2026-11-12T14:30:48-06:00"
description: "How rust-analyzer classifies a change by its effect on pub items and dependencies, and how conservative it is about new crates.io dependencies."
x:
  paths: ["crates/**", "lib/**", "Cargo.toml", "crates/*/Cargo.toml"]
  source: ["docs/book/src/contributing/style.md", "CONTRIBUTING.md", "AGENTS.md"]
---

# Scope of Changes and Dependencies

The style guide asks reviewers to watch the boundaries between components and sorts changes into three kinds:

1. **Internals of one component change** and no `pub` items change (for example, a new assist). Such a change is generally merged as long as it works for the happy case, it has tests, and it does not panic for the unhappy case.
2. **A component's API grows** with a new `pub` function. This gets "quite a bit of scrutiny and iteration". The new API needs to be right, or at least easy to change later. Keep the number of changed lines small. If a change of the first kind turns out to need API changes, maintainers will probably ask for the API change to go in a separate PR.
3. **A new dependency between components**, either a `pub use` re-export from another crate or a new line in a `Cargo.toml` `[dependencies]` section. This should be rare. Watch `pub use` closely because it easily breaks encapsulation.

**crates.io dependencies.** The project is "very conservative" about them. Do not add small "helper" crates. `itertools` and `either` are the allowed exceptions. A generally reusable bit of code should go into the `stdx` crate instead. Transitive dependencies matter too: it is worth reading `Cargo.lock` for ones that make no sense. The stated reasons are low compile times, ecosystem pressure for faster compiles, and fewer things that can break.

**Clippy.** Clippy is used. A lint that is unwanted should be allowed in the workspace `Cargo.toml` `[workspace.lints.clippy]` section, not silenced ad hoc.

**Review culture.** PRs are generally not blocked on style. A reviewer may flag only some nits and follow up with a cleanup PR. Reviewers should prefer extending the style document to leaving one-off comments.

**Feature scope.** New features should start with an issue so the team can agree they are in scope before work begins. At the time of these docs, CONTRIBUTING.md announces a feature freeze on *new* IDE assists: PRs adding new `ide-assists` are likely to be closed.

**AI disclosure.** Contributors are asked to disclose AI tool use. Undisclosed use may be grounds for rejection.
