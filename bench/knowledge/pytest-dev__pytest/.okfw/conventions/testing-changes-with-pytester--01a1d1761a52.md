---
id: "01a1d176-1a52-7ec4-ac00-b7d8edd8ef4a"
title: "Testing Changes with Pytester"
type: "Guideline"
tags:
  - "testing"
  - "pytester"
  - "tox"
  - "review-checklist"
created: "2026-11-12T14:32:20-06:00"
timestamp: "2026-11-12T14:32:20-06:00"
description: "Changes to pytest need new or updated tests, usually black-box tests with the pytester fixture placed in the testing/ module that matches the changed source module."
x:
  paths: ["testing/**/*.py", "src/_pytest/pytester.py", "src/_pytest/pytester_assertions.py"]
  source: ["CONTRIBUTING.rst", ".github/PULL_REQUEST_TEMPLATE.md", "doc/en/how-to/writing_plugins.rst", "testing/example_scripts/README.rst", "testing/plugins_integration/README.rst"]
---

# Testing Changes with Pytester

The pull request checklist asks contributors to "include new tests or update existing tests when applicable". Even a bug report is more useful with "a demonstration test that currently fails but should pass (xfail)".

## How pytest tests itself

- Tests for pytest and its plugins are "often done using the pytester fixture ... as a 'black-box' test": write files with `pytester.makepyfile` / `pytester.makeconftest`, run them with `pytester.runpytest()`, and check the result.
- Check outcomes with `result.assert_outcomes(passed=..., failed=...)`, or check terminal output with glob-like patterns using `result.stdout.fnmatch_lines([...])`.
- `pytester` is a plugin disabled by default; enable it with `pytest_plugins = ["pytester"]` or `-p pytester`. `pytester.copy_example` copies files from the directory set by `pytester_example_dir`.

## Where a test goes

- Put a new test in the existing `testing/` file that matches the source module. The example given: a regression test for `--lf` belongs in `test_cacheprovider.py`, because that option is implemented in `cacheprovider.py`.
- `testing/example_scripts/` holds example test suites that demonstrate behaviours; they "are not direct tests" but are used by other tests.
- `testing/plugins_integration/` holds smoke tests that check popular plugins still work with the current pytest. A plugin is added there only if it is widely used and has no large external dependencies such as external services, together with a quick smoke test of a small part of the plugin.

## Running the suite

- Tests run through `tox`; `tox -e linting,py313` (or `linting,py`) is "usually enough to cover most cases locally" and also runs the style checks.
- Alternatively, use an editable install with the `dev` extra and run `pytest` directly.
- Fetch the upstream git tags before testing locally; the contributing guide says you need them to test.

## Review checks

- A behaviour change or bug fix without a new or updated test.
- A test placed in a `testing/` file unrelated to the module it exercises.
- New tests that do not follow the pytester pattern used across the suite (`makepyfile` + `runpytest` + `assert_outcomes` or `fnmatch_lines`) when they check end-to-end behaviour.
- New entries in `testing/plugins_integration/` for plugins that are not widely used or that need external services.
