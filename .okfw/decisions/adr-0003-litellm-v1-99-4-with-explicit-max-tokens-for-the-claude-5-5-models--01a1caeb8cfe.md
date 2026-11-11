---
id: "01a1caeb-8cfe-7c8b-832c-dc4fc9b2d445"
title: "ADR-0003: LiteLLM v1.99.4 with explicit max_tokens for the Claude 5.5 models"
type: "ADR"
tags:
  - "adr"
  - "litellm"
  - "llm"
created: "2026-11-11T08:03:17-06:00"
timestamp: "2026-11-11T08:03:17-06:00"
description: "The proxy config pins max_tokens per model and sets drop_params, because Vizzini sends neither and LiteLLM's fallback would truncate reviews."
---

# ADR-0003: LiteLLM v1.99.4 with explicit max_tokens for the Claude 5.5 models

**Status:** Accepted

## Context
- Vizzini (go-openai) sends `response_format: json_object` and no `max_tokens`.
- In LiteLLM v1.99.4, a `json_object` with no schema maps to neither Anthropic `output_format` nor a JSON tool; it only sets `json_mode`. So the JSON contract is held by Vizzini's prompt, `extractJSON`, and its CUE repair loop (Vizzini ADR-0003/0004).
- Anthropic requires `max_tokens`. Where LiteLLM has no model entry, it falls back to `DEFAULT_ANTHROPIC_CHAT_MAX_TOKENS` (4096), which a multi-finding review can exceed.

## Decision
`litellm/config.yaml` sets `max_tokens: 16384` for `claude-sonnet-5-5` and `claude-opus-5-5`, plus `drop_params: true`. The proxy is bound to 127.0.0.1. The Anthropic key reaches it only as a podman secret, and a random master key in `.cache/litellm/master.key` gates it.
