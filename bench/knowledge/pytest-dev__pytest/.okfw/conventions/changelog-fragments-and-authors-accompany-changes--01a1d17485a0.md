---
id: "01a1d174-85a0-777b-b72b-1cd57e9ae49e"
title: "Changelog Fragments and AUTHORS Accompany Changes"
type: "Guideline"
tags:
  - "changelog"
  - "pull-requests"
  - "review-checklist"
created: "2026-11-12T14:30:36-06:00"
timestamp: "2026-11-12T14:30:36-06:00"
description: "Every non-trivial change to pytest must ship a changelog fragment named <issueid>.<type>.rst in changelog/ and, for new contributors, an AUTHORS entry."
x:
  paths: ["src/**/*.py", "changelog/*.rst", "AUTHORS"]
  source: ["CONTRIBUTING.rst", ".github/PULL_REQUEST_TEMPLATE.md"]
---

# Changelog Fragments and AUTHORS Accompany Changes

pytest builds its release notes from small per-change files, so a reviewer should check that a pull request carries one whenever it changes documented behaviour.

## The rule

- Add a new file in the `changelog/` directory named `<issueid>.<type>.rst`, where *issueid* is the number of the related issue.
- *type* must be one of: `feature`, `improvement`, `bugfix`, `doc`, `deprecation`, `breaking`, `vendor`, `packaging`, `contrib`, or `misc`.
- The entry may be skipped only when the change "doesn't affect the documented behaviour of pytest", or when the change is trivial or a small documentation fix (a typo or reword of a small section).

## How the entry is written

The pull request template asks that fragments:

- are written in the **past or present tense** (examples given: "Improved verbose diff output with sequences." and "Terminal summary statistics now use multiple colors.");
- end the sentence with a period.

## Choosing the type

The type should match what the change does to users. A change that deprecates something uses `deprecation`; one that removes or breaks an API uses `breaking` (see [Backward Compatibility and Deprecation Policy](./backward-compatibility-and-deprecation-policy--01a1d17619c0.md)). Bug fixes normally land in patch releases and features in minor releases, so a mislabelled fragment can put a change in the wrong release section.

## Other checklist items from the pull request template

- Include documentation when adding new features.
- Include new tests or update existing tests when applicable (see [Testing Changes with Pytester](./testing-changes-with-pytester--01a1d1761a52.md)).
- Add the author to `AUTHORS`, in alphabetical order, unless the change is trivial or a small documentation fix.
- Link the fixed issue with text like `closes #XYZW` in the description or commits.
- If AI agents were used, credit them in `Co-authored-by` commit trailers. The contributing guide also states that purely agentic pull requests with no meaningful human review are not accepted: the submitter must understand the change and be able to answer review feedback.

## What a reviewer flags

- A behaviour change in `src/` with no file under `changelog/`.
- A fragment whose name does not follow `<issueid>.<type>.rst` or uses a type outside the list above.
- A fragment that is not a full sentence ending in a period.
