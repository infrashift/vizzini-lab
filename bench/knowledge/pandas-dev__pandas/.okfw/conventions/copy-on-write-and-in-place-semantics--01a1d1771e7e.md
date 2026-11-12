---
id: "01a1d177-1e7e-7d1d-9ad7-fef62105c250"
title: "Copy-on-Write and in-place semantics"
type: "Guideline"
tags:
  - "internals"
  - "copy-on-write"
  - "api"
created: "2026-11-12T14:33:27-06:00"
timestamp: "2026-11-12T14:33:27-06:00"
description: "Any derived DataFrame or Series must behave as a copy; Block reference tracking decides when a write must copy, and inplace is kept only for methods that can really modify values."
x:
  paths: ["pandas/core/internals/**/*.py", "pandas/core/generic.py", "pandas/core/frame.py", "pandas/core/series.py", "pandas/core/indexing.py"]
  source: ["doc/source/development/copy_on_write.rst", "web/pandas/pdeps/0007-copy-on-write.md", "web/pandas/pdeps/0008-inplace-methods-in-pandas.md"]
---

# Copy-on-Write and in-place semantics

## The user-facing rule (PDEP-7)

Copy-on-Write (CoW) means "any DataFrame or Series derived from another in any way always behaves as a copy". The result of any indexing operation, including taking a column as a Series, and of any method returning a new object, must never modify the original when it is modified, and modifying the original must not change it. Under the hood pandas uses views as much as possible and copies lazily, so method chains do not copy data at every step. The only way to modify an object is to modify that object directly. As a consequence, chained assignment such as `df["B"][mask] = 10` can never work; such cases raise a `ChainedAssignmentError` warning.

## The implementation rule (developer docs)

- Reference tracking lives at the Block level. A `BlockValuesRefs` object, held through weak references, tracks every block whose values share memory. Every pair of blocks sharing memory should point to the same `BlockValuesRefs`.
- When a DataFrame or Series shares data with another object, each must have its own BlockManager and Block objects. One Block instance held by a DataFrame/Series should be used by only that one object. To reuse a Block for another object, create a shallow copy with `block.copy(deep=False)`, which keeps the same values and sets up the references correctly.
- Before writing into values, ask the reference tracker whether another live block shares the data, and copy first if one does.

A reviewer should therefore be wary of code that hands the same Block instance to two objects, or that writes into shared values without going through this check.

## `inplace` and `copy` keywords (PDEP-8, accepted)

- `inplace` is kept only for methods that can update the underlying values in place, such as `where`, `fillna`, `replace`, `mask`, `interpolate`, `ffill`, `bfill` and `clip`.
- It is to be removed (through the normal deprecation process) from methods that can never work in place or that only rebind the object, such as `rename`, `set_index`, `reset_index`, `dropna`, `sort_values` and `query`. The PDEP also calls the `copy` keyword redundant under CoW.
- For methods that keep `inplace=True`, pandas tries to operate in place but silently copies when needed under CoW, so in-place is not guaranteed, and the method returns `self` instead of `None`.
