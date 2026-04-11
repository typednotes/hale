# StreamingCommons -- Streaming Network Utilities

**Lean:** `Hale.StreamingCommons` | **Haskell:** `streaming-commons`

Streaming network utilities: bind/connect helpers and application data abstraction.

## Key Types

| Type | Description |
|------|-------------|
| `AppData` | Connection data with read/write/close/address fields |

## API

| Function | Description |
|----------|-------------|
| `bindPortTCP` | Bind server socket to port |
| `getSocketTCP` | Connect to remote TCP server |
| `acceptSafe` | Accept with transient error retry |

## Files
- `Hale/StreamingCommons/Data/Streaming/Network.lean` -- AppData, bind/connect helpers
