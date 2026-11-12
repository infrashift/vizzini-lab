---
id: "01a1d175-13e2-787c-b504-656f54545d00"
title: "Thread safety and thread-safe tests"
type: "Guideline"
tags:
  - "concurrency"
  - "thread-safety"
  - "free-threading"
  - "testing"
created: "2026-11-12T14:31:13-06:00"
timestamp: "2026-11-12T14:31:13-06:00"
description: "NumPy releases the GIL in many operations and supports free-threaded Python, so shared mutable state, global test setup and object-dtype arrays need care, and tests must pass under pytest-run-parallel."
x:
  paths: ["numpy/**/tests/**", "numpy/_core/src/**", "numpy/_core/*.py"]
  source: ["doc/source/reference/thread_safety.rst", "doc/TESTS.rst"]
---

# Thread safety and thread-safe tests

## What the docs say about NumPy's threading model

- Many NumPy operations release the GIL, so threads that spend most of their time in low-level code run in parallel.
- Sharing arrays between threads is possible, but mutating a shared array while another thread reads it produces racy results. Some cases, such as resizing an array while another thread runs a ufunc on it, can crash the interpreter. `ndarray` has no internal locking.
- Operations on `dtype=np.object_` arrays do not release the GIL. Under free-threaded Python (experimental support since NumPy 2.1 with CPython 3.13), object arrays are not protected by a GIL, which allows data races on Python objects that cannot happen otherwise.
- `numpy.errstate` and the text-formatting options are context-local: each thread or asyncio task has its own copy, and leaving the context manager restores the previous value.
- C-extension authors are pointed to the multithreading notes in the C-API array documentation.

## Writing tests that survive parallel runs

CI runs the suite under `pytest-run-parallel` (`spin test -p auto`), so new tests should be checked for failures in that mode. TESTS.rst gives these rules:

- Prefer explicit setup/teardown helpers that each test calls itself. xunit-style setup methods and other pytest setup fixtures are "generally not thread-safe".
- Use a local seeded RNG rather than global random state.
- If `pytest.mark.parametrize` values cause thread-safety issues, `copy()` them inside the test.
- Mark inherently unsafe tests with `@pytest.mark.thread_unsafe(reason=...)` so they run on a single thread. Typical candidates are tests that use `sys.stdout`/`sys.stderr`, mutate global data (docstrings, modules, garbage collector, etc.) or need a lot of memory.
- `monkeypatch` and `capsys` are thread-unsafe fixtures. pytest-run-parallel marks tests that use them automatically. `tmp_path` has been patched to be thread-safe.

Ideally, parallel test runs use a free-threaded Python 3.14 or newer. Otherwise set `PYTHON_CONTEXT_AWARE_WARNINGS=1` and `PYTHON_THREAD_INHERIT_CONTEXT=1`.
