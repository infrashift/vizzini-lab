# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Backward compatibility of the Go SDK](backward-compatibility-of-the-go-sdk--01a1d1733183.md) - Public Go definitions under pkg/ must not change in a backward-incompatible way, while cmd/ and internal/ may change freely.
* [CLI, chart and file-format compatibility](cli-chart-and-file-format-compatibility--01a1d173318c.md) - Commands, flags, arguments, file formats such as Chart.yaml, chart behaviour and chart repository functionality must stay backward compatible within a major version.
* [Package layout and layering](package-layout-and-layering--01a1d173317b.md) - Helm splits code into a thin CLI entry point, public SDK packages under pkg/, and private implementations under internal/, with operations living in pkg/action.
* [Prefer plugins and extension points over core features](prefer-plugins-and-extension-points-over-core-features--01a1d173319f.md) - New functionality should be added through plugins and extension points where possible, and larger features need a Helm Improvement Proposal.
* [Testing expectations](testing-expectations--01a1d1733195.md) - Helm tests are table-driven with testify, use golden files in testdata/ for complex output and mock Kubernetes clients for action tests, and run with make test.

