# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Backward Compatibility and Deprecation Policy](backward-compatibility-and-deprecation-policy--01a1d17619c0.md) - pytest removes public behaviour only through a warning-backed deprecation period ending in a major release, and true breakage needs prior announcement and documentation in doc/en/deprecations.rst.
* [Changelog Fragments and AUTHORS Accompany Changes](changelog-fragments-and-authors-accompany-changes--01a1d17485a0.md) - Every non-trivial change to pytest must ship a changelog fragment named <issueid>.<type>.rst in changelog/ and, for new contributors, an AUTHORS entry.
* [Code Style, Docstrings and Typing](code-style-docstrings-and-typing--01a1d1761a7f.md) - pytest code follows PEP 8 naming enforced by pre-commit, uses Sphinx-format docstrings that feed the API reference, and relies on type annotations rather than types in docstrings.
* [Fixture Teardown, Threads and Async Boundaries](fixture-teardown-threads-and-async-boundaries--01a1d1761aa7.md) - pytest runs tests single-threaded with non-thread-safe primitives, expects fixtures to clean up through yield or finalizers with one state change each, and does not await async fixtures for sync tests.
* [Hook Specification and Implementation Rules](hook-specification-and-implementation-rules--01a1d1761a20.md) - pytest is built from pluggy hooks with pytest_-prefixed names, validated argument names, keyword-only calls and the hookimpl decorators, and most hooks must not raise.
* [Plugin Loading, conftest Scope and Assertion Rewriting](plugin-loading-conftest-scope-and-assertion-rewriting--01a1d1761ad3.md) - pytest loads builtin, entry-point and conftest plugins in a fixed startup order, scopes conftest hooks per directory, and rewrites asserts only in test modules and registered plugin modules.
* [Public pytest API Versus Private _pytest Internals](public-pytest-api-versus-private-pytest-internals--01a1d17619f0.md) - Users and plugins are meant to reach pytest through the pytest namespace and documented constructors such as Node.from_parent, while _pytest internals and their constructors are private.
* [Testing Changes with Pytester](testing-changes-with-pytester--01a1d1761a52.md) - Changes to pytest need new or updated tests, usually black-box tests with the pytester fixture placed in the testing/ module that matches the changed source module.

