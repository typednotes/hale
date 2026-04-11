# Http3 -- HTTP/3 Protocol

**Lean:** `Hale.Http3` | **Haskell:** `http3`

HTTP/3 framing and QPACK header compression per RFC 9114. Uses QUIC variable-length integer encoding (RFC 9000 Section 16) with proven roundtrip properties.

## Key Types

| Type | Description |
|------|-------------|
| `FrameType` | Inductive of HTTP/3 frame types (DATA, HEADERS, SETTINGS, GOAWAY, etc.) |

## Proven Properties
- `decodeVarInt (encodeVarInt n) = some n` (roundtrip)

## Modules

| Module | Description |
|--------|-------------|
| `Frame` | Frame types + varint encoding/decoding |
| `Error` | HTTP/3 error codes |
| `QPACK.Table` | QPACK static/dynamic tables |
| `QPACK.Encode` | QPACK header compression |
| `QPACK.Decode` | QPACK header decompression |
| `Server` | HTTP/3 server |

## Files
- `Hale/Http3/Network/HTTP3/Frame.lean` -- Frame types, varint codec
- `Hale/Http3/Network/HTTP3/Error.lean` -- Error codes
- `Hale/Http3/Network/HTTP3/QPACK/Table.lean` -- QPACK tables
- `Hale/Http3/Network/HTTP3/QPACK/Encode.lean` -- QPACK encoding
- `Hale/Http3/Network/HTTP3/QPACK/Decode.lean` -- QPACK decoding
- `Hale/Http3/Network/HTTP3/Server.lean` -- Server
