---
id: "01a1d177-1e53-7990-8f85-55e41f9a4751"
title: "Code standards, type hints and optional dependencies"
type: "Guideline"
tags:
  - "style"
  - "typing"
  - "dependencies"
  - "ci"
created: "2026-11-12T14:33:27-06:00"
timestamp: "2026-11-12T14:33:27-06:00"
description: "pandas code must pass pre-commit checks, should carry PEP 484 type hints that follow project conventions, and must import optional libraries through import_optional_dependency."
x:
  paths: ["pandas/**/*.py", "pandas/_typing.py", "pandas/api/typing/**/*.py", "pandas/compat/_optional.py"]
  source: ["doc/source/development/contributing_codebase.rst", "doc/source/getting_started/install.rst", ".github/PULL_REQUEST_TEMPLATE.md"]
---

# Code standards, type hints and optional dependencies

## Linting is a merge requirement

The contributing guide says "good style is a requirement for submitting code to pandas". CI runs formatting and lint checks such as `ruff`, `isort` and `clang-format` through pre-commit hooks, and any warning fails CI. Slower hooks (mypy, pyright, stubtest) run in the `manual` stage but still run in CI. A PR is considered for merging only with an all-green build.

## Type hints

- PEP 484 hints are "strongly encouraged"; new development should contain them, and the PR template asks for annotations on new arguments, methods and functions.
- Type imports follow `from typing import ...`. Pre-commit may rewrite code to modern constructs (built-in `list` instead of `typing.List`).
- If a class variable shadows a builtin (`str = None`), annotate with an unambiguous alias (`str_type = str`).
- `typing.cast` is "strongly discouraged". Prefer refactoring so the checker can infer the type (for example `isinstance` instead of a helper like `is_number`); "every effort should be exhausted to avoid `cast`".
- Reuse aliases from `pandas._typing` (for example `Dtype`). That module is private; types meant for users belong in `pandas.api.typing.aliases`.
- pandas is not yet a `py.typed` library.

## Optional dependencies

The installation guide says pandas "has many optional dependencies that are only used for specific methods" and raises `ImportError` when a method's dependency is missing. The contributing guide requires that:

- Optional dependencies are imported with the private helper `pandas.compat._optional.import_optional_dependency`, which "ensures a consistent error message when the dependency is not met".
- The minimum version is set in `pandas.compat._optional.VERSIONS`, and the dependency is documented in the installation guide's optional-dependencies section (grouped by pip extra, with minimum versions).
- Every method using an optional dependency has a test asserting `ImportError` is raised when the dependency is missing, skipped when the library is present.
