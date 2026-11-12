# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Architecture and module boundaries](architecture-and-module-boundaries--01a1d1764fbf.md) - How rclone is split into fs core, backends, commands, lib and vfs, and why core code must stay backend-agnostic.
* [Backend implementation conventions](backend-implementation-conventions--01a1d1764fec.md) - Layout and library rules a new or changed backend must follow so that rclone's many backends stay alike.
* [Backward compatibility and minimal changes](backward-compatibility-and-minimal-changes--01a1d176589d.md) - Rclone treats the observable behaviour of commands, flags and the rc API as a contract, and expects every change to be as small as possible.
* [Code comments, help text and docs](code-comments-help-text-and-docs--01a1d17658f6.md) - Rclone's rules for godoc comments, inline comments, option Help text and which documentation files are hand-edited or generated.
* [Errors, retries and exit codes](errors-retries-and-exit-codes--01a1d176591e.md) - How rclone classifies errors into retry categories, separates low-level from high-level retries, and maps outcomes to exit codes.
* [Filename encoding and metadata contracts](filename-encoding-and-metadata-contracts--01a1d1765285.md) - Rules backends follow for restricted characters, invalid UTF-8 and the shared metadata framework.
* [Optional features and fallback behaviour](optional-features-and-fallback-behaviour--01a1d1765016.md) - What each optional fs.Features capability means and how rclone falls back when a backend lacks it.
* [Security boundaries and secret handling](security-boundaries-and-secret-handling--01a1d1765947.md) - The security model the docs state for the rc API, credential redaction and test servers.
* [Testing expectations](testing-expectations--01a1d17658c8.md) - Which tests a change needs in rclone, from unit tests and quicktest to backend integration tests and test_all.

