---
id: "01a1d174-8585-7360-a995-05eaf96eccc6"
title: "Documentation tests and API docs"
type: "Guideline"
tags:
  - "documentation"
  - "testing"
  - "rust"
  - "api"
created: "2026-11-12T14:30:36-06:00"
timestamp: "2026-11-12T14:30:36-06:00"
description: "Every public API should have at least one documentation test, written from the point of view of a user of the tokio facade crate."
x:
  paths: ["tokio/src/**", "tokio-util/src/**", "tokio-stream/src/**", "tokio-macros/src/**", "tokio-test/src/**"]
  source: ["CONTRIBUTING.md"]
---

# Documentation tests and API docs

`CONTRIBUTING.md` asks that "ideally, every API has at least one documentation test that demonstrates how to use the API." Documentation tests run with `cargo test --doc`, which "ensures that the example is correct and provides additional test coverage." A reviewer should check that new public items come with a working example.

**How to write them**

- Strike "a balance between being succinct for a reader to understand and actually testing the API."
- The full `tokio` crate is available in doc tests, which is how an example gets a runtime to run on.
- Doc tests appear both in the sub-crate's own docs **and** in the `tokio` facade docs via re-export. So "the example should be written from the point of view of a user that is using the `tokio` crate", using the API "via the facade and not by directly referencing the crate."
- Show the way users normally reach the item. The guide's example: a *type-level* example for a timeout type uses the extension-trait method users normally call, while a doc test for the type's `new` constructor calls `new` directly.
- Lines starting with `/// #` are hidden from the rendered docs and exist only to make the test run (for example, setup or a surrounding `main`).

**Building docs correctly**

Feature markers that show which feature a part of Tokio requires are missing from a normal doc build. Docs must be built with the `docsrs` cfg:

```
RUSTDOCFLAGS="--cfg docsrs" RUSTFLAGS="--cfg docsrs" cargo +nightly doc --all-features
```

Unstable APIs need `--cfg tokio_unstable` passed to *both* rustdoc and rustc. When a change adds feature-gated or unstable public API, a reviewer should consider whether its docs render with the right feature markers under this build.

**Helping others**

The guide also asks people who received help on a question to contribute back a documentation PR that helps others avoid the same problem, so documentation-only PRs are expected and welcome; even a one-character typo fix in API documentation is "greatly appreciated".
