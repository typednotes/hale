# Warp -- High-Performance HTTP Server

**Lean:** `Hale.Warp` | **Haskell:** `warp`

> **API Reference:** [Hale.Warp](../../Hale/Warp.html) | [Types](../../Hale/Warp/Network/Wai/Handler/Warp/Types.html) | [Settings](../../Hale/Warp/Network/Wai/Handler/Warp/Settings.html) | [Request](../../Hale/Warp/Network/Wai/Handler/Warp/Request.html) | [Response](../../Hale/Warp/Network/Wai/Handler/Warp/Response.html) | [Run](../../Hale/Warp/Network/Wai/Handler/Warp/Run.html)

A fast HTTP/1.x server achieving **156,000+ requests/sec** with keep-alive.

## Connection Lifecycle

```
  runSettings(port, app)
         |
         v
  +--------------------+
  | listenTCP(port)    |
  | Socket(.listening) |
  +--------+-----------+
           |
     acceptLoop <------------------------------------+
           |                                          |
           v                                          |
  +--------------------+                              |
  | Socket.accept      |                              |
  | -> (.connected)    |                              |
  +--------+-----------+                              |
           |                                          |
     forkIO (green thread)                            |
           |                                          |
           v                                          |
  +------------------------+                          |
  | runConnection          |                          |
  |  +------------------+  |                          |
  |  | parseRequest     |  |                          |
  |  | -> WAI.Request   |  |                          |
  |  +--------+---------+  |                          |
  |           |             |                          |
  |  +--------v---------+  |                          |
  |  | app(req, respond) |  |                          |
  |  | -> Response       |  |                          |
  |  +--------+---------+  |                          |
  |           |             |                          |
  |  +--------v---------+  |                          |
  |  | sendResponse     |  |                          |
  |  +--------+---------+  |                          |
  |           |             |                          |
  |  +--------v---------+  |                          |
  |  | connAction?      |  |                          |
  |  | keepAlive/close  |  |                          |
  |  +--------+---------+  |                          |
  |           |             |                          |
  |     +-----+-----+      |                          |
  |     | keepAlive  |      |                          |
  |     | -> loop ---+------+-- (back to parseRequest) |
  |     |            |      |                          |
  |     | close      |      |                          |
  |     | -> cleanup |      |                          |
  |     +------------+      |                          |
  +-------------------------+                          |
                                                       |
           <-------------------------------------------+
```

## Transport Abstraction

```lean
inductive Transport where
  | tcp                                         -- plain channel
  | tls (major minor : Nat) (alpn : Option String) (cipher : UInt16)
  | quic (alpn : Option String) (cipher : UInt16)
```

**Security proofs:**
| Theorem | Statement |
|---------|-----------|
| `tcp_not_secure` | `Transport.isSecure .tcp = false` |
| `tls_is_secure` | `Transport.isSecure (.tls ..) = true` |
| `quic_is_secure` | `Transport.isSecure (.quic ..) = true` |

## Keep-Alive State Machine

```
  +---------------+    Connection: close    +-----------+
  |   HTTP/1.1    | ----------------------> |   CLOSE   |
  | (keep-alive   |                         +-----------+
  |  by default)  |    no Connection hdr         ^
  |               | ----------------------> keepAlive
  +---------------+                              |
                                                 |
  +---------------+    Connection: keep-alive    |
  |   HTTP/1.0    | ----------------------> keepAlive
  | (close by     |
  |  default)     |    no Connection hdr    +-----------+
  |               | ----------------------> |   CLOSE   |
  +---------------+                         +-----------+
```

**Proven semantics:**
- `connAction_http10_default`: HTTP/1.0 without Connection header -> close
- `connAction_http11_default`: HTTP/1.1 without Connection header -> keep-alive

## How Lean 4's Dependent Types Secure the Warp Server

Warp is where every dependent-type technique in Hale converges: phantom
state machines, proof-carrying structures, and indexed monads all
cooperate to make entire classes of server bugs **unrepresentable**.

