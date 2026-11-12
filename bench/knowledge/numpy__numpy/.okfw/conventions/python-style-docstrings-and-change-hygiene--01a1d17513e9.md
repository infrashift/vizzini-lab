---
id: "01a1d175-13e9-7c24-9ee3-715d1246c9d5"
title: "Python style, docstrings and change hygiene"
type: "Guideline"
tags:
  - "style"
  - "documentation"
  - "pep8"
  - "review"
created: "2026-11-12T14:31:13-06:00"
timestamp: "2026-11-12T14:31:13-06:00"
description: "Python code follows PEP 8 checked by ruff, uses NumPy dtype objects and `import numpy as np`, is documented with numpydoc docstrings, and is submitted as focused, prefixed, reviewed changes with release notes."
x:
  paths: ["numpy/**/*.py", "numpy/**/*.pyi", "doc/release/upcoming_changes/**"]
  source: ["doc/source/dev/index.rst", "doc/source/dev/development_workflow.rst", "doc/source/dev/howto-docs.rst", "doc/source/dev/reviewer_guidelines.rst", "doc/source/dev/ai_policy.rst"]
---

# Python style, docstrings and change hygiene

## Stylistic guidelines (dev guide)

- Follow PEP 8 (no trailing whitespace, no tabs, etc.) and check code with ruff.
- Use NumPy data types instead of strings: `np.uint8`, not `"uint8"`.
- Import as `import numpy as np`.
- C code follows NEP 45 (see the C style concept).
- Do not add copyright notices to source files without discussing it first.

## Documentation

- "All code should be documented", using the numpydoc docstring standard (Parameters and other sections with `---` underlines).
- Examples inside NumPy docstrings need not start with `import numpy as np`.
- Docstrings for objects defined in C extensions (for example `ndarray.transpose` and `numpy.array`) live separately in `numpy/_core/_add_newdocs.py`.
- Reviewers check that docstrings are properly formatted. They are also asked whether variable names could be clearer and whether comments should be added or removed as unhelpful.
- Behaviour changes are recorded in docs with `.. deprecated::` or `.. versionchanged::` directives (NEP 23).

## Shape of a change

- Changes that touch the API or add or modify a function need a release-note fragment in `doc/release/upcoming_changes/`, in the format given by that directory's README.
- Commit messages and PR titles start with a standard prefix such as `API`, `BUG`, `DEP`, `DOC`, `ENH`, `MAINT`, `TST`, `TYP` or `STY`. Messages should explain the motivation and be understandable without reading the code.
- In source code, refer to issues and PRs as `gh-xxxx`.
- "Please do not change unrelated lines." Unrelated changes make review harder and cause merge conflicts.
- New features and API changes should first be raised on the mailing list. Complex or public-API PRs are left open for a couple of days so other maintainers can comment, and need approval from at least one core team member. CI and the docs build must pass.

## AI-assisted contributions

The AI policy requires PRs to disclose whether AI tools were used, which tools, and which code or text they generated. PRs without this disclosure are rejected. Submitters must understand and be able to explain all code they submit. Pull requests opened autonomously by an AI agent are not permitted. "AI slop" is rejected, and submitters are responsible for any copyright issues in generated code.
