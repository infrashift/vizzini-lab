---
id: "01a1d175-bea3-73ac-af6c-fc3d8ae96f1c"
title: "Dependency footprint: depaware files and DepChecker tests"
type: "Guideline"
tags:
  - "dependencies"
  - "binary-size"
  - "testing"
  - "review"
created: "2026-11-12T14:31:57-06:00"
timestamp: "2026-11-12T14:31:57-06:00"
description: "Every change to a binary's dependency graph must appear as a depaware.txt diff in the same PR, the minimal build's depaware file must not grow without good reason, and omissions are locked down with deptest.DepChecker."
x:
  paths: ["**/depaware*.txt", "cmd/tailscaled/deps_test.go", "tstest/deptest/**", "tsnet/tsnet_test.go", "feature/hooks.go"]
  source: ["feature/README.md", "tsnet/README.md"]
---

# Dependency footprint: depaware files and DepChecker tests

## depaware

`depaware` snapshots the full set of Go packages linked into each tracked binary into a checked-in `depaware.txt`. Its job is "to force us to be *aware of our deps*." Every change to the dependency graph "shows up as a diff to `depaware.txt` in the same PR that introduced it," giving an auditable history of the dependency footprint. Tracked flavors include:

- full `tailscaled` and full `tailscale` CLI on all GOOSes
- `cmd/derper`
- minimal `tailscaled`+CLI (`depaware-min.txt`, `depaware-minbox.txt`)
- `tsnet` (its own `depaware.txt`)
- `k8s-operator`, which uses `tsnet`

The docs give reviewers a direct instruction: "When reviewing a PR, look at the depaware diff to see what got pulled in or dropped, and make sure the changes make sense." A PR that adds imports but has no matching depaware update, or whose depaware diff pulls in unexpected packages, deserves a question.

## The minimal build is protected

"The minimal build's depaware file is sacred and must not grow without good reason." This is why hooks in `feature/hooks.go` must not mention types from heavy packages (`net/http`, `crypto/tls`, `golang.org/x/crypto/ssh`, `k8s.io/...`, or anything using `reflect`-based registration): doing so would grow `cmd/tailscaled/depaware-min.txt`.

The same concern applies to `tsnet`: for example, workload identity federation is not linked by default "to keep the AWS SDK and other cloud-provider dependencies out of programs that don't use" it; programs opt in with a blank import of `tailscale.com/feature/identityfederation`.

## Locking down omissions

Once a feature can be omitted, `deptest.DepChecker` locks that in instead of "hoping nobody accidentally adds a `taildrop` import back into a `ts_omit_taildrop` build." A test sets `GOOS`, `GOARCH`, `Tags` (for example `ts_omit_acme,ts_include_cli`) and an `OnDep` callback that fails on unexpected packages. `cmd/tailscaled/deps_test.go` has many examples, and new ones can go there or wherever they fit. `tsnet` has its own `TestDeps` in `tsnet_test.go` with a `BadDeps` map asserting that packages such as `feature/remoteconfig`, `feature/syspolicy` and `x/crypto/ssh` never get into `tsnet`.

For a new feature, the docs expect a DepChecker test for the omitted case and a regenerated, reviewed depaware diff.