### Socket State Machine (phantom type parameter)
```lean
structure Socket (state : SocketState) where   -- phantom parameter, erased at runtime
  raw : RawSocket

-- Every function declares its pre/post state:
listenTCP  : ... -> IO (Socket .listening)
accept     : Socket .listening -> IO (Socket .connected × SockAddr)
send       : Socket .connected -> ByteArray -> IO Nat
close      : Socket state -> (state ≠ .closed := by decide) -> IO (Socket .closed)

-- All of these are compile-time errors (not runtime, not asserts):
-- accept freshSocket       -- .fresh ≠ .listening
-- send listeningSocket     -- .listening ≠ .connected
-- close closedSocket       -- cannot prove .closed ≠ .closed
```

### Exactly-Once Response (indexed monad)

The server provides a `respond` callback and calls `(app req respond).run`.
The `AppM .pending .sent` return type guarantees that by the time `.run`
executes, the application has called `respond` exactly once:
```lean
-- In runConnection (the trust boundary):
let _received ← (app req fun resp => sendResponse sock settings req resp).run
```

### Settings with Proof Fields (zero-cost invariants)
```lean
structure Settings where
  settingsPort : UInt16
  settingsTimeout : Nat := 30
  settingsBacklog : Nat := 128
  settingsTimeoutPos : settingsTimeout > 0 := by omega   -- erased at runtime
  settingsBacklogPos : settingsBacklog > 0 := by omega   -- erased at runtime
```

The proof fields are **erased at compile time** (zero cost, same `sizeof`).
It is impossible to construct a `Settings` with a zero timeout or zero
backlog -- the `by omega` obligation cannot be discharged for `0 > 0`.

### InvalidRequest (Exhaustive Error Model)
```lean
inductive InvalidRequest where
  | notEnoughLines | badFirstLine | nonHttp | incompleteHeaders
  | connectionClosedByPeer | overLargeHeader | badProxyHeader
  | payloadTooLarge | requestHeaderFieldsTooLarge
```

## Full Theorem List (11)

### Transport Security (3, in `Types.lean`)
| Theorem | Statement |
|---------|-----------|
| `tcp_not_secure` | TCP is not encrypted |
| `tls_is_secure` | TLS is always encrypted |
| `quic_is_secure` | QUIC is always encrypted |

### Keep-Alive Semantics (2, in `Run.lean`)
| Theorem | Statement |
|---------|-----------|
| `connAction_http10_default` | HTTP/1.0 defaults to close |
| `connAction_http11_default` | HTTP/1.1 defaults to keep-alive |

### HTTP Version Parsing (5, in `Request.lean`)
| Theorem | Statement |
|---------|-----------|
| `parseHttpVersion_http11` | Parsing "HTTP/1.1" yields http11 |
| `parseHttpVersion_http10` | Parsing "HTTP/1.0" yields http10 |
| `parseHttpVersion_http09` | Parsing "HTTP/0.9" yields http09 |
| `parseHttpVersion_http20` | Parsing "HTTP/2.0" yields http20 |
| `parseRequestLine_empty` | Empty string yields none |

### Settings Validity (1, in `Settings.lean`)
| Theorem | Statement |
|---------|-----------|
| `defaultSettings_valid` | Default timeout > 0 and backlog > 0 |

## Performance
- **156k QPS** (wrk, 4 threads, 50 connections, keep-alive)
- **30k QPS** (ab, 100 connections, no keep-alive)
- Green threads via `forkIO` (scheduler-managed, not OS threads)
- RecvBuffer in C (CRLF scanning entirely in native code)

## Files (17 modules)
| Module | Purpose |
|--------|---------|
| `Types` | Connection, Transport, Source, InvalidRequest |
| `Settings` | Server configuration with proof fields |
| `Request` | HTTP request parsing |
| `Response` | HTTP response rendering |
| `Run` | Accept loop + keep-alive state machine |
| `Date` | Cached HTTP date header (AutoUpdate) |
| `Header` | O(1) indexed header lookup (13 headers) |
| `Counter` | Atomic connection counter |
| `ReadInt` / `PackInt` | Fast integer parsing/rendering |
| `IO`, `HashMap`, `Conduit`, `SendFile` | Internal utilities |
| `WithApplication` | Test helper (ephemeral port) |
| `Internal` | Re-exports for downstream (warp-tls, warp-quic) |
