# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Backwards compatibility and deprecation policy (NEP 23)](backwards-compatibility-and-deprecation-policy-nep-23--01a1d17513c6.md) - NumPy treats breaking changes as harmful by default and requires a formal deprecation path, with specific warning and documentation rules, before removing or changing public behaviour.
* [C and C++ coding style (NEP 45)](c-and-c-coding-style-nep-45--01a1d17513d5.md) - NumPy's C code follows PEP 7 with extra strictures: C99 without GCC extensions, 4-space indents, 80-column lines, braces on every branch, and fixed naming prefixes.
* [C-API and ABI compatibility rules](c-api-and-abi-compatibility-rules--01a1d17513cc.md) - Additions to NumPy's public C-API must stay ABI compatible with older versions, using version guards on struct fields and MinVersion annotations on API-table entries.
* [Python style, docstrings and change hygiene](python-style-docstrings-and-change-hygiene--01a1d17513e9.md) - Python code follows PEP 8 checked by ruff, uses NumPy dtype objects and `import numpy as np`, is documented with numpydoc docstrings, and is submitted as focused, prefixed, reviewed changes with release notes.
* [SIMD code uses the Highway wrapper](simd-code-uses-the-highway-wrapper--01a1d17513f0.md) - New SIMD kernels must use NumPy's C++ wrapper over Google Highway (np::simd, NPY_HWY macros), not the deprecated universal-intrinsics C interface, and must keep a scalar fallback.
* [Testing expectations](testing-expectations--01a1d17513db.md) - Every code change needs tests that fail before and pass after, written with pytest in each subpackage's tests/ directory, using NumPy's assertion helpers, deterministic random data and precise match patterns.
* [Thread safety and thread-safe tests](thread-safety-and-thread-safe-tests--01a1d17513e2.md) - NumPy releases the GIL in many operations and supports free-threaded Python, so shared mutable state, global test setup and object-dtype arrays need care, and tests must pass under pytest-run-parallel.
* [numpy.random stream-compatibility policy](numpy-random-stream-compatibility-policy--01a1d17513f6.md) - numpy.random has stricter compatibility rules than the rest of NumPy: RandomState is frozen, BitGenerators keep strong stream guarantees, and Generator stream changes are features that need caution.

