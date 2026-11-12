---
id: "01a1d175-13db-7679-8b6d-08d9c6db705f"
title: "Testing expectations"
type: "Guideline"
tags:
  - "testing"
  - "pytest"
  - "review"
created: "2026-11-12T14:31:13-06:00"
timestamp: "2026-11-12T14:31:13-06:00"
description: "Every code change needs tests that fail before and pass after, written with pytest in each subpackage's tests/ directory, using NumPy's assertion helpers, deterministic random data and precise match patterns."
x:
  paths: ["numpy/**/tests/**", "numpy/testing/**"]
  source: ["doc/TESTS.rst", "doc/source/dev/index.rst", "doc/source/dev/reviewer_guidelines.rst"]
---

# Testing expectations

## What the dev guide requires

- "All code should have tests." PRs that modify code should add new tests or change existing tests so that they fail before the PR and pass afterwards. The standard review reply asks for "a non-regression test that would fail at main but pass in this PR".
- Ideally a module's tests reach 100% statement coverage.
- Whenever a new bug is found, add a test for that case so it cannot return unnoticed.

## Reviewer checklist items about behaviour

The reviewer guidelines ask whether intended behaviour is clear under all conditions, specifically:

- What happens with unexpected inputs such as empty arrays or `nan`/`inf` values?
- Are axis or shape arguments tested as both `int` and `tuple`?
- Are unusual dtypes tested if the function supports them?

## How tests are written

- All NumPy tests use pytest (the old nose framework is kept only for downstream users).
- Tests live in a `tests/` subdirectory of the subpackage, e.g. `numpy/xxx/tests/test_yyy.py` for `numpy/xxx/yyy.py`. Test functions are named `test*` and classes `Test*`.
- Use `numpy.testing.assert_equal`, `assert_allclose` (with explicit tolerances) and `assert_array_less` for array comparisons. These compare values only; consider `strict=True` to also check dtype and shape.
- Prefer a plain `assert` over the legacy `numpy.testing.assert_`, and `pytest.raises`/`pytest.warns` over `assert_raises`/`assert_warns`. Always pass `match=` to target the intended error or warning precisely.
- Test functions should not have docstrings, because they make tests hard to identify in verbose output. Use `#` comments instead.
- Mark slow tests with `@pytest.mark.slow`. Use `pytest.mark.skipif`/`xfail` with a `reason`.
- Use `pytest.mark.parametrize` for parameter sweeps. Use fixtures sparingly (`tmp_path` for temporary directories).
- Random data must be deterministic: seed a local `numpy.random.RandomState(some_number)` rather than global state, or use Hypothesis. A test that fails occasionally without code changes "is not helpful".
- C-API behaviour is tested through extension modules that use only the public C-API (see the C-API concept).

Doctests in docstrings are checked separately (`spin check-docs`), not by `spin test`. A change to a function's API may require rerunning them. The thread-safety rules for tests are covered in the thread-safety concept.
