# HttpConduit -- HTTP + Conduit Integration

**Lean:** `Hale.HttpConduit` | **Haskell:** `http-conduit`

Conduit integration for HTTP client and simple high-level HTTP API.

## API

| Function | Description |
|----------|-------------|
| `httpSource` | Stream response body as conduit source |
| `parseUrl` | Parse URL string (http:// and https://) |

## Files
- `Hale/HttpConduit/Network/HTTP/Client/Conduit.lean` -- Conduit bridge
- `Hale/HttpConduit/Network/HTTP/Simple.lean` -- Simple one-shot API
