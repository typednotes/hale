# WaiAppStatic -- Static File Serving

**Lean:** `Hale.WaiAppStatic` | **Haskell:** `wai-app-static`

> **API Reference:** [Hale.WaiAppStatic](../../Hale/WaiAppStatic.html) | [Types](../../Hale/WaiAppStatic/WaiAppStatic/Types.html) | [Filesystem](../../Hale/WaiAppStatic/WaiAppStatic/Storage/Filesystem.html) | [Static](../../Hale/WaiAppStatic/Network/Wai/Application/Static.html)

Serves static files from the filesystem with type-safe path validation.

## Request Flow

```
  GET /css/style.css
         |
         v
  +---------------------+
  | toPieces(pathInfo)   |  Validate each path segment
  | "css"       -> Piece |  No dots, no slashes
  | "style.css" -> Piece |
  +--------+------------+
           |
  +--------v------------+
  | ssLookupFile         |  Filesystem stat + MIME lookup
  | -> LookupResult      |
  +--------+------------+
           |
     +-----+------+------------+------------+
     |            |            |            |
     v            v            v            v
  lrFile      lrFolder     lrNotFound   lrRedirect
  200 OK      try index    404          301
  + Cache     files
  + MIME
```

## Dependent Type: Piece (Path Traversal Prevention)

```lean
structure Piece where
  val : String
  no_dot   : startsDot val = false        -- no dotfiles
  no_slash : containsSlash val = false     -- no path traversal
```

The `no_dot` and `no_slash` fields are proofs, erased at runtime.
A `Piece` is just a `String` at runtime, but the type system guarantees
it cannot contain a leading dot or an embedded slash.

### Smart Constructor
```lean
def toPiece (t : String) : Option Piece  -- None if invalid!
```

**Proven properties (4 theorems, in `Types.lean`):**

| Theorem | Statement |
|---------|-----------|
| `empty_piece_valid` | `toPiece "" = some _` |
| `toPiece_rejects_dot` | `toPiece ".hidden" = none` |
| `toPiece_rejects_slash` | `toPiece "a/b" = none` |
| `toPiece_accepts_simple` | `toPiece "index.html" = some _` |

**Security guarantee:** It is impossible to construct a `Piece` with a
leading dot or embedded slash. The `staticApp` function only accepts
`Piece` values, so **dotfile serving and path traversal are prevented
by the type system**, not by runtime checks.

## Other Types

### LookupResult (File Lookup Outcome)
```lean
inductive LookupResult where
  | lrFile (file : File)       -- found a file
  | lrFolder                   -- found a directory
  | lrNotFound                 -- path does not exist
  | lrRedirect (pieces : Pieces)  -- client should be redirected
```

### MaxAge (Cache Control)
```lean
inductive MaxAge where
  | noMaxAge                   -- no cache-control header
  | maxAgeSeconds (seconds : Nat)  -- max-age=N
  | maxAgeForever              -- ~1 year (31536000s)
  | noStore                    -- cache-control: no-store
  | noCache                    -- cache-control: no-cache
```

### StaticSettings (Server Configuration)
```lean
structure StaticSettings where
  ssLookupFile    : Pieces -> IO LookupResult
  ssGetMimeType   : Piece -> String
  ssMaxAge        : MaxAge := .maxAgeSeconds 3600
  ssRedirectToIndex : Bool := true
  ssIndices       : List Piece := [unsafeToPiece "index.html"]
  ssListing       : Option (Pieces -> IO Response) := none
```

## Files
- `WaiAppStatic/Types.lean` -- Piece, LookupResult, StaticSettings + 4 proofs
- `WaiAppStatic/Storage/Filesystem.lean` -- Filesystem backend
- `Network/Wai/Application/Static.lean` -- WAI Application wrapper
