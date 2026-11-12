---
id: "01a1d175-13f6-7dd2-a6b7-a855e52ed756"
title: "numpy.random stream-compatibility policy"
type: "Guideline"
tags:
  - "random"
  - "backward-compatibility"
  - "api"
created: "2026-11-12T14:31:13-06:00"
timestamp: "2026-11-12T14:31:13-06:00"
description: "numpy.random has stricter compatibility rules than the rest of NumPy: RandomState is frozen, BitGenerators keep strong stream guarantees, and Generator stream changes are features that need caution."
x:
  paths: ["numpy/random/**"]
  source: ["doc/source/reference/random/compatibility.rst", "doc/neps/nep-0019-rng-policy.rst", "doc/neps/nep-0023-backwards-compatibility.rst", "doc/TESTS.rst"]
---

# numpy.random stream-compatibility policy

NEP 23 says `numpy.random` has its own compatibility policy on top of the general one. That policy is NEP 19, as summarised in the random "Compatibility policy" page. A change under `numpy/random/` should be reviewed against these rules.

## What is guaranteed

- Stream compatibility from run to run: the same `BitGenerator`, the same seed, the same sequence of calls and arguments, the same NumPy build, environment and machine should give the same numbers. Differences across CPUs or LAPACK builds (for example in `Generator.multivariate_normal`) are outside NumPy's control. Algorithms that resist such effects are preferred.
- The requested `size` counts as a parameter: `rng.random()` five times is not guaranteed to match `rng.random(5)`.
- API source compatibility follows the general NEP 23 deprecation policy.

## Rules for changes

- **`Generator` / `default_rng`:** breaking stream compatibility to add features or improve performance is "allowed with caution". Such changes are features, so they ship only in `X.Y` releases, never in `X.Y.Z`. Slowness is not a bug for this purpose. Weigh users' pain against the gain: a large speedup such as moving to Ziggurat is worthwhile, while slightly tweaking Ziggurat tables for a small gain is discouraged. `default_rng` may change its default BitGenerator, with caution and advance warning.
- **Correctness fixes** that break streams may go into bug-fix releases, but developers should consider waiting for the next feature release.
- **`BitGenerator` classes** have stronger version-to-version stream guarantees, documented in each class's docstring.
- **Legacy `RandomState` and the module-level convenience functions:** "There will be no more modifications to `RandomState`, not even to fix correctness bugs." The only exceptions are minor fixes that keep it working without segfaulting as internals change, and docstring fixes. NEP 19 says all current uses of `RandomState` continue to work in perpetuity, and mixed `RandomState`/`Generator` code shares BitGenerator state.

NEP 19 rejected versioning the RNG algorithms (keeping multiple versions of the same code) as hard to maintain and hard to use correctly. A change that adds such versioning goes against the accepted design.

Separately, the testing guidelines ask tests to draw random data from a seeded local `numpy.random.RandomState` instance.
