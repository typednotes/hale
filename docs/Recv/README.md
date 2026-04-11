# Recv -- Socket Receive

**Lean:** `Hale.Recv` | **Haskell:** `recv`

Thin wrapper for socket recv returning `ByteArray`. Empty result signals EOF.

## API

| Function | Description |
|----------|-------------|
| `recv` | Receive up to N bytes, returns empty `ByteArray` on EOF |
| `recvString` | UTF-8 decoded variant |

## Files
- `Hale/Recv/Network/Socket/Recv.lean` -- recv, recvString
