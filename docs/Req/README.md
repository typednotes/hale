# Req -- Type-Safe HTTP Client

**Lean:** `Hale.Req` | **Haskell:** `req`

Type-safe HTTP client with compile-time guarantees: method/body compatibility, HTTPS-only auth, non-empty hostnames, proven option monoid laws.

## Compile-Time Guarantees
- `HttpBodyAllowed` prevents GET with body
- `basicAuth` returns `Option .Https` for type safety
- Hostname non-emptiness proven at construction

## Files
- `Hale/Req/Network/HTTP/Req.lean` -- Type-safe request builders
