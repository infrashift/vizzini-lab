# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [BPF datapath unit and integration tests](bpf-datapath-unit-and-integration-tests--01a1d1752825.md) - Datapath changes are tested with C test programs in bpf/tests run through BPF_PROG_RUN, using CHECK/PKTGEN/SETUP programs and macro-based mocking.
* [CRDs and slim Kubernetes types](crds-and-slim-kubernetes-types--01a1d175286e.md) - Cilium CRDs are Go structs with kubebuilder markers in pkg/k8s/apis whose generated code, registration, install list and RBAC must all be updated together; slim types only keep fields Cilium uses.
* [Cell constructors, lifecycle hooks and goroutine cleanup](cell-constructors-lifecycle-hooks-and-goroutine-cleanup--01a1d17527da.md) - Constructors only validate and allocate; goroutines and I/O start in Start hooks, and Stop hooks must block until everything the cell created is cleaned up.
* [Commit structure and Go dependency rules](commit-structure-and-go-dependency-rules--01a1d1752856.md) - Commits must build and work on their own with proper Fixes tags and sign-off, and new Go dependencies or replace directives must meet the vendor team's criteria.
* [Configuration flags, defaults and upgrade impact](configuration-flags-defaults-and-upgrade-impact--01a1d17527f4.md) - New options are declared through cell.Config with every default set explicitly and chosen to minimize disruption on upgrade; CLI and user-facing changes need doc and upgrade notes.
* [Datapath configuration with DECLARE_CONFIG](datapath-configuration-with-declare-config--01a1d1752816.md) - BPF programs get agent-provided settings through DECLARE_CONFIG/CONFIG() runtime variables declared close to their use, not through new node_config defines or conditional includes.
* [Go unit, privileged and script tests](go-unit-privileged-and-script-tests--01a1d175283c.md) - Go code is tested with the standard go test framework, privileged tests are gated and skipped by default, and cells are integration-tested with hive scripts.
* [Hive cells and module boundaries](hive-cells-and-module-boundaries--01a1d17527c9.md) - Cilium components are wired as hive cells through dependency injection, with interfaces as module APIs and no global state.
* [StateDB tables and reconcilers for control-plane state](statedb-tables-and-reconcilers-for-control-plane-state--01a1d1752804.md) - New control-plane state belongs in StateDB tables with immutable objects, and side effects go through reconcilers rather than callbacks or ad hoc manager state.

