# WarpTLS -- HTTPS for Warp

**Lean:** `Hale.WarpTLS` | **Haskell:** `warp-tls`

HTTPS support for Warp using OpenSSL FFI. TLS 1.2+ enforced. ALPN negotiation for HTTP/2. Uses EventDispatcher and Green monad for non-blocking I/O.

## Key Types

| Type | Description |
|------|-------------|
| `OnInsecure` | `denyInsecure \| allowInsecure` -- handling for non-TLS connections |
| `CertSettings` | Certificate source (`certFile` with paths) |

## Files
- `Hale/WarpTLS/Network/Wai/Handler/WarpTLS.lean` -- runTLS, TLS settings
- `Hale/WarpTLS/Network/Wai/Handler/WarpTLS/Internal.lean` -- Internal types
