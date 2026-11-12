---
id: "01a1d175-2804-764a-85b2-4f2d47ef3eb7"
title: "StateDB tables and reconcilers for control-plane state"
type: "Guideline"
tags:
  - "statedb"
  - "architecture"
  - "concurrency"
  - "kubernetes"
created: "2026-11-12T14:31:18-06:00"
timestamp: "2026-11-12T14:31:18-06:00"
description: "New control-plane state belongs in StateDB tables with immutable objects, and side effects go through reconcilers rather than callbacks or ad hoc manager state."
x:
  paths: ["pkg/**/*.go", "daemon/**/*.go", "operator/**/*.go"]
  source: ["Documentation/contributing/development/statedb.rst", "Documentation/contributing/development/hive.rst", "pkg/loadbalancer/README.md"]
---

# StateDB tables and reconcilers for control-plane state

StateDB is an in-memory database used to manage Cilium control-plane state. The docs describe the target architecture as: *user intent tables* (Kubernetes objects, CRDs, kvstore data), *controllers* that compute *desired state tables* from them, and *reconcilers* that push desired state to targets such as BPF maps or the routing table. The goal is to move away from the "RWMutex+hashmap+callback pattern" and the "kitchen-sink Manager pattern", where a slow callback can stall critical functions and every component keeps its own copy of state.

The docs note that StateDB and reconciler APIs and metrics are not guaranteed to be stable yet.

**Table design guidelines:**
- Publicly provide `Table[Obj]` and export indexes or query functions. Do not export `RWTable[Obj]` unless other modules must write; if they do, consider writer functions that validate writes.
- Define a table next to its feature, or in `pkg/k8s/tables` / `pkg/datapath/tables` if it is shared.
- Objects must be JSON-marshallable for inspection; hide non-marshallable fields (private or `json:"-"`).
- For often-mutated maps or sets inside objects, consider `part.Map`/`part.Set`, which are immutable and need no deep copy.
- Export the table constructor so other modules' integration tests can use it. Write benchmarks for the table.
- Store small objects (<100 bytes) by value rather than by pointer.

**Pitfalls to flag in review:**
- Mutating an object after inserting it. Queries do not return copies, so every reader sees the change.
- Mutating an object stored by reference that came from a query and then reinserting it. StateDB will panic; objects must be shallow-cloned before mutating.
- Reading in a `ReadTxn` and using the results in a `WriteTxn`. The data may have changed; use `CompareAndSwap` for optimistic concurrency.

`tools/statedblint` catches some of these and runs in CI (`make statedb-lint`).

**Reconcilers.** Objects carry a `reconciler.Status` field and are inserted as pending. The reconciler calls `Update`, `Delete` and `Prune`, and retries failures with backoff. Errors are handled in the reconciler, not bubbled up to data sources. The load-balancer control plane follows this design: data sources write only through its `Writer` API, which keeps references between services, frontends and backends consistent.

**Kubernetes access.** The `Resource[T]` pattern "is being phased out in the Cilium Agent and new code should use StateDB." The Clientset "should usually only be used for creating and updating objects", so reads should go through reflected tables to limit API-server traffic.
