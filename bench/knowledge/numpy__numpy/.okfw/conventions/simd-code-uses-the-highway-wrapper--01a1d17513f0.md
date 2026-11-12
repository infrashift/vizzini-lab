---
id: "01a1d175-13f0-7abd-a19d-43fd058c9dba"
title: "SIMD code uses the Highway wrapper"
type: "Guideline"
tags:
  - "simd"
  - "performance"
  - "cpp"
created: "2026-11-12T14:31:13-06:00"
timestamp: "2026-11-12T14:31:13-06:00"
description: "New SIMD kernels must use NumPy's C++ wrapper over Google Highway (np::simd, NPY_HWY macros), not the deprecated universal-intrinsics C interface, and must keep a scalar fallback."
x:
  paths: ["numpy/_core/src/common/simd/**", "numpy/_core/src/umath/**", "numpy/_core/src/multiarray/**"]
  source: ["numpy/_core/src/common/simd/README.md"]
---

# SIMD code uses the Highway wrapper

The README in `numpy/_core/src/common/simd/` defines how vectorised code is written.

## Which interface to use

- The directory still contains the old universal-intrinsics C interface (`simd.h`, `NPY_SIMD` macros). It "is no longer supported" and is "deprecated and should not be used for new code". It is kept for compatibility and will eventually be removed.
- "All new SIMD code should use the Highway wrapper." Include `simd/simd.hpp` and use `np::simd` for maximum-width operations or `np::simd128` for fixed 128-bit operations. The wrapper drops Highway's class tags and deduces lane types from the arguments.
- The wrapper exposes a curated set of operations: creation (`Zero`, `Set`, `Undefined`), unaligned memory access (`LoadU`, `StoreU`), `Lanes`, conversions, comparisons, arithmetic (`Add` ... `Sqrt`) and bitwise logic. Other Highway operations are reachable through the `hn` alias.

## Feature checks and fallbacks

- Guard SIMD paths with `#if NPY_HWY` and provide scalar fallback code in the `#else` branch.
- Check type and feature support with NumPy's constants (`NPY_HWY_F16`, `NPY_HWY_F64`, `NPY_HWY_FMA`) or the compile-time traits `kSupportLane<T>` and `kMaxLanes<T>`, not raw Highway constants such as `HWY_HAVE_FLOAT16`. The NumPy constants also account for NumPy's build configuration, so SIMD is not used when optimisation is disabled (`NPY_DISABLE_OPTIMIZATION`, meson option `disable-optimization`) or when the Highway target is scalar or EMU128. Without them, "code might incorrectly try to use SIMD paths in scalar mode".
- NumPy deliberately avoids Highway's scalar operations. NumPy already has scalar kernels, compilers optimise standard-library code better, and direct scalar implementations give more predictable strict IEEE 754 behaviour than EMU128.

## Extending the wrapper

To expose another Highway operation, add a `using hn::FunctionName;` in `simd.inc.hpp` if it needs no tag. Otherwise add a templated `HWY_API` wrapper that passes `_Tag<TLane>()`. Then add documentation and SFINAE constraints as needed.

The docs give no specific benchmark requirement for SIMD changes. The dev index links a benchmarking guide but states no rule.
