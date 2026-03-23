# Hale Documentation

Hale ports Haskell's web ecosystem to Lean 4 with **maximalist typing** --
encoding correctness, invariants, and protocol guarantees directly in the type system.

**Mantra: Extensive typing/proving with no compromise on performance.**

## Architecture Overview

```
+-----------------------------------------------------------+
|                    User Application                        |
|              (Application : WAI type)                      |
+-----------------------------------------------------------+
|                    Middleware Stack                         |
|    AddHeaders . ForceSSL . Gzip . RequestLogger . ...      |
+-----------------------------------------------------------+
|                    WAI Interface                            |
|     Request -> (Response -> IO Received) -> IO Received    |
+----------+----------+-----------+-------------------------+
|   Warp   | WarpTLS  | WarpQUIC  |  Static File Server     |
| HTTP/1.x |  HTTPS   |  HTTP/3   |  (wai-app-static)       |
+----------+----------+-----------+-------------------------+
|              Transport Layer                                |
|  Socket(.listening) -> Socket(.connected) -> Connection    |
|     TCP (plain)    |   TLS (OpenSSL)    |  QUIC            |
+-----------------------------------------------------------+
|              Operating System (via FFI)                     |
|         POSIX sockets | OpenSSL | kqueue/epoll             |
+-----------------------------------------------------------+
```

## Type Safety Approach

Hale uses three main techniques to encode guarantees:

### 1. Phantom Type Parameters (Zero-Cost State Machines)
```
Socket (state : SocketState)     -- prevents send on unconnected socket
Transport.isSecure               -- TLS/QUIC always secure (proven)
```

### 2. Proof-Carrying Structures (Invariants by Construction)
```
Ratio { num, den, den_pos, coprime }  -- always normalized
Piece { val, no_dot, no_slash }       -- prevents path traversal
Settings { timeout, timeout_pos }     -- always positive timeout
```

### 3. Inductive Types (Protocol Semantics)
```
Response = File | Builder | Stream | Raw   -- 4 HTTP response modes
RequestBodyLength = Chunked | Known n      -- HTTP body encoding
StreamState = idle | open | halfClosed...  -- RFC 9113 compliance
```

## Package Index

> Links marked **API** point to the auto-generated doc-gen4 API reference.
> Links marked **Guide** point to hand-written documentation.

### Core Infrastructure
| Package | Guide | API | Theorems | Description |
|---------|-------|-----|----------|-------------|
| Base | [Guide](Base/README.md) | [API](../Hale/Base.html) | 88 | Foundational types, functors, monads |
| ByteString | [Guide](ByteString/README.md) | [API](../Hale/ByteString.html) | 7 | Byte array operations |
| Network | — | [API](../Hale/Network.html) | 7 | POSIX sockets with phantom state |
| HttpTypes | — | [API](../Hale/HttpTypes.html) | 42 | HTTP methods, status, headers, URI |

### Web Application Interface
| Package | Guide | API | Theorems | Description |
|---------|-------|-----|----------|-------------|
| WAI | [Guide](WAI/README.md) | [API](../Hale/WAI.html) | 17 | Request/Response/Application/Middleware |
| Warp | [Guide](Warp/README.md) | [API](../Hale/Warp.html) | 11 | HTTP/1.x server (156k QPS) |
| WarpTLS | [Guide](TLS/README.md) | [API](../Hale/WarpTLS.html) | — | HTTPS via OpenSSL FFI |
| WarpQUIC | — | [API](../Hale/WarpQUIC.html) | — | HTTP/3 over QUIC |
| WaiExtra | [Guide](WaiExtra/README.md) | [API](../Hale/WaiExtra.html) | 11 | 36 middleware modules |
| WaiAppStatic | [Guide](WaiAppStatic/README.md) | [API](../Hale/WaiAppStatic.html) | 4 | Static file serving |
| WebSockets | [Guide](WebSockets/README.md) | [API](../Hale/WebSockets.html) | 6 | RFC 6455 protocol |

### Protocol Implementations
| Package | Guide | API | Theorems | Description |
|---------|-------|-----|----------|-------------|
| Http2 | — | [API](../Hale/Http2.html) | 10 | HTTP/2 framing (RFC 9113) |
| Http3 | — | [API](../Hale/Http3.html) | 24 | HTTP/3 framing + QPACK |
| QUIC | — | [API](../Hale/QUIC.html) | — | QUIC transport |
| TLS | [Guide](TLS/README.md) | [API](../Hale/TLS.html) | — | OpenSSL FFI wrapper |

### Utilities
| Package | Guide | API | Theorems | Description |
|---------|-------|-----|----------|-------------|
| MimeTypes | — | [API](../Hale/MimeTypes.html) | — | MIME type lookup |
| Cookie | — | [API](../Hale/Cookie.html) | — | HTTP cookie parsing |
| Base64 | — | [API](../Hale/Base64.html) | — | RFC 4648 codec |
| ResourceT | [Guide](ResourceT/README.md) | [API](../Hale/ResourceT.html) | 1 | Resource management monad |
| FastLogger | — | [API](../Hale/FastLogger.html) | — | Buffered thread-safe logging |
| AutoUpdate | — | [API](../Hale/AutoUpdate.html) | — | Periodic cached values |
| TimeManager | — | [API](../Hale/TimeManager.html) | — | Connection timeout management |

## Proven Properties (230+ theorems)

See [Proofs.md](Proofs.md) for a complete catalog of all theorems.
