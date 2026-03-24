# hale

A port of Haskell's web ecosystem to Lean 4 with a maximalist approach to typing.

## Overview

`hale` ports 40 Haskell libraries (223 Lean modules) covering everything from foundational types to a full HTTP/1-2-3 web server stack. Unlike a minimal port, types encode correctness proofs, invariants, and guarantees wherever feasible:

- **Correctness:** Lawful typeclasses (`LawfulBifunctor`, `LawfulCategory`, `LawfulTraversable`) with verified laws
- **Invariants:** `Ratio` enforces positive denominator and coprimality in its type; `NonEmpty` guarantees `length >= 1`
- **Proofs:** `clamp` returns `{y : a // lo <= y && y <= hi}`; `Fixed.add_exact` proves addition preserves precision
- **257 compile-time verified theorems** across 52 files, checked by the Lean 4 kernel

## Quick Start

Add to your `lakefile.toml`:

```toml
[[require]]
name = "hale"
git = "<repository-url>"
rev = "main"
```

Then import:

```lean
import Hale
open Hale
```

## Ported Libraries

### Core Infrastructure

| Lean Package | Haskell Package | Description |
|---|---|---|
| `Hale.Base` | [base](https://hackage.haskell.org/package/base) | Foundational types, functors, monads, concurrency |
| `Hale.ByteString` | [bytestring](https://hackage.haskell.org/package/bytestring) | Byte array operations (strict, lazy, builder) |
| `Hale.Word8` | [word8](https://hackage.haskell.org/package/word8) | Word8 character classification |
| `Hale.Time` | [time](https://hackage.haskell.org/package/time) | Clock and time types |
| `Hale.STM` | [stm](https://hackage.haskell.org/package/stm) | Software transactional memory |
| `Hale.DataDefault` | [data-default](https://hackage.haskell.org/package/data-default) | Default values |
| `Hale.ResourceT` | [resourcet](https://hackage.haskell.org/package/resourcet) | Resource management monad |
| `Hale.UnliftIO` | [unliftio-core](https://hackage.haskell.org/package/unliftio-core) | MonadUnliftIO |

### Networking

| Lean Package | Haskell Package | Description |
|---|---|---|
| `Hale.Network` | [network](https://hackage.haskell.org/package/network) | POSIX sockets with phantom state |
| `Hale.IpRoute` | [iproute](https://hackage.haskell.org/package/iproute) | IP address types |
| `Hale.Recv` | [recv](https://hackage.haskell.org/package/recv) | Socket receive |
| `Hale.StreamingCommons` | [streaming-commons](https://hackage.haskell.org/package/streaming-commons) | Streaming network utilities |
| `Hale.SimpleSendfile` | [simple-sendfile](https://hackage.haskell.org/package/simple-sendfile) | sendfile(2) wrapper |
| `Hale.TLS` | [tls](https://hackage.haskell.org/package/tls) | TLS via OpenSSL FFI |

### HTTP

| Lean Package | Haskell Package | Description |
|---|---|---|
| `Hale.HttpTypes` | [http-types](https://hackage.haskell.org/package/http-types) | HTTP methods, status, headers, URI |
| `Hale.HttpDate` | [http-date](https://hackage.haskell.org/package/http-date) | HTTP date parsing |
| `Hale.Http2` | [http2](https://hackage.haskell.org/package/http2) | HTTP/2 framing, HPACK, server |
| `Hale.Http3` | [http3](https://hackage.haskell.org/package/http3) | HTTP/3 framing, QPACK |
| `Hale.QUIC` | [quic](https://hackage.haskell.org/package/quic) | QUIC transport |
| `Hale.BsbHttpChunked` | [bsb-http-chunked](https://hackage.haskell.org/package/bsb-http-chunked) | Chunked transfer encoding |

### Web Application Interface

| Lean Package | Haskell Package | Description |
|---|---|---|
| `Hale.WAI` | [wai](https://hackage.haskell.org/package/wai) | Request/Response/Application/Middleware |
| `Hale.Warp` | [warp](https://hackage.haskell.org/package/warp) | HTTP/1.x server |
| `Hale.WarpTLS` | [warp-tls](https://hackage.haskell.org/package/warp-tls) | HTTPS via OpenSSL |
| `Hale.WarpQUIC` | [warp-quic](https://hackage.haskell.org/package/warp-quic) | HTTP/3 over QUIC |
| `Hale.WaiExtra` | [wai-extra](https://hackage.haskell.org/package/wai-extra) | 36 middleware modules |
| `Hale.WaiAppStatic` | [wai-app-static](https://hackage.haskell.org/package/wai-app-static) | Static file serving |
| `Hale.WaiHttp2Extra` | [wai-http2-extra](https://hackage.haskell.org/package/wai-http2-extra) | HTTP/2 server push |
| `Hale.WaiWebSockets` | [wai-websockets](https://hackage.haskell.org/package/wai-websockets) | WebSocket WAI handler |
| `Hale.WebSockets` | [websockets](https://hackage.haskell.org/package/websockets) | RFC 6455 WebSocket protocol |

### Utilities

| Lean Package | Haskell Package | Description |
|---|---|---|
| `Hale.CaseInsensitive` | [case-insensitive](https://hackage.haskell.org/package/case-insensitive) | Case-insensitive strings |
| `Hale.Vault` | [vault](https://hackage.haskell.org/package/vault) | Type-safe heterogeneous storage |
| `Hale.AutoUpdate` | [auto-update](https://hackage.haskell.org/package/auto-update) | Periodic cached values |
| `Hale.TimeManager` | [time-manager](https://hackage.haskell.org/package/time-manager) | Connection timeout management |
| `Hale.Cookie` | [cookie](https://hackage.haskell.org/package/cookie) | HTTP cookie parsing |
| `Hale.MimeTypes` | [mime-types](https://hackage.haskell.org/package/mime-types) | MIME type lookup |
| `Hale.Base64` | [base64-bytestring](https://hackage.haskell.org/package/base64-bytestring) | RFC 4648 codec |
| `Hale.FastLogger` | [fast-logger](https://hackage.haskell.org/package/fast-logger) | Buffered thread-safe logging |
| `Hale.WaiLogger` | [wai-logger](https://hackage.haskell.org/package/wai-logger) | WAI request logging |
| `Hale.UnixCompat` | [unix-compat](https://hackage.haskell.org/package/unix-compat) | POSIX compatibility |
| `Hale.AnsiTerminal` | [ansi-terminal](https://hackage.haskell.org/package/ansi-terminal) | Terminal ANSI codes |
| `Hale.PSQueues` | [psqueues](https://hackage.haskell.org/package/psqueues) | Priority search queues |

## Typing Philosophy

Lean 4 is a dependently-typed proof assistant that compiles to efficient native
code. Hale leverages this to turn protocol specs, resource lifecycles, and
algebraic laws into **compile-time obligations** -- verified by the kernel,
then **erased at runtime** (zero overhead).

- **Phantom state machines:** `Socket (state : SocketState)` makes it a type
  error to `send` on an unconnected socket or `close` an already-closed one
  (proof obligation: `state != .closed`, discharged by `decide`)
- **Indexed monads:** `AppM .pending .sent ResponseReceived` enforces that
  a WAI application calls `respond` exactly once -- double-respond is a
  compile-time error, not a runtime crash
- **Proof-carrying structures:** `Ratio` carries `den_pos` and `coprime`
  proofs; `Settings` carries `timeout_pos` -- all erased at runtime (zero cost)
- **Algebraic laws:** 257 theorems (`bimap_id`, `bind_assoc`, `map_id`,
  `connAction_http11_default`, ...) verified by the Lean kernel

## Documentation

- [docs/](docs/README.md) -- Per-module documentation with API mappings and examples
- [docs/Proofs.md](docs/Proofs.md) -- Complete catalog of all 257 theorems
- [Tests/](Tests/) -- 82 Lean test files
- [Tests/cross-check/](Tests/cross-check/) -- 9 Haskell cross-verification scripts

## Build & Test

```bash
nix-shell                               # Nix users: enter shell with OpenSSL + pkg-config
lake build                              # Build the library
lake exe hale                           # Run smoke tests
lake build hale-tests && lake exe hale-tests  # Run test suite
bash tests/cross-check/run-all.sh       # Cross-check with Haskell (requires GHC)
```

Requires OpenSSL headers for TLS support. On non-Nix systems, ensure `pkg-config openssl` works (e.g., `brew install openssl pkg-config` on macOS, `apt install libssl-dev pkg-config` on Debian/Ubuntu).

## License

See [LICENSE](LICENSE) for details.
