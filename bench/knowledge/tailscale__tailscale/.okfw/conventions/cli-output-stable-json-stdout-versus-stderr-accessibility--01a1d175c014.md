---
id: "01a1d175-c014-72ca-b0a3-99b50028e501"
title: "CLI output: stable JSON, stdout versus stderr, accessibility"
type: "Guideline"
tags:
  - "cli"
  - "api-compatibility"
  - "output"
  - "accessibility"
created: "2026-11-12T14:31:57-06:00"
timestamp: "2026-11-12T14:31:57-06:00"
description: "CLI commands should offer stable, backward-compatible --json output, send only intended output to stdout, avoid breaking positional parsers, and keep human output plain and screen-reader friendly."
x:
  paths: ["cmd/tailscale/**"]
  source: ["docs/cli.md"]
---

# CLI output: stable JSON, stdout versus stderr, accessibility

These rules come from the "Output and streams" part of `docs/cli.md`.

## Machine output

Commands should offer a **stable** JSON format behind `--json`. Once a feature is generally available, the JSON is kept backward compatible as far as possible. Backward compatibility means "existing fields keep their meaning." Adding fields is allowed and expected, and consumers must tolerate unknown fields. A change that renames, removes or changes the meaning of an existing JSON field in a GA command conflicts with this.

## Human-readable output

Non-JSON output is the default and should be optimized for sighted humans first and, where possible, for screen readers:

- Avoid decorative Unicode; prefer plain ASCII.
- Put information in the text, not only in color or position.
- Keep output uncluttered and scannable.

`grep`/`awk`-friendliness of stdout is kept on a best-effort basis and is not a hard guarantee. Be conservative with the shape of stable output: adding a **new column** in the middle of stable tabular output "most often should not be done" because it breaks positional parsers. Extending what an existing column can say is acceptable with care. When the human reader and the parser conflict, "protect the human reader, and make machine consumers use `--json`."

## stdout and stderr

- "stderr is the standard *information* stream." Status notes, progress, warnings and diagnostics go to stderr.
- stdout carries the command's intended output, or nothing, so it can be piped safely.
- `--help` output requested by the user is intended output and goes to stdout. A usage message printed as part of a bad-flag error is diagnostic and goes to stderr. The docs note that current help handling has a known problem here and that new code should follow the correct behavior.

## TTY detection and color

Changing behavior based on whether stdout is a TTY is allowed sparingly (for example, suppressing a spinner). Major behavior or output changes based on TTY detection "should not be added arbitrarily."

Colored or heavily decorated output is "deferred at this time and should not be added until guidance is clarified," mainly for accessibility reasons. All meaning must be present in the text itself.
