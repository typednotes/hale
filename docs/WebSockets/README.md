# WebSockets -- RFC 6455 Protocol

**Lean:** `Hale.WebSockets` | **Haskell:** `websockets`

> **API Reference:** [Hale.WebSockets](../../Hale/WebSockets.html) | [Types](../../Hale/WebSockets/Network/WebSockets/Types.html) | [Frame](../../Hale/WebSockets/Network/WebSockets/Frame.html) | [Handshake](../../Hale/WebSockets/Network/WebSockets/Handshake.html) | [Connection](../../Hale/WebSockets/Network/WebSockets/Connection.html) | [WAI Bridge](../../Hale/WaiWebSockets/Network/Wai/Handler/WebSockets.html)

Native WebSocket framing implementation with typed state machine.

## WebSocket Upgrade Flow

```
  HTTP GET /chat
  Upgrade: websocket
  Connection: Upgrade
  Sec-WebSocket-Key: dGhlIHNhbXBsZQ==
  Sec-WebSocket-Version: 13
         |
         v
  +----------------------------+
  | isValidHandshake(headers)? |
  |   Check Upgrade header     |
  +------+-------+-------------+
         |yes    |no
         v       v
  +----------+  +--------------+
  | Handshake|  | Normal HTTP  |
  | SHA-1+B64|  | Application  |
  +----+-----+  +--------------+
       |
       v HTTP 101 Switching Protocols
  +----------------------------+
  |  PendingConnection         |
  |  state = .pending          |
  +------------+---------------+
               | acceptIO
               v
  +----------------------------+
  |  Connection                |
  |  state = .open_            |
  |                            |
  |  sendText / sendBinary     |
  |  receiveData / receiveText |
  |  sendPing (auto-pong)      |
  +------------+---------------+
               | sendClose
               v
  +----------------------------+
  |  state = .closing          |
  |  (awaiting close frame)    |
  +------------+---------------+
               | receive close
               v
  +----------------------------+
  |  state = .closed           |
  +----------------------------+
```

## Frame Format (RFC 6455 section 5.2)

```
  0                   1                   2                   3
  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
 +-+-+-+-+-------+-+-------------+-------------------------------+
 |F|R|R|R| opcode|M| Payload len |   Extended payload length     |
 |I|S|S|S|  (4)  |A|     (7)     |          (16/64)              |
 |N|V|V|V|       |S|             |  (if payload len==126/127)    |
 | |1|2|3|       |K|             |                               |
 +-+-+-+-+-------+-+-------------+-------------------------------+
 | Masking-key (if MASK=1)       |         Payload Data          |
 +-------------------------------+-------------------------------+
```

## Dependent Types

### Opcode (Bounded to 4 bits)
```lean
inductive Opcode where
  | continuation | text | binary | close | ping | pong
  | reserved (val : Fin 16)   -- Fin 16 bounds to [0, 15]
```

The `reserved` constructor uses `Fin 16` to statically guarantee all
opcode values fit in 4 bits, matching the wire format.

### Connection State Machine
```lean
inductive ConnectionState where
  | pending   -- handshake not completed
  | open_     -- data transfer active
  | closing   -- close frame sent
  | closed    -- terminated
```

### CloseCode (Typed Status Codes)
```lean
structure CloseCode where
  code : UInt16

-- Named constants:
CloseCode.normal         -- 1000
CloseCode.goingAway      -- 1001
CloseCode.protocolError   -- 1002
CloseCode.unsupportedData -- 1003
```

### ServerApp (Application Type)
```lean
abbrev ServerApp := PendingConnection -> IO Unit
```

## Proven Properties (6 theorems)

All opcode encoding/decoding roundtrips, in `Types.lean`:

| Theorem | Statement |
|---------|-----------|
| `opcode_roundtrip_text` | `fromUInt8 (toUInt8 .text) = .text` |
| `opcode_roundtrip_binary` | `fromUInt8 (toUInt8 .binary) = .binary` |
| `opcode_roundtrip_close` | `fromUInt8 (toUInt8 .close) = .close` |
| `opcode_roundtrip_ping` | `fromUInt8 (toUInt8 .ping) = .ping` |
| `opcode_roundtrip_pong` | `fromUInt8 (toUInt8 .pong) = .pong` |
| `opcode_roundtrip_continuation` | `fromUInt8 (toUInt8 .continuation) = .continuation` |

## Implementation Notes

- **XOR masking:** `applyMask` applies the 4-byte masking key via XOR.
  XOR is its own inverse, so the same function masks and unmasks.
- **Auto-pong:** When a `ping` control frame is received during `receiveData`,
  the connection automatically replies with a `pong` frame (RFC 6455 section 5.5.3).
- **SHA-1 placeholder:** The handshake module contains a placeholder SHA-1
  implementation. TODO: replace with full FIPS 180-4 implementation for production.

## Files
- `Types.lean` -- Core types (Opcode, ConnectionState, Connection, PendingConnection) + 6 roundtrip proofs
- `Frame.lean` -- Frame encode/decode + XOR masking
- `Handshake.lean` -- WebSocket upgrade (SHA-1 + Base64, magic GUID)
- `Connection.lean` -- High-level send/receive API with auto-pong
