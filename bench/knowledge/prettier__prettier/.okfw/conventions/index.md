# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [Building Docs correctly in printers](building-docs-correctly-in-printers--01a1d1747a1d.md) - Printers build a Doc intermediate representation with the builder commands, and commands.md states rules and limits for using them correctly and efficiently.
* [Correctness first: print, never transform](correctness-first-print-never-transform--01a1d17479fc.md) - Formatted output must be valid code with exactly the same behavior as the input, and Prettier only reprints code; it never rewrites or reorders it.
* [Format tests and snapshots](format-tests-and-snapshots--01a1d1747a31.md) - Formatting changes are tested with Jest snapshots driven by runFormatTest, and snapshots must be updated and included in every PR.
* [Language plugin contract: parsers, printers, embed and comments](language-plugin-contract-parsers-printers-embed-and-comments--01a1d1747a26.md) - Built-in languages and external plugins share one plugin contract, and plugins.md defines the required shape and behavior of parsers, printers, embed, visitor keys and comment handling.
* [No new formatting options](no-new-formatting-options--01a1d1747a08.md) - The option set is frozen: pull requests that add formatting options, or that preserve input formatting as a disguised option, are not accepted.
* [Performance changes and how to measure them](performance-changes-and-how-to-measure-them--01a1d1747a45.md) - Performance contributions should be measured with Prettier's debug and benchmark tooling against a production build, and printer code should avoid the documented expensive patterns.
* [Pull request requirements: changelog, docs and public API](pull-request-requirements-changelog-docs-and-public-api--01a1d1747a3d.md) - User-facing changes need a changelog_unreleased entry, API or CLI changes need docs updates, and the public API stays asynchronous.
* [Reversible output and the few input-dependent heuristics](reversible-output-and-the-few-input-dependent-heuristics--01a1d1747a12.md) - Prettier avoids formatting that depends on the original layout; the documented exceptions (objects, decorators, template literals, blank lines, certain long lines) are deliberate and should not be extended casually.

