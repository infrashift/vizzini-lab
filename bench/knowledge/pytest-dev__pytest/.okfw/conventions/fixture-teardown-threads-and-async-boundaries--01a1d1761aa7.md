---
id: "01a1d176-1aa7-7397-bd86-b12729febc19"
title: "Fixture Teardown, Threads and Async Boundaries"
type: "Guideline"
tags:
  - "fixtures"
  - "concurrency"
  - "async"
  - "resource-management"
created: "2026-11-12T14:32:20-06:00"
timestamp: "2026-11-12T14:32:20-06:00"
description: "pytest runs tests single-threaded with non-thread-safe primitives, expects fixtures to clean up through yield or finalizers with one state change each, and does not await async fixtures for sync tests."
x:
  paths: ["src/_pytest/fixtures.py", "src/_pytest/runner.py", "src/_pytest/raises.py", "src/_pytest/recwarn.py", "src/_pytest/threadexception.py", "src/_pytest/unraisableexception.py", "testing/**/*.py"]
  source: ["doc/en/explanation/flaky.rst", "doc/en/how-to/fixtures.rst", "doc/en/deprecations.rst"]
---

# Fixture Teardown, Threads and Async Boundaries

These rules describe how pytest's runtime is designed to behave. They matter when reviewing changes to the fixture machinery and the runner, and when reviewing pytest's own tests and fixtures.

## Threads

- "pytest is single-threaded, executing its tests always in the same thread, sequentially, never spawning any threads itself." Parallel plugins such as `pytest-xdist` usually spawn *processes*, not threads.
- Primitives provided by pytest, such as `pytest.warns` and `pytest.raises`, "are not thread-safe" and should not be used from multiple threads.
- Tests and fixtures that start threads must "eventually wait on any spawned threads", for example at the end of the test or in fixture teardown. Hidden use of pytest's global state from threads is named as a source of flaky results.

## Teardown and resources

- `yield` fixtures are the recommended teardown mechanism; `request.addfinalizer` is the alternative, and yield fixtures use `addfinalizer` internally. Teardown runs in reverse setup order.
- If setup code before the `yield` raises, the teardown after it does not run. The "safest and simplest fixture structure" limits each fixture to **one state-changing action** bundled with its own teardown, so each successful action is always undone.
- Calling `request.getfixturevalue()` during teardown for a fixture that was not already requested is deprecated and will become an error, because teardown runs while scopes are already unwinding. Fixtures needed in teardown must be requested before the fixture yields.
- Applying a mark such as `usefixtures` to a fixture function never had any effect; pytest now warns about it.

## Async

- pytest itself does not run async tests; it errors on an async test function and points users to a plugin.
- A synchronous test that depends on an async fixture is deprecated and then removed: the coroutine is never awaited, and value caching can make it appear to work when an async test requested it first. Async plugins handle coroutines in `pytest_fixture_setup` before pytest sees them.

## Iterables in parametrize

- Non-`Collection` iterables (generators, iterators) passed as `argvalues` to `parametrize` are deprecated because they are exhausted after the first pass, silently skipping tests when collection runs more than once.

## Review checks

Threads started without being joined, pytest primitives used across threads, multi-step fixtures whose early failure would leak state, fixtures requested lazily during teardown, and generators passed to `parametrize`.
