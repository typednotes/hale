# HttpTypes -- Core HTTP Types

**Lean:** `Hale.HttpTypes` | **Haskell:** `http-types`

Core HTTP/1.1 types: methods, status codes, headers, versions, and URI query parsing. Status codes carry a bounded proof (`100 ≤ code ≤ 999`).

## Key Types

| Type | Description |
|------|-------------|
| `StdMethod` | Inductive of standard HTTP methods (GET, POST, HEAD, PUT, DELETE, etc.) |
| `Method` | `StdMethod` or custom `String` |
| `Status` | HTTP status with bounded 3-digit code (proof: `100 ≤ code ≤ 999`) |
| `HeaderName` | Case-insensitive header name |
| `Header` | `HeaderName × ByteArray` |
| `HttpVersion` | Major/minor pair with ordering |
| `Query` / `QueryItem` | Parsed query strings |

## API

| Function | Signature |
|----------|-----------|
| `parseQuery` | `String → Query` |
| `renderQuery` | `Bool → Query → String` |
| `urlEncode` | `Bool → ByteArray → ByteArray` |
| `urlDecode` | `Bool → ByteArray → Option ByteArray` |

## Files
- `Hale/HttpTypes/Network/HTTP/Types/Method.lean` -- StdMethod, Method
- `Hale/HttpTypes/Network/HTTP/Types/Status.lean` -- Status with bounded proof
- `Hale/HttpTypes/Network/HTTP/Types/Header.lean` -- Header types
- `Hale/HttpTypes/Network/HTTP/Types/Version.lean` -- HttpVersion
- `Hale/HttpTypes/Network/HTTP/Types/URI.lean` -- Query parsing and URL encoding
