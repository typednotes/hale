# BsbHttpChunked -- Chunked Transfer Encoding

**Lean:** `Hale.BsbHttpChunked` | **Haskell:** `bsb-http-chunked`

HTTP/1.1 chunked transfer encoding framing. Each chunk: `<hex-length>\r\n<data>\r\n`. Terminator: `0\r\n\r\n`.

## API

| Function | Description |
|----------|-------------|
| `hexChar` | Encode a hex digit |
| `natToHex` | Encode Nat as hex bytes |

## Files
- `Hale/BsbHttpChunked/Network/HTTP/Chunked.lean` -- Chunked encoding helpers
