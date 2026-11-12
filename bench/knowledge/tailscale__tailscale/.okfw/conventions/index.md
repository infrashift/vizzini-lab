# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [CLI command structure and where settings live](cli-command-structure-and-where-settings-live--01a1d175bf25.md) - Guidelines for adding tailscale CLI surface: keep configurability low, prefer noun-verb subcommands and set/get preferences, keep up closed, and treat daemon flags and env vars as last resorts.
* [CLI output: stable JSON, stdout versus stderr, accessibility](cli-output-stable-json-stdout-versus-stderr-accessibility--01a1d175c014.md) - CLI commands should offer stable, backward-compatible --json output, send only intended output to stdout, avoid breaking positional parsers, and keep human output plain and screen-reader friendly.
* [Commit message and pull request conventions](commit-message-and-pull-request-conventions--01a1d175c03e.md) - Tailscale commits use Go/Linux-style "pkg/path: imperative verb" subjects, a Fixes or Updates line, Signed-off-by, and no fixup commits; each commit in a PR must be logically separate and pass tests.
* [Dependency footprint: depaware files and DepChecker tests](dependency-footprint-depaware-files-and-depchecker-tests--01a1d175bea3.md) - Every change to a binary's dependency graph must appear as a depaware.txt diff in the same PR, the minimal build's depaware file must not grow without good reason, and omissions are locked down with deptest.DepChecker.
* [Feature build tags, buildfeatures constants and registration checks](feature-build-tags-buildfeatures-constants-and-registration-checks--01a1d175b31c.md) - How ts_omit_* build tags, generated buildfeatures constants, condregister shims and feature.IsRegistered fit together, and the mistakes to look for.
* [Generated files and forked code must stay in sync](generated-files-and-forked-code-must-stay-in-sync--01a1d175c065.md) - Several checked-in files are generated or forked; changes must go through their source and generator in the same change rather than hand-editing the output.
* [Hooks and IPN extensions: per-backend state, not globals](hooks-and-ipn-extensions-per-backend-state-not-globals--01a1d175b35d.md) - Rules for feature.Hook, feature.Hooks and ipnext extensions, including keeping state per LocalBackend and designing hooks for multiple writers.
* [New functionality belongs in modular feature packages](new-functionality-belongs-in-modular-feature-packages--01a1d175b2eb.md) - New client functionality should live in a self-contained feature/<name> package that installs itself via hooks from init, not be added to LocalBackend or ipn/ipnlocal.

