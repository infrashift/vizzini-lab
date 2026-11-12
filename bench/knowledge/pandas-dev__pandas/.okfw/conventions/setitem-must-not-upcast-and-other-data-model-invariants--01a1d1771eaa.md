---
id: "01a1d177-1eaa-72d9-aadf-96a6ccaa3e1a"
title: "Setitem must not upcast, and other data-model invariants"
type: "Guideline"
tags:
  - "internals"
  - "dtypes"
  - "indexing"
created: "2026-11-12T14:33:27-06:00"
timestamp: "2026-11-12T14:33:27-06:00"
description: "Setitem-like operations must keep a Series' dtype and raise instead of upcasting, alongside the Index, MultiIndex and _values conventions described in the internals docs."
x:
  paths: ["pandas/core/internals/blocks.py", "pandas/core/indexing.py", "pandas/core/indexes/**/*.py", "pandas/core/series.py", "pandas/core/frame.py"]
  source: ["web/pandas/pdeps/0006-ban-upcasting.md", "doc/source/development/internals.rst"]
---

# Setitem must not upcast, and other data-model invariants

## No upcasting in setitem-like operations (PDEP-6, implemented)

- If a Series (or DataFrame column) has a given dtype, a setitem-like operation should not change that dtype. Where such an operation used to upcast, it now raises, for example `ValueError: Invalid value 'potage' for dtype int64`.
- In scope: `ser[indexer] = v`, `ser.loc[...] = v`, `ser.iloc[...] = v`, `df.loc[indexer, col] = v`, `df.iloc[indexer, i] = v`, and value-setting methods such as `fillna` and `where`, with or without `inplace`. The PDEP names the Block-level methods involved: `Block.setitem`, `Block.where`, `Block.putmask` and their `EABackedBlock` equivalents.
- For floats set into an integer column, the chosen rule is: accept "round" floats (setting `3.0` keeps `int64`) and raise for anything else (setting `1.5`). Values that would need a wider integer type (for example `1_000_000.0` into `int8`) also raise. This matches the existing nullable-dtype behavior.
- Not affected: operations that create new objects (`diff`, `concat`, reductions), setting a value of the same dtype, replacing a whole column (`df["a"] = ...`), and enlargement (setting a new label past the end), which the PDEP leaves out of scope.

A change that reintroduces silent coercion to a common dtype in these paths contradicts this policy.

## Index and values conventions (internals.rst)

- `Index` holds hashable (likely immutable) labels that need not be unique, and builds a label-to-location dict in Cython for O(1) lookups. `DatetimeIndex`, `TimedeltaIndex` and `PeriodIndex` are backed by the matching ExtensionArray and box elements as `Timestamp`, `Timedelta` and `Period`.
- Custom `Index` subclasses are not supported; custom behavior should go through the `ExtensionArray` interface instead.
- A `MultiIndex` is made of levels, integer codes and names. Sortedness is determined **solely** by the codes, not by whether the levels are sorted. `from_tuples` and `from_arrays` guarantee consistency; code that computes levels and codes itself must be careful.
- For 1-D containers (Index classes and Series), `cls._values` is the "best possible" array: an `ndarray` or an `ExtensionArray` (for example a `Categorical` for category data).
