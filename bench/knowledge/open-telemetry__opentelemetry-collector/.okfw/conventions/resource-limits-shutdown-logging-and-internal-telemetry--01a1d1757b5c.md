---
id: "01a1d175-7b5c-7bfe-b12c-255b779649f9"
title: "Resource Limits, Shutdown, Logging and Internal Telemetry"
type: "Guideline"
tags:
  - "performance"
  - "observability"
  - "logging"
  - "resource-management"
created: "2026-11-12T14:31:39-06:00"
timestamp: "2026-11-12T14:31:39-06:00"
description: "Rules for bounding resource use, shutting down within a time limit, logging sparingly and defining internal metrics through metadata.yaml."
x:
  paths: ["receiver/**", "processor/**", "exporter/**", "connector/**", "extension/**", "scraper/**", "service/**", "**/metadata.yaml"]
  source: ["docs/coding-guidelines.md", "docs/observability.md", "docs/component-stability.md"]
---

# Resource Limits, Shutdown, Logging and Internal Telemetry

**Bound every resource.** Code must limit its use of CPU, RAM and other resources and must not consume them "in an uncontrolled manner". A queue of unprocessed messages must always have a size limit unless something else guarantees it drains faster than it fills. When code cannot keep up with incoming data, it must not keep allocating until the process runs out of memory; it should drop data at the limit and record the drop in a metric exposed to users. Performance should be tested under normal load and under load many times higher than acceptable.

**Graceful shutdown.** Every component must be ready to shut down through the `Shutdown()` method all component interfaces require. Temporary data should be processed and exported before shutdown completes, and the shutdown operation needs a bounded duration.

**Logging.** Log component startup and shutdown, including successful outcomes, but keep success messages to a minimum. Never log per received or processed data item: the Collector handles many thousands of items per second. For high-frequency events, increment an internal metric instead. Log messages should be human readable and carry enough context.

**Internal metrics.**
- Define custom metrics in the component's `metadata.yaml` and run `go generate` (mdatagen), which produces `documentation.md` and `internal/metadata/generated_telemetry.go`. Components then use the generated `TelemetryBuilder`.
- Metrics produced by Collector components use the `otelcol_` prefix; instrumentation scope defaults to the component's package name and the recommendation is to keep it.
- Prefer core components and helper libraries (for example the exporter helpers that emit `otelcol_exporter_sent_spans`) so components are observed consistently.
- Use the units `{records}`, `{spans}` and `{datapoints}` for counts of logs, spans and data points.
- Telemetry should include attributes identifying the component instance.
- The default observability level must have insignificant performance impact.

**Semantic conventions.** Before adding metrics or attributes to a component, check whether Semantic Conventions already define them. Promoting a metric to stable without a matching Semantic Convention needs explicit justification.

Stable components should emit enough internal telemetry to detect errors, data loss and performance issues.
