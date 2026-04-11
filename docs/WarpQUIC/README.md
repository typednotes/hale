# WarpQUIC -- HTTP/3 over QUIC

**Lean:** `Hale.WarpQUIC` | **Haskell:** `warp-quic`

WAI handler over HTTP/3/QUIC transport. TLS 1.3 mandatory (QUIC requirement).

## Key Types

```lean
structure Settings where
  port     : Nat
  certFile : String
  keyFile  : String
```

## Files
- `Hale/WarpQUIC/Network/Wai/Handler/WarpQUIC.lean` -- Settings, QUIC server entry point
