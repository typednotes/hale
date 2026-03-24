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
|  Request -> (Response -> IO Received) -> AppM .pending .sent|
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

## Leveraging Lean 4's Dependent Type System

Lean 4 is not Haskell with nicer syntax -- it is a full dependently-typed proof
assistant that also happens to compile to efficient native code. Hale exploits
this to turn protocol specifications, resource lifecycles, and algebraic
contracts into **compile-time obligations** that are verified by the kernel and
then **erased at runtime** (zero cost). Below are the four core techniques.

### 1. Phantom Type Parameters -- Zero-Cost State Machines

A phantom parameter encodes the resource's lifecycle state in the type.
Functions that require a particular state accept only that constructor;
transitions return the new state. The parameter is fully erased at runtime
(same machine code as an untyped handle), yet the compiler rejects every
protocol violation.

```lean
structure Socket (state : SocketState) where    -- phantom parameter, erased at runtime
  raw : RawSocket

def bind   (s : Socket .fresh)     : IO (Socket .bound)     -- fresh  --> bound
def listen (s : Socket .bound)     : IO (Socket .listening)  -- bound  --> listening
def accept (s : Socket .listening) : IO (Socket .connected)  -- listen --> connected
def send   (s : Socket .connected) : IO Nat                  -- only connected
def close  (s : Socket state)                                -- any non-closed state
           (h : state ≠ .closed := by decide)                -- PROOF: not already closed
           : IO (Socket .closed)                             -- returns closed token

-- Compile-time errors (no runtime check needed):
-- send freshSocket       -- type error: .fresh ≠ .connected
-- accept boundSocket     -- type error: .bound ≠ .listening
-- close closedSocket     -- type error: cannot prove .closed ≠ .closed
```

### 2. Proof-Carrying Structures -- Invariants by Construction

Lean 4 erases proof terms at compile time, so proof fields in structures are
**literally free** -- same `sizeof`, same codegen. The invariant is guaranteed
the moment the value exists; no runtime validation is ever needed.

```lean
structure Ratio where
  num : Int
  den : Nat
  den_pos : den > 0          -- erased: denominator always positive
  coprime : Nat.Coprime num.natAbs den  -- erased: always in lowest terms

structure Settings where
  settingsTimeout : Nat := 30
  settingsTimeoutPos : settingsTimeout > 0 := by omega  -- erased: never zero
```

### 3. Indexed Monads -- Exactly-Once Protocol Enforcement

Where Haskell's WAI relies on a gentleman's agreement ("call `respond` exactly
once"), Lean 4 enforces it at the type level via an **indexed monad** whose
pre/post state parameters track the response lifecycle. The constructor is
`private`, so the only way to produce `AppM .pending .sent ResponseReceived`
is through the provided combinators -- fabrication is a type error.

```lean
structure AppM (pre post : ResponseState) (α : Type) where
  private mk ::          -- can't fabricate: constructor is private
  run : IO α

def AppM.respond         -- the ONLY transition from .pending to .sent
  (callback : Response → IO ResponseReceived)
  (resp : Response)
  : AppM .pending .sent ResponseReceived

-- Double-respond is a compile-time error:
-- After the first respond, state is .sent.
-- A second respond would need AppM .sent .sent, which does not exist.
```

### 4. Inductive Types -- Protocol Semantics as Data

Sum types encode every valid protocol state or message shape. Pattern matching
is exhaustive, so the compiler verifies that every case is handled.

```lean
inductive Response where
  | responseFile    ...   -- sendfile(2)
  | responseBuilder ...   -- in-memory ByteArray
  | responseStream  ...   -- chunked streaming
  | responseRaw     ...   -- raw socket (WebSocket upgrade)

inductive RequestBodyLength where
  | chunkedBody           -- Transfer-Encoding: chunked
  | knownLength (n : Nat) -- Content-Length: n
```

### Design Principle: Proofs on Objects, Not Wrapper Types

Invariants belong **inside** the original type, not in a separate wrapper.
Proof fields are zero-cost (erased), so there is never a reason to create
`ValidSettings` alongside `Settings` -- just put the proof in `Settings`.

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
