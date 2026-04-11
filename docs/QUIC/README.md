# QUIC -- QUIC Transport Protocol

**Lean:** `Hale.QUIC` | **Haskell:** `quic`

QUIC transport protocol types per RFC 9000. Connection IDs carry a bounded-length proof (≤ 20 bytes). Stream IDs encode directionality (client/server, bidi/uni) in the type.

## Key Types

| Type | Description |
|------|-------------|
| `ConnectionId` | Variable-length up to 20 bytes (bounded proof) |
| `StreamId` | UInt64 with 2-bit type encoding |
| `TransportParams` | RFC 9000 Section 18 defaults |

## Modules

| Module | Description |
|--------|-------------|
| `Types` | Core protocol types |
| `Config` | Configuration |
| `Connection` | Connection management |
| `Stream` | Stream management |
| `Server` | QUIC server |
| `Client` | QUIC client |

## Files
- `Hale/QUIC/Network/QUIC/Types.lean` -- ConnectionId, StreamId, TransportParams
- `Hale/QUIC/Network/QUIC/Config.lean` -- Configuration
- `Hale/QUIC/Network/QUIC/Connection.lean` -- Connection management
- `Hale/QUIC/Network/QUIC/Stream.lean` -- Stream management
- `Hale/QUIC/Network/QUIC/Server.lean` -- Server
- `Hale/QUIC/Network/QUIC/Client.lean` -- Client
