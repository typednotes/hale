# WaiExtra -- Middleware Collection

**Lean:** `Hale.WaiExtra` | **Haskell:** `wai-extra`

> **API Reference:** [Hale.WaiExtra](../../Hale/WaiExtra.html) | [AddHeaders](../../Hale/WaiExtra/Network/Wai/Middleware/AddHeaders.html) | [ForceSSL](../../Hale/WaiExtra/Network/Wai/Middleware/ForceSSL.html) | [Gzip](../../Hale/WaiExtra/Network/Wai/Middleware/Gzip.html) | [HttpAuth](../../Hale/WaiExtra/Network/Wai/Middleware/HttpAuth.html) | [Test](../../Hale/WaiExtra/Network/Wai/Test.html)

36 middleware modules for request/response transformation.

## Middleware Composition

```
         +----------------------------------------------+
         |         Middleware Composition                 |
         |                                               |
         |   m1 . m2 . m3 : Middleware                   |
         |                                               |
         |   Algebraic Laws:                             |
         |     id . m = m        (left identity)         |
         |     m . id = m        (right identity)        |
         |     (f.g).h = f.(g.h) (associativity)         |
         +----------------------------------------------+

  Request --> m1 --> m2 --> m3 --> App --> Response
              |       |       |              |
              | modify| check |              | modify
              | headers auth  |              | headers
              v       v       v              v
```

## Available Middleware

### Request Modification
| Middleware | Proven Properties | Description |
|-----------|-------------------|-------------|
| `methodOverride` | -- | Override method from `_method` query param |
| `methodOverridePost` | -- | Override method from POST body |
| `acceptOverride` | -- | Override Accept from `_accept` param |
| `realIp` | -- | Extract client IP from X-Forwarded-For |
| `rewrite` | -- | URL path rewriting rules |

### Response Modification
| Middleware | Proven Properties | Description |
|-----------|-------------------|-------------|
| `addHeaders` | `addHeaders [] = id` | Add headers to responses |
| `stripHeaders` | `stripHeaders [] = id` | Remove headers from responses |
| `combineHeaders` | -- | Merge duplicate headers |
| `gzip` | -- | Gzip compression (framework) |
| `streamFile` | -- | Convert file->stream responses |

### Routing and Filtering
| Middleware | Proven Properties | Description |
|-----------|-------------------|-------------|
| `select` | `select (fun _ => none) = id` | Conditional middleware |
| `routed` | `routed (fun _ => true) m = m`, `routed (fun _ => false) = id` | Path-based routing |
| `vhost` | -- | Virtual host routing |
| `urlMap` | -- | URL prefix routing |

### Security
| Middleware | Proven Properties | Description |
|-----------|-------------------|-------------|
| `forceSSL` | Secure requests pass through | Redirect HTTP->HTTPS |
| `forceDomain` | -- | Redirect to canonical domain |
| `httpAuth` | -- | HTTP Basic Authentication |
| `localOnly` | -- | Restrict to localhost |
| `requestSizeLimit` | -- | Reject oversized bodies (413) |
| `validateHeaders` | -- | Reject invalid header chars (500) |

### Monitoring
| Middleware | Description |
|-----------|-------------|
| `requestLogger` | Apache/dev format logging |
| `requestLogger.json` | Structured JSON logging |
| `healthCheck` | Health check endpoint (200 OK) |
| `timeout` | Request timeout (503) |

### Protocol
| Middleware | Description |
|-----------|-------------|
| `autohead` | HEAD->GET + strip body |
| `cleanPath` | Normalize URL paths (301 redirect) |
| `approot` | Application root detection |
| `eventSource` | Server-Sent Events |
| `jsonp` | JSONP callback wrapping |

## Proven Properties (11 theorems)

All proofs are in the source files, verified at compile time (no `sorry`):

### AddHeaders Identity (3, in `AddHeaders.lean`)
| Theorem | Statement |
|---------|-----------|
| `addHeaders_nil_builder` | Empty headers on builder = identity |
| `addHeaders_nil_file` | Empty headers on file = identity |
| `addHeaders_nil_stream` | Empty headers on stream = identity |

### StripHeaders Identity (3, in `StripHeaders.lean`)
| Theorem | Statement |
|---------|-----------|
| `stripHeaders_nil_builder` | Empty strip list on builder = identity |
| `stripHeaders_nil_file` | Empty strip list on file = identity |
| `stripHeaders_nil_stream` | Empty strip list on stream = identity |

### Select (1, in `Select.lean`)
| Theorem | Statement |
|---------|-----------|
| `select_none` | Always-none selector = identity middleware |

### Routed (2, in `Routed.lean`)
| Theorem | Statement |
|---------|-----------|
| `routed_true` | Always-true predicate = apply middleware |
| `routed_false` | Always-false predicate = identity middleware |

### ForceSSL (1, in `ForceSSL.lean`)
| Theorem | Statement |
|---------|-----------|
| `forceSSL_secure` | Secure requests pass through unchanged |

### HealthCheck (1, in `HealthCheckEndpoint.lean`)
| Theorem | Statement |
|---------|-----------|
| `healthCheck_passthrough` | Non-matching paths pass through to inner app |

## Files (36 modules)
| File | Purpose |
|------|---------|
| `Middleware/AddHeaders.lean` | Add headers + 3 identity proofs |
| `Middleware/StripHeaders.lean` | Remove headers + 3 identity proofs |
| `Middleware/Select.lean` | Conditional middleware + 1 proof |
| `Middleware/Routed.lean` | Path-based routing + 2 proofs |
| `Middleware/ForceSSL.lean` | HTTP->HTTPS redirect + 1 proof |
| `Middleware/HealthCheckEndpoint.lean` | Health check + 1 proof |
| `Middleware/Autohead.lean` | HEAD method handling |
| `Middleware/AcceptOverride.lean` | Accept header override |
| `Middleware/MethodOverride.lean` | Method override (query param) |
| `Middleware/MethodOverridePost.lean` | Method override (POST body) |
| `Middleware/Vhost.lean` | Virtual host routing |
| `Middleware/Timeout.lean` | Request timeout |
| `Middleware/CombineHeaders.lean` | Header deduplication |
| `Middleware/StreamFile.lean` | File->stream conversion |
| `Middleware/Rewrite.lean` | URL rewriting |
| `Middleware/CleanPath.lean` | Path normalization |
| `Middleware/ForceDomain.lean` | Domain redirect |
| `Middleware/Local.lean` | Localhost restriction |
| `Middleware/RealIp.lean` | Client IP extraction |
| `Middleware/HttpAuth.lean` | Basic authentication |
| `Middleware/RequestSizeLimit.lean` | Body size limit |
| `Middleware/ValidateHeaders.lean` | Header validation |
| `Middleware/RequestLogger.lean` | Request logging |
| `Middleware/RequestLogger/JSON.lean` | JSON request logging |
| `Middleware/Gzip.lean` | Gzip compression |
| `Middleware/Approot.lean` | Application root |
| `Middleware/Jsonp.lean` | JSONP support |
| `UrlMap.lean` | URL prefix routing |
| `Header.lean` | WAI header utilities |
| `Request.lean` | Request utilities |
| `Parse.lean` | Multipart/form parsing |
| `EventSource.lean` | Server-Sent Events |
| `EventSource/EventStream.lean` | SSE stream types |
| `Test.lean` | WAI test utilities |
| `Test/Internal.lean` | Test internals |
| `Middleware/RequestSizeLimit/Internal.lean` | Size limit internals |
