# Http2 -- HTTP/2 Protocol

**Lean:** `Hale.Http2` | **Haskell:** `http2`

HTTP/2 framing, HPACK header compression, flow control, and server implementation per RFC 9113. Stream IDs carry a 31-bit bound proof. Settings carry RFC 9113 value constraint proofs.

## Key Types

| Type | Description |
|------|-------------|
| `StreamId` | 31-bit bounded stream identifier |
| `FrameType` | Inductive of all RFC 9113 frame types |
| `ErrorCode` | Connection/stream error codes |
| `Settings` | RFC 9113 settings with proof-carrying value constraints |
| `ConnectionError` | Error code + message for GOAWAY |
| `StreamError` | Stream ID + error code + message for RST_STREAM |

## Modules

| Module | Description |
|--------|-------------|
| `Frame.Types` | Frame type definitions and flags |
| `Frame.Encode` | Binary frame serialization |
| `Frame.Decode` | Binary frame deserialization |
| `HPACK.Table` | Dynamic/static header table |
| `HPACK.Huffman` | Huffman coding |
| `HPACK.Encode` | HPACK header compression |
| `HPACK.Decode` | HPACK header decompression |
| `FlowControl` | Window-based flow control |
| `Stream` | Stream lifecycle management |
| `Server` | HTTP/2 server implementation |

## Files
- `Hale/Http2/Network/HTTP2/Types.lean` -- Core types
- `Hale/Http2/Network/HTTP2/Frame/Types.lean` -- Frame definitions
- `Hale/Http2/Network/HTTP2/Frame/Encode.lean` -- Frame encoding
- `Hale/Http2/Network/HTTP2/Frame/Decode.lean` -- Frame decoding
- `Hale/Http2/Network/HTTP2/HPACK/Table.lean` -- HPACK tables
- `Hale/Http2/Network/HTTP2/HPACK/Huffman.lean` -- Huffman coding
- `Hale/Http2/Network/HTTP2/HPACK/Encode.lean` -- HPACK encoding
- `Hale/Http2/Network/HTTP2/HPACK/Decode.lean` -- HPACK decoding
- `Hale/Http2/Network/HTTP2/FlowControl.lean` -- Flow control
- `Hale/Http2/Network/HTTP2/Stream.lean` -- Stream management
- `Hale/Http2/Network/HTTP2/Server.lean` -- Server
