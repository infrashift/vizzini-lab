---
id: "01a1d177-1e27-78b2-8c29-dc99ceb3dd0b"
title: "Required pytest idioms for pandas tests"
type: "Guideline"
tags:
  - "testing"
  - "pytest"
created: "2026-11-12T14:33:27-06:00"
timestamp: "2026-11-12T14:33:27-06:00"
description: "How pandas tests are expected to be written: functional pytest style, tm assertion helpers, strict warning and exception checks, and no real network access."
x:
  paths: ["pandas/tests/**/*.py", "pandas/conftest.py", "pandas/_testing/**/*.py"]
  source: ["doc/source/development/contributing_codebase.rst", "doc/source/development/contributing.rst", ".github/PULL_REQUEST_TEMPLATE.md"]
---

# Required pytest idioms for pandas tests

pandas "is serious about testing" and encourages test-driven development. Tests are one of the most common requests on pull requests, the PR template asks for tests when fixing a bug or adding a feature, and the guide says tests "should be the first part of any PR". Contributors are asked to strive for changed code being covered by a test.

## Style

- Existing tests are mostly class-based, but new tests should prefer a functional style: `def test_*` functions that take *only* fixtures or parameters as arguments.
- Use a bare `assert` for scalars and truth tests; use `tm.assert_series_equal(result, expected)` and `tm.assert_frame_equal(result, expected)` for Series and DataFrame results.
- Use `@pytest.mark.parametrize` for multiple cases, `@pytest.fixture` for shared setup, and `pytest.param` when one case needs a mark.
- Add the GitHub issue number as a comment in a new test (the example uses `# GH <issue_number>`).

## xfail and skip

- `pytest.mark.skip` is for cases never expected to pass; `pytest.mark.xfail` for known failures whose failure mode is not being captured.
- Do **not** use `pytest.xfail` (it stops the test immediately); use `pytest.skip` if that is the intent.
- `strict=False` on xfail is "highly undesirable" and only a last resort for flaky tests.
- Prefer the decorator or `pytest.param` so marks apply at collection time; for xfails that depend on fixtures, use `request.applymarker(...)`.
- Never xfail a test about invalid user arguments; check the exception with `pytest.raises` instead.

## Warnings and exceptions

- Check warnings with `tm.assert_produces_warning(WarningClass, match="...")`. Both the class and `match` are required; `match=None` is only for the rare case where the message genuinely cannot be asserted. Pass `False` to assert no warning.
- If a test emits a warning it is not testing, use `@pytest.mark.filterwarnings("ignore:msg:category")`.
- Check exceptions with `pytest.raises(SpecificError, match="...")`. Never use the bare `Exception` class.

## Files, network and markers

- Use the `temp_file` fixture for tests that write files.
- A unit test should not access a public data set over the internet. Mock it with the `httpserver` fixture from pytest-localserver and synthetic data, marking the test `network` and `single_cpu`.
- Markers defined in `PANDAS_MARKERS` in `pandas/conftest.py` include `slow`, `network`, `db`, `single_cpu`, `high_memory` (needs more than 5GB, skipped unless requested) and `arm_slow`.
