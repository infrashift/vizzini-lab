---
id: "01a1d177-1dfa-7910-8fe5-612e551dad3c"
title: "Where tests go and how they import pandas"
type: "Guideline"
tags:
  - "testing"
  - "layout"
created: "2026-11-12T14:33:27-06:00"
timestamp: "2026-11-12T14:33:27-06:00"
description: "Rules of thumb for placing a new test in pandas/tests and the import style test files must follow."
x:
  paths: ["pandas/tests/**/*.py"]
  source: ["doc/source/development/contributing_codebase.rst"]
---

# Where tests go and how they import pandas

The contributing guide states that all tests go into the `tests` subdirectory of the specific package, and that ideally there is "one, and only one, obvious place for a test to reside". Reviewers may ask for a test to be moved. The guide's rules of thumb:

- **Only `pd._libs.tslibs`** code: `tests/tslibs`, `tests/scalar`, or `tests/tseries/offsets`. No file in `tests/tslibs` should import from pandas modules outside `pd._libs.tslibs`.
- **Only `pd._libs`** code: `tests/libs` or `tests/groupby/test_libgroupby`.
- **Arithmetic or comparison methods**: `tests/arithmetic` (for tests shared across DataFrame/Series/Index/ExtensionArray through the `box_with_array` fixture), or `tests/frame/test_arithmetic`, `tests/series/test_arithmetic`.
- **Reductions** (min, max, sum, prod, ...): `tests/reductions`, `tests/frame/test_reductions`, `tests/series/test_reductions`, `tests/test_nanops`.
- **Indexing**:
  - Index methods such as `get_loc`/`get_indexer`: `tests/indexes/test_indexing` or `tests/indexes/<fooindex>/test_indexing`, inside a method-specific class like `TestGetLoc`; usually no Series or DataFrame needed.
  - Other Series/DataFrame indexing methods (`xs`, `where`, `take`, `mask`, `insert`): `tests/frame/indexing/test_<method>` or `tests/series/indexing/test_<method>`.
  - `loc`, `iloc`, `at`, `iat`: `tests/indexing/test_loc` and siblings.
  - `__getitem__`/`__setitem__`: `tests/series/test_getitem`, `test_setitem`, and the frame equivalents.
  - When a test exercises several similar methods, place it by the *underlying* method being tested, or, for a bug fix, by the location of the actual bug.
- **Plotting** methods: `tests/plotting`. **IO** methods: `tests/io` (includes `to_string`; `__repr__` goes in `tests/frame/test_repr` / `tests/series/test_repr`).
- **Other DataFrame/Series methods**: `tests/series/methods/test_<method>` or `tests/frame/methods/test_<method>`; a test shared via the `frame_or_series` fixture goes in the `tests/frame` file by convention.
- **Index methods** not depending on Series/DataFrame: `tests/indexes`.
- **pandas-provided ExtensionArrays** (Categorical, DatetimeArray, StringArray, ...): `tests/arrays`. Tests for **all** ExtensionArray subclasses (the EA interface): `tests/extension`.

## Imports in tests

Objects in the top-level namespace are reached through `pd` (`import pandas as pd; pd.Series(...)`) rather than imported directly. Everything else is imported from the module that defines it, for example `import pandas._testing as tm` or `from pandas.core.dtypes.common import is_integer_dtype`. A `test-imports` pre-commit hook checks that test files do not import from the `pandas` namespace directly.
