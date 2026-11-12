---
id: "01a1d177-1ee1-7820-876c-0a9b87d9aa57"
title: "Extension arrays, dtypes and accessors"
type: "Guideline"
tags:
  - "extension-api"
  - "arrays"
  - "architecture"
created: "2026-11-12T14:33:27-06:00"
timestamp: "2026-11-12T14:33:27-06:00"
description: "The contract for ExtensionDtype, ExtensionArray, custom accessors and subclasses, which pandas also uses for its own non-NumPy types."
x:
  paths: ["pandas/core/arrays/**/*.py", "pandas/core/dtypes/base.py", "pandas/core/dtypes/dtypes.py", "pandas/core/accessor.py", "pandas/api/extensions/__init__.py", "pandas/tests/extension/**/*.py"]
  source: ["doc/source/development/extending.rst", "doc/source/development/internals.rst"]
---

# Extension arrays, dtypes and accessors

pandas extends NumPy's type system through an interface of two classes, and uses it itself for types NumPy lacks (categorical, period, interval, timezone-aware datetime). The `ExtensionDtype`/`ExtensionArray` APIs follow the pandas deprecation policy, so changes to them are public-API changes.

## ExtensionDtype

Describes the data type, like `numpy.dtype`. Implementers must provide items such as the name and, importantly, the `type` property: the scalar class of the data. A dtype can be registered so it can be created from a string name (as `'category'` is for `CategoricalDtype`).

## ExtensionArray

- Limited to one dimension; linked to its dtype through the `dtype` attribute.
- No restrictions on construction or storage (it may be backed by zero, one or many NumPy arrays, or something else), but it must be convertible to a NumPy array, even if that is expensive.
- No operators by default. Either define them directly, or use `ExtensionScalarOpsMixin` with `_add_arithmetic_ops()`/`_add_comparison_ops()`; the mixin calls the scalar operator element by element and may be slower.
- Binary ops should not handle Series or Index: detect them and return `NotImplemented`. pandas unboxes the array from the Series, calls the op, and re-boxes the result.
- Implementing `__array_ufunc__` is recommended to avoid coercion to ndarray. It is required to defer to pandas by returning `NotImplemented` when a Series, DataFrame or Index is among the inputs.
- Arrow round-tripping uses `ExtensionArray.__arrow_array__` and `ExtensionDtype.__from_arrow__`.
- The shared interface test suite lives in `pandas/tests/extension/base`; implementations subclass its base test classes (for example `base.BaseConstructorsTests`) and provide the fixtures in `pandas/tests/extension/conftest.py`.

## Accessors and subclassing

- `register_dataframe_accessor`, `register_series_accessor` and `register_index_accessor` add namespaces. The docs highly recommend validating the data in the accessor's `__init__` (raising `AttributeError` on failure) and validating the dtype for Series accessors that apply only to some dtypes.
- Subclassing is discouraged in favor of `pipe`, composition, accessors or extension types. Subclasses that need to survive operations override `_constructor`, `_constructor_sliced` (DataFrame to Series) and `_constructor_expanddim` (Series to DataFrame).
- Custom `Index` subclasses are not supported; use the ExtensionArray interface.
