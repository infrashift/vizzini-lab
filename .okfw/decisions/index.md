# decisions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [ADR-0001: A dedicated UAT repo that builds every tool from a pinned SHA](adr-0001-a-dedicated-uat-repo-that-builds-every-tool-from-a-pinned-sha--01a1caeb8cd0.md) - The UAT lives in its own repository and builds Vizzini, mrman, garmr and okfw from pinned commits, never from installed binaries or working trees.
* [ADR-0002: The mrman submit grant stays a human step](adr-0002-the-mrman-submit-grant-stays-a-human-step--01a1caeb8ce7.md) - The UAT never fakes a terminal to grant mrman's --auto submit; it pauses and a person runs the TUI with --auto.
* [ADR-0003: LiteLLM v1.99.4 with explicit max_tokens for the Claude 5.5 models](adr-0003-litellm-v1-99-4-with-explicit-max-tokens-for-the-claude-5-5-models--01a1caeb8cfe.md) - The proxy config pins max_tokens per model and sets drop_params, because Vizzini sends neither and LiteLLM's fallback would truncate reviews.

