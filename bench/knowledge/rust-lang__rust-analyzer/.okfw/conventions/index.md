# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Avoiding Premature Pessimization](avoiding-premature-pessimization--01a1d174b4e9.md) - The runtime and compile-time performance rules rust-analyzer's style guide asks reviewers to enforce.
* [Code Style and Naming](code-style-and-naming--01a1d174b532.md) - rust-analyzer's stated conventions for imports, item order, naming, matching, and comments that reviewers check beyond rustfmt.
* [Crate Layering and API Boundaries](crate-layering-and-api-boundaries--01a1d174b417.md) - Which rust-analyzer crates are API boundaries and what each layer is forbidden to know about.
* [Error Handling and Panic Resilience](error-handling-and-panic-resilience--01a1d174b45b.md) - rust-analyzer treats broken code as data rather than an error, keeps core analysis infallible, and recovers from impossible conditions instead of asserting.
* [Function and Type Design Rules](function-and-type-design-rules--01a1d174b50e.md) - rust-analyzer's style rules for shaping functions, structs and parameters: preconditions in types, getters without setters, Config structs, and general borrowed types.
* [Incrementality, Cancellation and Server State](incrementality-cancellation-and-server-state--01a1d174b47f.md) - The salsa-based invariants that changes to hir, ide and the language server must preserve: incremental invalidation, unwinding-based cancellation, a stateless server, and no IO in the analysis core.
* [Scope of Changes and Dependencies](scope-of-changes-and-dependencies--01a1d174b43b.md) - How rust-analyzer classifies a change by its effect on pub items and dependencies, and how conservative it is about new crates.io dependencies.
* [Stability, Serialization and LSP Extensions](stability-serialization-and-lsp-extensions--01a1d174b4c6.md) - Where rust-analyzer does and does not promise stability, why internal types must not be serializable, and how LSP protocol extensions are kept in sync with their documentation.
* [Testing Conventions](testing-conventions--01a1d174b4a4.md) - rust-analyzer's data-driven snapshot tests: what a new or changed feature's tests should look like and which test patterns are forbidden.

