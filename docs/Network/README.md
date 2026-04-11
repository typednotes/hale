# Network -- POSIX Sockets with Phantom State

**Lean:** `Hale.Network` | **Haskell:** `network`

POSIX socket API with phantom type parameters encoding lifecycle states. A `Socket (state : SocketState)` tracks state transitions (fresh → bound → listening → connected → closed) at compile time, making it a type error to send on an unconnected socket or close an already-closed one.

## Socket State Machine

```
  Fresh ──bind──► Bound ──listen──► Listening ──accept──► Connected
    │                                                         │
    └──────────────────── close ◄─────────────────────────────┘
```

## Key Types

| Type | Description |
|------|-------------|
| `Socket (state : SocketState)` | Phantom-typed socket |
| `SocketState` | `.fresh \| .bound \| .listening \| .connected \| .closed` |
| `SockAddr` | Socket address |
| `AcceptOutcome` / `RecvOutcome` / `SendOutcome` | Non-blocking I/O outcomes |
| `RecvBuffer` | Buffered reader with CRLF scanning (C FFI) |
| `EventDispatcher` | Green thread suspension bridge (kqueue/epoll) |

## API

| Function | State Transition | Signature |
|----------|-----------------|-----------|
| `socket` | → `.fresh` | `IO (Socket .fresh)` |
| `bind` | `.fresh` → `.bound` | `Socket .fresh → SockAddr → IO (Socket .bound)` |
| `listen` | `.bound` → `.listening` | `Socket .bound → Nat → IO (Socket .listening)` |
| `accept` | `.listening` → `.connected` | `Socket .listening → IO (Socket .connected × SockAddr)` |
| `connect` | `.fresh` → `.connected` | `Socket .fresh → SockAddr → IO (Socket .connected)` |
| `send` | requires `.connected` | `Socket .connected → ByteArray → IO Nat` |
| `recv` | requires `.connected` | `Socket .connected → Nat → IO ByteArray` |
| `close` | any → `.closed` | `Socket s → IO Unit` |

## Files
- `Hale/Network/Network/Socket/Types.lean` -- SocketState, SockAddr, phantom socket type
- `Hale/Network/Network/Socket/FFI.lean` -- C FFI declarations
- `Hale/Network/Network/Socket.lean` -- High-level API with state transitions
- `Hale/Network/Network/Socket/ByteString.lean` -- ByteArray send/recv
- `Hale/Network/Network/Socket/Blocking.lean` -- Blocking wrappers
- `Hale/Network/Network/Socket/EventDispatcher.lean` -- kqueue/epoll dispatcher
