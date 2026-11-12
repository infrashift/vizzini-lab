---
id: "01a1d175-7bfa-71c6-ba7c-191b878b356f"
title: "Feature Gates for User-Facing Breaking Changes"
type: "Guideline"
tags:
  - "feature-gates"
  - "backward-compatibility"
  - "deprecation"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "When and how to use feature gates to roll out end-user breaking changes through the alpha, beta and stable stages."
x:
  paths: ["featuregate/**", "**/metadata.yaml", "**/generated_feature_gates.go"]
  source: ["docs/coding-guidelines.md", "featuregate/README.md"]
---

# Feature Gates for User-Facing Breaking Changes

End-user breaking changes (runtime behaviour, configuration, telemetry output) follow the feature gate approach, modelled on Kubernetes, so users can adopt or delay a change independently of other Collector updates. Breaking changes MUST have migration guidelines, and users SHOULD be warned before migration is required.

**Defining gates**
- Prefer declaring gates in the component's `metadata.yaml` under `feature_gates`, with `id`, `description`, `stage`, `from_version` and `reference_url` (plus `to_version` for `stable` or `deprecated`). mdatagen generates the registration in `internal/metadata`.
- Packages without mdatagen register gates in an `init()` function on `featuregate.GlobalRegistry()`. A gate marked `Stable` must have a removal version.
- IDs are dot-namespaced and as specific as possible. Component gates use `<component kind>.<component type>.<base ID>`, where the base ID is a verb describing what happens when the gate is enabled, e.g. `receiver.otlp.UseUnspecifiedHostAsDefaultHost`.
- Checking a gate takes a read lock and a map lookup, so check once and cache the result; do not query the registry in a loop.

**Lifecycle**
- **Alpha**: disabled by default (opt-in). Add a changelog entry naming the gate and its effect; logging a warning when a user relies on the behaviour that will change is strongly recommended. Update docs and examples if that can be done without affecting users.
- **Beta**: enabled by default (opt-out). Add a second changelog entry marked breaking and set the gate's `to_version`. Where applicable, error messages should say the behaviour came from a breaking change that can be temporarily reverted by disabling the gate. Low-impact or performance-only changes may start here.
- **Stable**: permanently on. Disabling it is an error and enabling it logs a warning. Remove the dead code, drop gate references from docs, error messages and examples, and add a final changelog entry. The gate is removed at its `ToVersion`.
- **Deprecated**: a feature that proves unworkable is permanently disabled and the gate is removed after at least two releases. A beta feature being discontinued returns to alpha for two releases first.

A reviewer should check that behaviour changes visible to users are gated, that gate IDs follow the naming scheme, and that gate checks are not placed on hot paths.
