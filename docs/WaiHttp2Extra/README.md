# WaiHttp2Extra -- HTTP/2 Server Push

**Lean:** `Hale.WaiHttp2Extra` | **Haskell:** `wai-http2-extra`

HTTP/2 server push via referer prediction. Learns resource associations from Referer headers and proactively pushes on subsequent requests. LRU eviction for bounded memory.

## Key Types

| Type | Description |
|------|-------------|
| `PushSettings` | Middleware configuration |

## API

| Function | Description |
|----------|-------------|
| `pushOnReferer` | Create push middleware |

## Modules
- `Types` -- PushSettings, configuration
- `LRU` -- LRU eviction cache
- `Manager` -- Thread-safe push table
- `ParseURL` -- URL parsing for same-origin checks
- `Referer` -- Main middleware entry point

## Files
- `Hale/WaiHttp2Extra/Network/Wai/Middleware/Push/Referer.lean` -- Main middleware
- `Hale/WaiHttp2Extra/Network/Wai/Middleware/Push/Referer/Types.lean` -- Configuration
- `Hale/WaiHttp2Extra/Network/Wai/Middleware/Push/Referer/LRU.lean` -- LRU cache
- `Hale/WaiHttp2Extra/Network/Wai/Middleware/Push/Referer/Manager.lean` -- Push manager
- `Hale/WaiHttp2Extra/Network/Wai/Middleware/Push/Referer/ParseURL.lean` -- URL parsing
