# TLS -- OpenSSL FFI Wrapper

**Lean:** `Hale.TLS` | **Haskell:** `tls` (concept) / OpenSSL bindings

> **API Reference:** [Hale.TLS](../../Hale/TLS.html) | [Types](../../Hale/TLS/Network/TLS/Types.html) | [Context](../../Hale/TLS/Network/TLS/Context.html) | [WarpTLS](../../Hale/WarpTLS/Network/Wai/Handler/WarpTLS.html)

HTTPS support via OpenSSL/LibreSSL C FFI.

## TLS Handshake Flow

```
  Client                          Server
    |                               |
    |     TCP connect               |
    |------------------------------>|
    |                               |
    |     ClientHello               |
    |------------------------------>|
    |                               | SSL_accept()
    |     ServerHello + Cert        | (OpenSSL FFI)
    |<------------------------------|
    |                               |
    |     Key Exchange + Finished   |
    |------------------------------>|
    |                               |
    |     === TLS Established ===   |
    |                               |
    |     HTTP/1.1 (encrypted)      |
    |------------------------------>|
    |     or HTTP/2 (via ALPN)      |
    |                               |
```

## Opaque Handles (FFI Pattern)

```lean
opaque TLSContextHandle : NonemptyType    -- SSL_CTX*
opaque TLSSessionHandle : NonemptyType    -- SSL*
def TLSContext := TLSContextHandle.type
def TLSSession := TLSSessionHandle.type
```

Both handles use the `lean_alloc_external` / `lean_register_external_class`
pattern (same as Socket). The GC finalizer calls `SSL_free` / `SSL_CTX_free`
automatically when the Lean object is collected.

## API

| Lean | C (OpenSSL) | Signature |
|------|-------------|-----------|
| `createContext` | `SSL_CTX_new` + `SSL_CTX_use_certificate_file` | `String -> String -> IO TLSContext` |
| `setAlpn` | `SSL_CTX_set_alpn_select_cb` | `TLSContext -> IO Unit` |
| `acceptSocket` | `SSL_new` + `SSL_set_fd` + `SSL_accept` | `TLSContext -> RawSocket -> IO TLSSession` |
| `read` | `SSL_read` | `TLSSession -> USize -> IO ByteArray` |
| `write` | `SSL_write` | `TLSSession -> ByteArray -> IO Unit` |
| `close` | `SSL_shutdown` + `SSL_free` | `TLSSession -> IO Unit` |
| `getVersion` | `SSL_get_version` | `TLSSession -> IO String` |
| `getAlpn` | `SSL_get0_alpn_selected` | `TLSSession -> IO (Option String)` |

## TLS Version Types

```lean
inductive TLSVersion where
  | tls10 | tls11 | tls12 | tls13
```

## Security
- Minimum TLS 1.2 (enforced by `SSL_CTX_set_min_proto_version`)
- ALPN for HTTP/2 negotiation ("h2" / "http/1.1")
- Certificate + key validated at context creation time (OpenSSL rejects invalid files)
- Hardware AES-NI acceleration (via OpenSSL)
- Session finalizer ensures `SSL_shutdown` + `SSL_free` on GC

## Integration with WarpTLS

`WarpTLS.runTLS` creates a `TLSContext` once at startup, then for each
accepted connection:

```
1. Socket.accept  -> Socket .connected
2. TLS.acceptSocket ctx sock -> TLSSession
3. parseRequest + app + sendResponse (via TLS read/write)
4. TLS.close session
5. Socket.close sock
```

Both TLS session and socket are cleaned up in `try/finally` blocks.

## Files
- `Hale/TLS/Network/TLS/Types.lean` -- TLSVersion, CipherID
- `Hale/TLS/Network/TLS/Context.lean` -- Opaque handles + FFI declarations
