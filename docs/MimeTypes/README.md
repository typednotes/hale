# MimeTypes -- MIME Type Lookup

**Lean:** `Hale.MimeTypes` | **Haskell:** `mime-types`

Map file extensions to MIME types. Default fallback: `application/octet-stream`. Handles multi-part extensions (e.g., `tar.gz`).

## Key Types

| Type | Description |
|------|-------------|
| `MimeType` | `String` |
| `MimeMap` | `List (Extension × MimeType)` |

## API

| Function | Description |
|----------|-------------|
| `defaultMimeLookup` | Look up MIME type by filename |
| `defaultMimeMap` | Built-in extension → MIME mapping |

## Files
- `Hale/MimeTypes/Network/Mime.lean` -- MimeType, MimeMap, lookup
