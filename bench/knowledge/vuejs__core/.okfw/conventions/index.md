# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Bundle size, tree-shaking and __DEV__ branches](bundle-size-tree-shaking-and-dev-branches--01a1d1742fb2.md) - Every change must justify its bundle-size cost, keep dev-only and compiler-only code out of production runtime builds, and stay tree-shakable.
* [Code style, runtime constraints and PR scope](code-style-runtime-constraints-and-pr-scope--01a1d1742ff0.md) - Vue core expects boring, focused changes that follow existing style, avoid optional chaining in runtime source, and never bundle unrelated refactors.
* [Package boundaries and cross-package imports](package-boundaries-and-cross-package-imports--01a1d1742f92.md) - Vue core is a monorepo of layered packages, and code may only cross package boundaries through package-name imports that respect the compiler/runtime split.
* [Performance in runtime hot paths](performance-in-runtime-hot-paths--01a1d1742fd1.md) - Changes to the virtual DOM renderer, component instantiation and Vapor render effects need extra performance scrutiny, and performance claims need benchmarks.
* [Public API changes, compatibility and commit messages](public-api-changes-compatibility-and-commit-messages--01a1d174302e.md) - New API surface targets the minor branch and needs strong justification, runtime behavior breakage is avoided above all else, and breaking changes are declared in the commit footer.
* [Testing expectations for changes](testing-expectations-for-changes--01a1d1743010.md) - Fixes need a test that fails without the fix, tests use the minimal API and the right runtime, snapshot tests need explicit assertions, and type changes need dts tests.
* [Vapor interop, SSR and template trust boundaries](vapor-interop-ssr-and-template-trust-boundaries--01a1d174304d.md) - Vapor and VDOM interop changes must be verified in both directions, Vapor runtime ships only as an esm-bundler browser build, and template source is a trusted input by policy.

