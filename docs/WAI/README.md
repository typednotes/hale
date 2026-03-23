# WAI -- Web Application Interface

**Lean:** `Hale.WAI` | **Haskell:** `wai`

> **API Reference:** [Hale.WAI](../../Hale/WAI.html) | [Network.Wai.Internal](../../Hale/WAI/Network/Wai/Internal.html) | [Network.Wai](../../Hale/WAI/Network/Wai.html)

The core abstraction for Hale's HTTP ecosystem. Every web application,
middleware, and server speaks WAI.

## Request Lifecycle

```
   Client HTTP Request
         |
         v
  +--------------+     +------------------+
  | Socket.accept |---->| parseRequest     |
  |  (.listening) |     | (headers, body)  |
  +--------------+     +--------+---------+
                                |
                     WAI Request struct
                                |
         +----------------------+----------------------+
         |                      |                      |
         v                      v                      v
  +--------------+     +--------------+     +--------------+
  |  Middleware   |---->|  Middleware   |---->|  Application |
  |  (ForceSSL)  |     |  (Logger)    |     |  (user code) |
  +--------------+     +--------------+     +------+-------+
                                                    |
                                             Response (inductive)
                                                    |
                       +----------------------------+----------+
                       |              |              |          |
                       v              v              v          v
                  responseFile   responseBuilder  responseStream  responseRaw
                  (sendfile)    (in-memory)      (chunked)       (WebSocket)
                       |              |              |          |
                       +--------------+--------------+----------+
                                       |
                                sendResponse
                                       |
                                       v
                              Socket.connected
```

## Core Types

### Application (CPS Pattern)
```lean
abbrev Application :=
  Request -> (Response -> IO ResponseReceived) -> IO ResponseReceived
```
The continuation-passing style ensures exactly one response per request.
`ResponseReceived` is an opaque token -- the only way to obtain it is
by calling the `respond` callback.

### Middleware (Monoid under Composition)
```lean
abbrev Middleware := Application -> Application
```

**Proven algebraic properties:**
| Theorem | Statement |
|---------|-----------|
| `idMiddleware_comp_left` | `id . m = m` |
| `idMiddleware_comp_right` | `m . id = m` |
| `modifyRequest_id` | `modifyRequest id = id` |
| `modifyResponse_id` | `modifyResponse id = id` |
| `ifRequest_false` | `ifRequest (fun _ => false) m = id` |

### Response (4 Delivery Modes)
```lean
inductive Response where
  | responseFile    (status headers path part)   -- sendfile(2)
  | responseBuilder (status headers body)        -- in-memory ByteArray
  | responseStream  (status headers body)        -- chunked streaming
  | responseRaw     (rawAction fallback)         -- raw socket (WebSocket)
```

**Proven accessor laws (12 theorems):**
- `status_responseBuilder s h b = s` (and for File, Stream)
- `headers_responseBuilder s h b = h` (and for File)
- `mapResponseHeaders id r = r` (per constructor: builder, file, stream)
- `mapResponseStatus id r = r` (per constructor: builder, file, stream)

### RequestBodyLength (Dependent Encoding)
```lean
inductive RequestBodyLength where
  | chunkedBody                    -- Transfer-Encoding: chunked
  | knownLength (bytes : Nat)      -- Content-Length: N
```

## Full Theorem List (17)

### Response Accessor Laws (11, in `Internal.lean`)
| Theorem | Source |
|---------|--------|
| `status_responseBuilder` | `Wai.Internal` |
| `status_responseFile` | `Wai.Internal` |
| `status_responseStream` | `Wai.Internal` |
| `headers_responseBuilder` | `Wai.Internal` |
| `headers_responseFile` | `Wai.Internal` |
| `mapResponseHeaders_id_responseBuilder` | `Wai.Internal` |
| `mapResponseHeaders_id_responseFile` | `Wai.Internal` |
| `mapResponseHeaders_id_responseStream` | `Wai.Internal` |
| `mapResponseStatus_id_responseBuilder` | `Wai.Internal` |
| `mapResponseStatus_id_responseFile` | `Wai.Internal` |
| `mapResponseStatus_id_responseStream` | `Wai.Internal` |

### Middleware Algebra (5, in `Wai.lean`)
| Theorem | Source |
|---------|--------|
| `idMiddleware_comp_left` | `Wai` |
| `idMiddleware_comp_right` | `Wai` |
| `modifyRequest_id` | `Wai` |
| `modifyResponse_id` | `Wai` |
| `ifRequest_false` | `Wai` |

### Axiom-Dependent Property
- **Response linearity:** The `respond` callback must be invoked exactly once.
  `ResponseReceived` proves invocation happened but cannot prevent double
  invocation without linear types. Documented as an axiom-dependent contract
  matching Haskell WAI.

## Files
- `Hale/WAI/Network/Wai/Internal.lean` -- Core types + 11 accessor theorems
- `Hale/WAI/Network/Wai.lean` -- Public API + 5 middleware algebra theorems
