# WaiWebSockets -- WebSocket WAI Handler

**Lean:** `Hale.WaiWebSockets` | **Haskell:** `wai-websockets`

Upgrade WAI requests to WebSocket connections.

## API

| Function | Description |
|----------|-------------|
| `isWebSocketsReq` | Check if request is a WebSocket upgrade |
| `websocketsApp` | Upgrade WAI request to WebSocket connection |

## Files
- `Hale/WaiWebSockets/Network/Wai/Handler/WebSockets.lean` -- WebSocket upgrade handler
