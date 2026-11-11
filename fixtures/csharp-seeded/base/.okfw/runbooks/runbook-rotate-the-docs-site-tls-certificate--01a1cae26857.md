---
id: "01a1cae2-6857-7409-a8f6-2be67ee7616e"
title: "Runbook: rotate the docs site TLS certificate"
type: "note"
tags:
  - "runbook"
  - "tls"
created: "2026-11-11T07:53:17-06:00"
timestamp: "2026-11-11T07:53:17-06:00"
description: "How to renew and deploy the documentation site's TLS certificate before it expires."
x:
  paths: ["docs/**"]
---

# Runbook: rotate the docs site TLS certificate

Renew with the internal CA 30 days before expiry, then redeploy the docs site. Unrelated to application code.
