# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [API Stability and Backwards Compatibility](api-stability-and-backwards-compatibility--01a1d1759f26.md) - Django's promise that documented public APIs stay stable, what counts as internal, and the documentation and release notes a behavior change must include.
* [Architecture and Design Philosophies](architecture-and-design-philosophies--01a1d175a00a.md) - The design principles Django uses to judge changes: loose coupling between layers, explicitness, DRY, SQL efficiency, a minimal cache hot path, and benchmarked optimizations.
* [Async Safety and Sync/Async Boundaries](async-safety-and-sync-async-boundaries--01a1d1759f94.md) - Rules for code that crosses Django's sync/async boundary: async-unsafe parts, sync_to_async thread sensitivity, database connections, and dual-mode views and middleware.
* [Deprecation Procedure](deprecation-procedure--01a1d1759f5a.md) - How Django code deprecates a feature: RemovedInDjangoXXWarning over two feature releases, keeping Django itself warning-free, marking the shim code, and testing the warning.
* [Imports and Import-Time Settings Access](imports-and-import-time-settings-access--01a1d1758eb0.md) - How Django modules order and write imports, and why they must not read django.conf.settings when the module is imported.
* [Python Coding Style](python-coding-style--01a1d1758c27.md) - Django's stated Python style rules: black formatting, PEP 8 with an 88-character limit, readable string interpolation, and naming conventions.
* [Security Rules for Framework Code](security-rules-for-framework-code--01a1d1759fcd.md) - Security rules from Django's docs that apply when reviewing framework code: parameterized SQL, careful marking of strings as safe, CSRF exemptions, input size assumptions, and severity levels.
* [Template, View and Model Code Style](template-view-and-model-code-style--01a1d1758edf.md) - Django's style rules for template markup, view function signatures, and the layout of model classes.
* [Test Expectations for Changes](test-expectations-for-changes--01a1d175929e.md) - What Django expects of tests in a change: a failing-first regression test for bugs, full coverage of new code, precise assertions, and isolated model definitions.

