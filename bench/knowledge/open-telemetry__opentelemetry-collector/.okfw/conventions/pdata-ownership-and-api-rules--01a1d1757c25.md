---
id: "01a1d175-7c25-7ed7-96db-f781e87169d7"
title: "pdata Ownership and API Rules"
type: "Guideline"
tags:
  - "pdata"
  - "concurrency"
  - "data-ownership"
  - "api"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Who may read or modify pipeline data at each point in a pipeline, and the structural rules every pdata type must follow."
x:
  paths: ["pdata/**", "consumer/**", "processor/**", "connector/**", "exporter/exporterhelper/**"]
  source: ["processor/README.md", "pdata/README.md", "CONTRIBUTING.md"]
---

# pdata Ownership and API Rules

pdata is the in-memory form of all telemetry: receivers convert into it, it travels through the pipeline, and exporters convert out of it.

**Data ownership in pipelines** (processor/README.md)
- Ownership of `Traces`, `Metrics` and `Logs` is passed along with each `ConsumeTraces`/`ConsumeMetrics`/`ConsumeLogs` call.
- A processor that modifies data must declare it with `MutatesData: true` in `Capabilities()`. Any such processor puts the pipeline, and every other pipeline fed by the same receiver, into exclusive ownership mode; the fan-out then clones data for each pipeline.
- In exclusive mode a processor owns the data from the start of its `Consume*` call until it calls the next consumer. After that call it "must no longer read or write the data since it may be concurrently modified by the new owner".
- In shared mode no processor may modify the data it receives. A processor that needs changes but wants to avoid cloning may declare `MutatesData=false` only if it never mutates the original, for example by using copy-on-write on sub-parts.

Reviewers should flag code that touches a payload after handing it downstream, or that mutates input while reporting `MutatesData=false`.

**pdata API rules** (pdata/README.md)
- No pdata instance may reference an object used by another instance; the API is designed to avoid mutable data sharing.
- Every pdata struct MUST have a `New...` constructor. Zero-initialized values are prohibited and can panic.
- Every struct MUST provide `MoveTo` (destination overwritten, source reset to empty) and `CopyTo` (deep copy, source unchanged).
- Names follow the OTLP protobuf messages; nested messages take the owner's name as prefix (`ExponentialHistogramDataPointBuckets`). Only a short list of exceptions is accepted.
- Scalar and enum fields need `Set...` setters; optional fields need `Has...` and `Remove...`; oneof options need getters/setters, `SetEmpty...` for message options, a `Type`/`<field>Type` getter and an `...Empty` constant; repeated fields become `...Slice` types; flags are immutable `uint32` types with `With...` setters and a `Default...` value.
- The underlying protobuf struct stays private so it can change.

Much of pdata is generated: when OTLP adds fields, the matching change is made in the generator under `pdata/internal/cmd/pdatagen/internal` and the code is regenerated with `make genproto` and `make genpdata`.
