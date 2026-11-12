---
id: "01a1d176-1a7f-7d2a-873f-f1613c14a846"
title: "Code Style, Docstrings and Typing"
type: "Guideline"
tags:
  - "style"
  - "docstrings"
  - "typing"
  - "documentation"
created: "2026-11-12T14:32:20-06:00"
timestamp: "2026-11-12T14:32:20-06:00"
description: "pytest code follows PEP 8 naming enforced by pre-commit, uses Sphinx-format docstrings that feed the API reference, and relies on type annotations rather than types in docstrings."
x:
  paths: ["src/**/*.py", "testing/**/*.py", "doc/en/**/*.rst", ".pre-commit-config.yaml"]
  source: ["CONTRIBUTING.rst", ".github/PULL_REQUEST_TEMPLATE.md", "doc/en/explanation/types.rst"]
---

# Code Style, Docstrings and Typing

## Formatting and naming

- Follow PEP 8 for naming.
- Style and code checks are enforced by `pre-commit`; contributors are asked to install it so that it runs (and re-formats files if needed) on every commit. The `linting` tox environment runs the same checks. A reviewer should not need to comment on formatting that pre-commit handles; a pull request that fails linting is not ready.

## Docstrings

pytest's API reference is "in large part generated automatically" from docstrings, so docstrings on public items are user documentation. The contributing guide says "there can never be too many of them" and gives the format:

- Sphinx docstring format.
- A subject line, then more detail in separate paragraphs.
- "Use proper sentences -- start sentences with capital letters and end with periods."
- `:param name:` entries for arguments (long text continues on indented lines), `:returns:` for the result, and `:raises SomeError:` describing when an exception happens.
- Version directives such as `.. versionadded:: 6.0` for new API.
- "Including types into the annotations above is not necessary when type-hinting is being used". Types belong in the signature, not repeated in the docstring.

## Typing

The source tree ships `py.typed` markers for both `pytest` and `_pytest`, and the docs explain why typing matters for the project's production code: a type checker catches bugs that "might not be caught by tests at all (regardless of coverage)", such as a function that can fall through and return `None`. For tests, the main benefit is refactoring, since the type checker points out needed changes without running the full suite. Fixtures are typed like normal functions; nothing special is needed for the `fixture` decorator.

The stash API exists partly for typing reasons: assigning ad-hoc private attributes to items is something "type-checkers like mypy frown upon" (see [Hook Specification and Implementation Rules](./hook-specification-and-implementation-rules--01a1d1761a20.md)).

## Documentation with features

The pull request checklist requires documentation when adding new features. Documentation sources are under `doc/en/` and build with `tox -e docs`.

## Review checks

- Public functions or classes without a docstring, or docstrings that are not full sentences.
- Types repeated in docstrings when the signature is annotated.
- New features without documentation or without a `versionadded` note.
