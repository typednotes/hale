# Base64 -- RFC 4648 Codec

**Lean:** `Hale.Base64` | **Haskell:** `base64-bytestring`

Base64 encoding and decoding per RFC 4648.

## Guarantees
- `decode (encode bs) = some bs` (roundtrip)
- Output of `encode` contains only `[A-Za-z0-9+/=]`

## API

| Function | Signature |
|----------|-----------|
| `encode` | `ByteArray → String` |
| `decode` | `String → Option ByteArray` |

## Files
- `Hale/Base64/Data/ByteString/Base64.lean` -- encode, decode
