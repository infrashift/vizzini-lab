---
id: "01a1d174-859a-709b-b0ff-28e9f14cd9b0"
title: "Compatibility, versioning and MSRV"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "semver"
  - "msrv"
created: "2026-11-12T14:30:36-06:00"
timestamp: "2026-11-12T14:30:36-06:00"
description: "Tokio 1.x follows semantic versioning with LTS guarantees, keeps patch releases free of behaviour changes, and only raises its rolling six-month MSRV in minor releases."
x:
  paths: ["tokio/src/**", "tokio-util/src/**", "tokio-stream/src/**", "tokio-macros/src/**", "tokio-test/src/**", "tokio/Cargo.toml", "tokio-util/Cargo.toml", "tokio-stream/Cargo.toml", "tokio-macros/Cargo.toml", "tokio-test/Cargo.toml"]
  source: ["CONTRIBUTING.md", "README.md"]
---

# Compatibility, versioning and MSRV

Tokio's stability promises shape what changes are acceptable and how they must be labelled.

**Stability guarantees**

Tokio 1.x comes with LTS guarantees: at least 5 years of maintenance and at least 3 years before a hypothetical 2.0, "to provide stability to the ecosystem." Breaking public API changes are therefore not acceptable in normal changes. When preparing a release, maintainers compare HEAD with the last release tag, and if there are breaking API changes, "determine if those changes can be made without breaking existing APIs" and resolve them that way if possible.

**What goes in which release** (Semantic Versioning 2.0):

- Patch releases "should only contain bug fixes or documentation changes" and "should not substantially change runtime behavior."
- Minor releases may contain new functionality, MSRV increases, minor dependency updates, deprecations and larger internal implementation changes.

Whenever a bug warrants a patch release, the fix is backported and released for each designated LTS minor version (`README.md`).

**Minimum Supported Rust Version**

- Tokio keeps a rolling MSRV policy of **at least** six months: "When increasing the MSRV, the new Rust version must have been released at least six months ago."
- The MSRV "is not increased automatically, and only as part of a minor release."
- The project tries to avoid dependencies transitively raising the MSRV, though it does not guarantee it.
- A reviewer should flag code that uses language or standard library features newer than the stated MSRV, and any dependency change that would raise it.
- The MSRV is recorded in several places that must be updated together. Comments in the docs list them: the CI workflow, `CONTRIBUTING.md`, `README.md`, `tokio/README.md` and the `Cargo.toml` of `tokio`, `tokio-util`, `tokio-test` and `tokio-stream`.

**Labelling changes**

The review guide asks whether the commit message is readable and correct and, "if it contains a breaking change", whether that is clear enough. Deprecation is the tool for retiring APIs; the commit message guide's own example is "timer: introduce `Timeout` and deprecate `Deadline`".
