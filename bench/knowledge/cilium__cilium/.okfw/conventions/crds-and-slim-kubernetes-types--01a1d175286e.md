---
id: "01a1d175-286e-7b6e-9ee1-0c4c2b76593e"
title: "CRDs and slim Kubernetes types"
type: "Guideline"
tags:
  - "kubernetes"
  - "crd"
  - "api"
  - "codegen"
created: "2026-11-12T14:31:18-06:00"
timestamp: "2026-11-12T14:31:18-06:00"
description: "Cilium CRDs are Go structs with kubebuilder markers in pkg/k8s/apis whose generated code, registration, install list and RBAC must all be updated together; slim types only keep fields Cilium uses."
x:
  paths: ["pkg/k8s/apis/**", "pkg/k8s/client/**", "pkg/k8s/synced/**", "pkg/k8s/watchers/**", "pkg/k8s/slim/**", "install/kubernetes/cilium/templates/**/clusterrole.yaml"]
  source: ["Documentation/contributing/development/introducing_new_crds.rst", "pkg/k8s/slim/README.md", "Documentation/contributing/development/dev_setup.rst"]
---

# CRDs and slim Kubernetes types

**Defining CRDs.** Cilium CRDs are Go structures in `pkg/k8s/apis/cilium.io/v2/` and `pkg/k8s/apis/cilium.io/v2alpha1/`. The directory after `apis/` gives the Group and Version. Markers in comments (`+kubebuilder:resource`, `+kubebuilder:storageversion`, `+genclient`, `+k8s:deepcopy-gen`, validation markers such as `format=cidr` and `required`) tell `controller-gen` how to generate the CRD and its JSON-schema validation.

**Generated code must be regenerated, not hand-written.** Generated artifacts include CRD YAML, the client, listers, informers, `DeepCopy` and `DeepEqual`.
- Add the CRD's plural name to `CRDS_CILIUM_V2` or `CRDS_CILIUM_V2ALPHA1` in the `Makefile`, then run `make manifests`. Manifests land in `pkg/k8s/apis/cilium.io/client/crds/<version>/`.
- Run `make generate-k8s-api` for client-go integration. `contrib/scripts/check-k8s-code-gen.sh` regenerates both.

**Integration checklist for a new CRD.** A complete change touches all of these:
- Register the types and name constants in the version's `register.go`, and bump `CustomResourceDefinitionSchemaVersion` so Cilium knows new CRDs were added.
- Register with the client in `pkg/k8s/apis/cilium.io/client/register.go`, including the `//go:embed` of the generated YAML.
- Configure the watcher in `pkg/k8s/watchers/watcher.go`, or tell the agent to skip it.
- Add the CRD to the install list in `pkg/k8s/synced/crd.go`.
- Grant create/read/update/delete permissions in the agent, operator and preflight `clusterrole.yaml` Helm templates.

**Slim types.** `pkg/k8s/slim` holds slim copies of upstream Kubernetes structures used by Cilium's watchers. When syncing them, "only the changes relevant to the structures used by Cilium are necessary to keep". Upstream functions, fields or structs that Cilium does not use can be removed. When the minimum supported Kubernetes version changes, the docs ask to remove code that existed only for older versions (most likely under `pkg/k8s`) and update `MinimalVersionConstraint` in `pkg/k8s/version/version.go`.
