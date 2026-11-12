# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Backward compatibility and deprecation policy](backward-compatibility-and-deprecation-policy--01a1d1770a8f.md) - Rules for changing public pandas behavior: deprecate first, warn with the right class, and only break in major releases.
* [Code standards, type hints and optional dependencies](code-standards-type-hints-and-optional-dependencies--01a1d1771e53.md) - pandas code must pass pre-commit checks, should carry PEP 484 type hints that follow project conventions, and must import optional libraries through import_optional_dependency.
* [Copy-on-Write and in-place semantics](copy-on-write-and-in-place-semantics--01a1d1771e7e.md) - Any derived DataFrame or Series must behave as a copy; Block reference tracking decides when a write must copy, and inplace is kept only for methods that can really modify values.
* [Docstring conventions](docstring-conventions--01a1d1771f11.md) - pandas docstrings follow the numpydoc convention plus pandas-specific rules, and their examples are doctests that must pass.
* [Extension arrays, dtypes and accessors](extension-arrays-dtypes-and-accessors--01a1d1771ee1.md) - The contract for ExtensionDtype, ExtensionArray, custom accessors and subclasses, which pandas also uses for its own non-NumPy types.
* [Pull request expectations](pull-request-expectations--01a1d1771f40.md) - What a pandas pull request is expected to carry: a linked issue, tests, a release note, benchmark evidence where performance matters, and disclosure of any AI tool use.
* [Required pytest idioms for pandas tests](required-pytest-idioms-for-pandas-tests--01a1d1771e27.md) - How pandas tests are expected to be written: functional pytest style, tm assertion helpers, strict warning and exception checks, and no real network access.
* [Setitem must not upcast, and other data-model invariants](setitem-must-not-upcast-and-other-data-model-invariants--01a1d1771eaa.md) - Setitem-like operations must keep a Series' dtype and raise instead of upcasting, alongside the Index, MultiIndex and _values conventions described in the internals docs.
* [Where tests go and how they import pandas](where-tests-go-and-how-they-import-pandas--01a1d1771dfa.md) - Rules of thumb for placing a new test in pandas/tests and the import style test files must follow.

