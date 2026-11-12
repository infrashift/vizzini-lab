---
id: "01a1d175-27f4-7d85-aaf9-1a01c85f451e"
title: "Configuration flags, defaults and upgrade impact"
type: "Guideline"
tags:
  - "configuration"
  - "compatibility"
  - "upgrade"
  - "cli"
created: "2026-11-12T14:31:18-06:00"
timestamp: "2026-11-12T14:31:18-06:00"
description: "New options are declared through cell.Config with every default set explicitly and chosen to minimize disruption on upgrade; CLI and user-facing changes need doc and upgrade notes."
x:
  paths: ["pkg/**/*.go", "daemon/**/*.go", "operator/**/*.go", "cilium-dbg/**/*.go", "install/kubernetes/**", "Documentation/cmdref/**"]
  source: ["Documentation/contributing/development/hive.rst", "Documentation/contributing/development/contributing_guide.rst", "Documentation/contributing/development/reviewers_committers/review_process.rst", "Documentation/contributing/release/backports.rst"]
---

# Configuration flags, defaults and upgrade impact

**Declaring options.** Cilium binaries use cobra and pflag. Hive bridges to them with `cell.Config`, which takes a default configuration struct implementing `Flags(*pflag.FlagSet)` and provides the parsed configuration to the application. Rules from the hive guide:

- "Every field in the default configuration structure must be explicitly populated."
- "When selecting defaults for the option, consider which option will introduce the minimal disruption to existing users during upgrade." If a flag keeps behavior from a previous release, its default should keep that behavior. "If you are introducing a new optional feature, consider disabling the option by default."
- In tests, prefer a config override over parsing flags.

**CLI reference docs.** "If you change CLI arguments of any binaries in this repo, the CI will reject your PR if you don't also update the command reference docs." The fix is to run `make postcheck` and commit the changes under `Documentation/cmdref`.

**Upgrade impact.** Contributors must "document any user-facing or breaking changes in `Documentation/operations/upgrade.rst`." Reviewers are told to "check for upgrade compatibility impact and if in doubt, set the label `upgrade-impact`" and raise it for discussion. The `upgrade-impact` label marks code changes that have a potential upgrade impact.

**Release notes.** Release notes are read by users, so notes for bugs and features should not contain internal details. The guide's example of a bad note is "Fix concurrent access in k8s watchers structures"; a good one is "Fix panic when Cilium received an invalid Cilium Network Policy from Kubernetes."

**Backports.** Bugfixes are candidates for backport to the current stable minor release. For the two older stable releases, only security-relevant fixes, major bugfixes for correct operation, and debug-tool improvements qualify. Because of this, a reviewer must check that a PR subject to backport "does not mix bugfix and refactoring of code", and ask for it to be split if it does.
