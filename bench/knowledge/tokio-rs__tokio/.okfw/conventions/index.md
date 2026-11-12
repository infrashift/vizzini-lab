# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Compatibility, versioning and MSRV](compatibility-versioning-and-msrv--01a1d174859a.md) - Tokio 1.x follows semantic versioning with LTS guarantees, keeps patch releases free of behaviour changes, and only raises its rolling six-month MSRV in minor releases.
* [Concurrency verification with loom, miri and fuzzing](concurrency-verification-with-loom-miri-and-fuzzing--01a1d174858c.md) - Tokio's concurrent and unsafe internals are checked with loom model tests, miri and cargo-fuzz harnesses, each run with specific flags.
* [Documentation tests and API docs](documentation-tests-and-api-docs--01a1d1748585.md) - Every public API should have at least one documentation test, written from the point of view of a user of the tokio facade crate.
* [Formatting, lints and commit conventions](formatting-lints-and-commit-conventions--01a1d17485a0.md) - Tokio code is formatted with rustfmt for edition 2021 (not cargo fmt), linted with the CI's pinned clippy version, and committed with crate-prefixed lowercase messages.
* [I/O driver readiness and waker design](i-o-driver-readiness-and-waker-design--01a1d1748592.md) - Tokio's I/O driver uses edge-triggered readiness, tracks known readiness per resource, removes waiters on drop and uses a tick to avoid lost wakeups.
* [Tests required with every code change](tests-required-with-every-code-change--01a1d174857e.md) - Code changes in Tokio must come with integration or documentation tests, and Tokio avoids unit tests as much as possible.

