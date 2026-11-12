---
id: "01a1d174-7a08-71cd-b122-6f9a25409039"
title: "No new formatting options"
type: "Guideline"
tags:
  - "options"
  - "api"
  - "policy"
created: "2026-11-12T14:30:33-06:00"
timestamp: "2026-11-12T14:30:33-06:00"
description: "The option set is frozen: pull requests that add formatting options, or that preserve input formatting as a disguised option, are not accepted."
x:
  paths: ["src/main/core-options.evaluate.js", "src/common/common-options.evaluate.js", "src/cli/cli-options.evaluate.js", "src/language-*/options.js", "docs/options.md"]
  source: ["CONTRIBUTING.md", "docs/option-philosophy.md"]
---

# No new formatting options

## The rule

CONTRIBUTING.md is direct: "Prettier is an opinionated formatter and is not accepting pull requests that add new formatting options." The option philosophy page repeats it in bold: "Prettier has a few options because of history. **But we won't add more of them.**" and "Option requests aren't accepted anymore."

A reviewer should flag any change that adds a new formatting option to the core option definitions, a language's `options.js`, or the CLI option list.

## Why

The main reason to adopt Prettier is to stop debates over style. Every option turns a style debate into a debate about which option value to pick. The docs also note that demand is hard to measure and that "just one more" option never ends.

Existing options fall into two groups:

- Options that are easier to justify, mostly for compatibility or technical reasons: `--trailing-comma=es5`, `--prose-wrap`, `--html-whitespace-sensitivity`, `--end-of-line`, `--quote-props`.
- Options the team regrets: `--arrow-parens`, `--jsx-single-quote`, `--bracket-same-line` and `--no-bracket-spacing`. They are "a historical artifact and should not motivate adding more options". An argument of the form "if those exist, why not this one?" is explicitly rejected.

## Preserving input formatting counts as an option

Requests to "preserve elements of input formatting (e.g. line breaks)" are treated the same way, because that is "nothing else but an option in disguise with all the downsides of 'real' options." A change that makes output depend on how the input happened to be laid out should be viewed with the same suspicion as a new option (see the reversibility concept for the few existing exceptions).

## The one exception

"There may be situations where adding an option can't be avoided because of technical necessity (e.g. compatibility), but for formatting-related options, this is final." A non-formatting option added for compatibility must still be justified on those grounds.
