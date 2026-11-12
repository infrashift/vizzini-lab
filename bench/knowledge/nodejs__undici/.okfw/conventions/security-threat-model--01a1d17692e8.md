---
id: "01a1d176-92e8-771c-9b97-80fcd066c1b6"
title: "Security threat model"
type: "Guideline"
tags:
  - "security"
created: "2026-11-12T14:32:51-06:00"
timestamp: "2026-11-12T14:32:51-06:00"
description: "What undici trusts and does not trust, which classes of bugs it treats as vulnerabilities, and the protocol-level limits the docs document."
x:
  paths: ["lib/core/**/*.js", "lib/dispatcher/client-h1.js", "lib/dispatcher/client-h2.js", "lib/llhttp/**", "lib/web/fetch/**/*.js", "lib/web/websocket/**/*.js", "lib/web/eventsource/**/*.js", "lib/interceptor/decompress.js"]
  source: ["SECURITY.md", "README.md", "docs/docs/api/Fetch.md"]
---

# Security threat model

undici's threat model is aligned with the Node.js threat model. A vulnerability is the ability, through elements undici does not trust, to cause disclosure or loss of integrity/confidentiality of data protected by correct API use, or unavailability of the runtime "including the unbounded degradation of its performance".

## Untrusted input

undici does **not** trust data from the remote end that it parses or transforms: response status lines and headers, response bodies when undici processes them (chunked decoding, content-encoding), WebSocket frames, and Server-Sent Events data. It also owns TLS certificate validation done on the application's behalf. Code touching these paths is security-sensitive.

## Trusted input

undici **trusts** application code and its configuration, options and callbacks (including which body-consuming APIs it calls), the OS and network stack, the Node.js runtime, installed dependencies, DNS results, the network environment, and any configured proxy. Prototype pollution through application-supplied input, malicious third-party modules, and misconfiguration (for example disabling TLS verification) are explicitly not undici vulnerabilities.

## Bug classes treated as vulnerabilities

- Improper certificate validation (CWE-295).
- Response parsing bugs in headers or transfer encoding that enable response smuggling or desynchronization (CWE-444).
- Requests interpreted differently by undici and an upstream server (request smuggling, CWE-444).
- **CRLF injection**: untrusted input passed to undici APIs, "such as header values or URLs", that can inject headers or corrupt the request stream (CWE-93).
- Untrusted data triggering actions other than those documented, such as "polluting globals, causing an unrecoverable crash", or other unexpected side effects.

DoS reports must show asymmetric resource consumption through a public, documented API used correctly.

## Documented limits and caveats

- At most **5** `Content-Encoding` layers per response; more rejects the fetch, "to prevent resource exhaustion attacks".
- `body.formData()` buffers and parses the whole body, and must only be called on responses from trusted servers.
- Large response payloads on outbound connections are the application's responsibility to limit.
- HTTP/1.1 keep-alive responses carry no request identifier. undici avoids immediate reuse of non-pipelined connections when callers are waiting; applications needing isolation use `pipelining: 0`, `maxRequestsPerClient: 1`, or HTTP/2.
- Pipelining is used only with a `pipelining` factor above `1` and should only be enabled for trusted servers.
- undici intentionally does not implement CORS and removes the Fetch spec's forbidden-header restrictions to give users control.

Fixes for reported vulnerabilities are prepared privately and coordinated with Node.js releases rather than committed publicly first.
