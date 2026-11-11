---
id: "01a1cb22-38af-76ee-acaa-aa825c8297c0"
title: "Runbook: rotate the CDN origin certificate"
type: "note"
tags:
  - "runbook"
  - "tls"
created: "2026-11-11T09:03:00-06:00"
timestamp: "2026-11-11T09:03:00-06:00"
description: "How to renew the CDN origin certificate before it expires."
x:
  paths: ["docs/**"]
---

# Runbook: rotate the CDN origin certificate

Renew via the internal CA 30 days before expiry and upload it to the CDN. Unrelated to application code.
