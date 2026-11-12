---
id: "01a1d174-7a31-79e6-b8ad-fe27c4ba44e5"
title: "Format tests and snapshots"
type: "Guideline"
tags:
  - "testing"
  - "snapshots"
  - "jest"
created: "2026-11-12T14:30:34-06:00"
timestamp: "2026-11-12T14:30:34-06:00"
description: "Formatting changes are tested with Jest snapshots driven by runFormatTest, and snapshots must be updated and included in every PR."
x:
  paths: ["tests/format/**", "tests/config/**", "tests/integration/**", "tests/unit/**"]
  source: ["CONTRIBUTING.md", ".github/PULL_REQUEST_TEMPLATE.md"]
---

# Format tests and snapshots

## Snapshot tests

The tests use Jest snapshots. After a change, run `yarn test -u` (or `jest -u`) and inspect `git diff`. CONTRIBUTING.md says: "Always update the snapshots when opening a PR." The PR template asks the author to confirm "I've added tests to confirm my change works." A reviewer should expect a behavior change in a printer to come with new or changed fixtures and the matching snapshot diff, and should read that diff as the real description of the change.

## `format.test.js` and `runFormatTest`

Every directory in `tests/format` has a `format.test.js` with one or more calls to the global `runFormatTest(fixtures, parsers, options?)`:

- `fixtures` is `import.meta`, or `{ importMeta: import.meta, snippets }` to add inline inputs (snippets may give expected `output` directly).
- `parsers` lists parsers that must all produce the **same** output. Some are added implicitly: `typescript` also covers `babel-ts`, `oxc-ts` and `yuku-ts`; `flow` covers `hermes`; and `babel` under `tests/format/js` or `tests/format/jsx` also covers `acorn`, `espree`, `meriyah`, `oxc` and `yuku`. A change that only works for one parser will therefore fail for the others.
- `options` passes formatting options, plus `errors` to declare inputs/parsers that are expected to throw.

## Deeper checks

`FULL_TEST=1 jest` adds checks that also run on CI:

- **compare AST**: the output re-parses to an AST equivalent to the input's;
- **second format**: formatting the output again gives identical output (idempotency);
- **EOL `\r\n` and `\r`**: changing line endings in the input does not change the output;
- **BOM**: adding a BOM only affects output by preserving the BOM.

Changes should keep all of these properties.

## Vendored Flow tests

`tests/format/flow/flow-repo/` holds the Flow test suite and "is not supposed to be edited by hand." It is updated with `scripts/sync-flow-tests.cjs` from a Flow checkout. Hand edits there should be flagged.
