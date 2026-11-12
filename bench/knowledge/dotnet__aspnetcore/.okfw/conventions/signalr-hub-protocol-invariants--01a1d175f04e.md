---
id: "01a1d175-f04e-731a-b1c3-0f2335238864"
title: "SignalR hub protocol invariants"
type: "Guideline"
tags:
  - "signalr"
  - "protocol"
  - "compatibility"
created: "2026-11-12T14:32:09-06:00"
timestamp: "2026-11-12T14:32:09-06:00"
description: "Normative MUST rules from the SignalR hub protocol specification that client and server implementations must keep."
x:
  paths: ["src/SignalR/common/SignalR.Common/**", "src/SignalR/common/Protocols.Json/**", "src/SignalR/common/Protocols.MessagePack/**", "src/SignalR/common/Protocols.NewtonsoftJson/**", "src/SignalR/clients/**", "src/SignalR/server/**"]
  source: ["src/SignalR/docs/specs/HubProtocol.md"]
---

# SignalR hub protocol invariants

`src/SignalR/docs/specs/HubProtocol.md` defines the wire protocol that every SignalR client and server implementation speaks. A code change to a protocol implementation should keep these rules.

## Handshake and framing

- The client's first message must be a `HandshakeRequest`. The handshake request and response are **always** JSON, whatever the message format.
- If the server does not support the requested protocol, or the first message is not a `HandshakeRequest`, the server must close the connection.
- The handshake `version` must always be 1, for both JSON and MessagePack.
- The handshake messages, and all JSON messages, are terminated by the record separator `0x1E`.
- Only one format is used for the whole connection.
- The protocol assumes reliable, in-order delivery and provides no retransmission or reordering.

## Invocations

- An `Invocation`'s `Target` names one specific method. Overloading is not permitted, and `Target` is case-sensitive.
- An invocation without an Invocation ID is non-blocking, and the callee **must not** send any response to it.
- Callees may limit Invocation ID length and terminate the connection when an ID is too long.
- Messages may carry headers, which implementations must be able to accept and ignore.

## Streaming, completion and cancellation

- A streaming callee **MUST** send each result in its own `StreamItem` and finish with a `Completion`. A single-result callee **MUST NOT** send `StreamItem` messages and returns its result in the `Completion`.
- A mismatch (an `Invocation` for a streaming method, or a `StreamInvocation` for a single-result method) **MUST** be completed with an error `Completion`.
- An invocation is complete only when its `Completion` arrives. Any later message with the same ID is a protocol error, and the connection may be terminated.
- On `CancelInvocation`, the callee need not abort the method but **MUST** still send a `Completion`. A cancel for an unknown ID **SHOULD** be ignored.
- Upload stream IDs must be unique per caller.
- An error `Completion` ends the invocation, but results received earlier are still dispatched before the error is surfaced.
- On reconnect, each side sends a `Sequence` message first, naming the sequence ID it will resume from. `Ack` messages acknowledge receipt up to a sequence ID. Duplicate messages are possible and "should be ignored."
