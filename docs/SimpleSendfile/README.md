# SimpleSendfile -- Zero-Copy File Sending

**Lean:** `Hale.SimpleSendfile` | **Haskell:** `simple-sendfile`

Efficient file sending using sendfile(2) syscall for zero-copy transfer, with read+send fallback.

## Key Types

```lean
structure FilePart where
  offset : Nat
  count  : Nat
```

## API

| Function | Description |
|----------|-------------|
| `sendFile` | Send file (or portion) over connected socket |

## Files
- `Hale/SimpleSendfile/Network/Sendfile.lean` -- sendFile, FilePart
