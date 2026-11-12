---
id: "01a1d175-a00a-7b69-9ce3-ad94b2def549"
title: "Architecture and Design Philosophies"
type: "Guideline"
tags:
  - "architecture"
  - "design"
  - "performance"
  - "coupling"
created: "2026-11-12T14:31:49-06:00"
timestamp: "2026-11-12T14:31:49-06:00"
description: "The design principles Django uses to judge changes: loose coupling between layers, explicitness, DRY, SQL efficiency, a minimal cache hot path, and benchmarked optimizations."
x:
  paths: ["django/**/*.py"]
  source: ["docs/misc/design-philosophies.txt", "docs/internals/contributing/writing-code/submitting-patches.txt", "docs/internals/contributing/committing-code.txt"]
---

# Architecture and Design Philosophies

Django's design-philosophies document is meant "to explain the past and guide the future". It gives reviewers principles for judging whether a change fits the framework.

**Layer boundaries**
- The goal is "loose coupling and tight cohesion". Framework layers should not know about each other "unless absolutely necessary".
- The template system knows nothing about web requests. The database layer knows nothing about data display. Views don't care which template system is used, or whether one is used at all.
- The stack ships as a whole, but its pieces stay independent wherever possible. A change that makes one layer depend on another without real necessity goes against this principle.
- URLs are not coupled to Python function names, and the same app's URLs can differ between sites.

**General principles**
- Explicit is better than implicit. Magic is acceptable only for "a huge convenience unattainable in other ways", and only when it doesn't confuse people learning the feature.
- DRY: every distinct concept or piece of data lives in exactly one place.
- Less code: no boilerplate, and use Python's introspection where that helps.
- Consistency at every level, from coding style to the experience of using Django.
- Models follow Active Record. All the information about an object, including its metadata, lives in the model class.

**Performance**
- The database API should run SQL "as few times as possible" and optimize statements internally. That is why `save()` is explicit and why `select_related()` exists.
- The ORM should allow rich queries with terse syntax, perform joins automatically, and let every object reach its related objects in both directions. It should still make it easy to drop into raw SQL.
- Cache framework code around the backend should be "kept to the absolute minimum, especially for `get()` operations". The cache API stays consistent across backends.
- A patch that claims a performance improvement must include before-and-after benchmarks and the commands reviewers need to reproduce them. Adding `django-asv` benchmarks is encouraged.

**Change scope**
The committing guidelines ask for the most granular sensible change, with bug fixes kept separate from feature changes because fixes may be backported. Medium-to-large changes should be discussed on the Django Forum first.
