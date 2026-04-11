# HttpClient -- HTTP Client

**Lean:** `Hale.HttpClient` | **Haskell:** `http-client`

HTTP client with pluggable transport. `Connection` abstracts plain TCP and TLS uniformly.

## Key Types

| Type | Description |
|------|-------------|
| `Connection` | Record with read/write/close callbacks |
| `Request` | Serializable HTTP request |
| `Response` | Parsed status, headers, body |

## API

| Function | Description |
|----------|-------------|
| `connectionFromSocket` | TCP connection builder |
| `connectionFromTLS` | TLS connection builder |

## Modules
- `Types` -- Core types
- `Connection` -- Transport abstraction
- `Request` -- Request building and serialization
- `Response` -- Response parsing
- `Redirect` -- Redirect following

## Files
- `Hale/HttpClient/Network/HTTP/Client/Types.lean` -- Connection, Request, Response
- `Hale/HttpClient/Network/HTTP/Client/Connection.lean` -- Transport
- `Hale/HttpClient/Network/HTTP/Client/Request.lean` -- Request
- `Hale/HttpClient/Network/HTTP/Client/Response.lean` -- Response
- `Hale/HttpClient/Network/HTTP/Client/Redirect.lean` -- Redirects
