/-
  Network.Wai.Application.Static -- Static file serving WAI application

  Provides `staticApp` which creates a WAI `Application` that serves
  static files based on `StaticSettings`, and `static` as a convenience
  for filesystem-backed serving.

  ## Design

  Mirrors Haskell's `Network.Wai.Application.Static` from `wai-app-static`.
  The heavy dependencies (blaze-html, template-haskell, file-embed) are
  skipped; only core serving logic is ported.

  ## Guarantees

  - Invalid paths (dotfiles, slashes) are rejected with 403
  - Cache-Control headers are set according to `ssMaxAge`
  - Folder requests try index files before falling back to listing or 404
  - Redirects use 301 for permanent path canonicalization
-/
import Hale.WaiAppStatic.WaiAppStatic.Types
import Hale.WaiAppStatic.WaiAppStatic.Storage.Filesystem

namespace Network.Wai.Application

open WaiAppStatic
open WaiAppStatic.Storage
open Network.Wai
open Network.HTTP.Types

/-- Render MaxAge as a Cache-Control header value.
    Returns `none` for `noMaxAge` (no header should be emitted).
    $$\text{maxAgeToHeader} : \text{MaxAge} \to \text{Option String}$$ -/
private def maxAgeToHeader : MaxAge -> Option String
  | .noMaxAge => none
  | .maxAgeSeconds n => some s!"max-age={n}"
  | .maxAgeForever => some "max-age=31536000"
  | .noStore => some "no-store"
  | .noCache => some "no-cache"

/-- Build cache-control headers from MaxAge settings. -/
private def cacheHeaders (maxAge : MaxAge) : ResponseHeaders :=
  match maxAgeToHeader maxAge with
  | some cc => [(hCacheControl, cc)]
  | none => []

/-- Try index files in order. Returns the first matching file response,
    or `none` if no index file is found.
    $$\text{tryIndices} : \text{lookup} \to \text{Pieces} \to \text{List Piece} \to \text{IO (Option File)}$$ -/
private partial def tryIndices
    (lookup : Pieces -> IO LookupResult)
    (pieces : Pieces)
    : List Piece -> IO (Option File)
  | [] => pure none
  | idx :: rest => do
    let result ← lookup (pieces ++ [idx])
    match result with
    | .lrFile file => pure (some file)
    | _ => tryIndices lookup pieces rest

/-- Create a WAI Application that serves static files.
    Path segments from the request are validated as `Piece`s to prevent
    directory traversal. Lookup, caching, and directory handling are
    controlled by the `StaticSettings`.
    $$\text{staticApp} : \text{StaticSettings} \to \text{Application}$$ -/
def staticApp (settings : StaticSettings) : Application :=
  fun req respond => do
    -- Convert path segments to validated Pieces
    let piecesOpt := toPieces req.pathInfo
    match piecesOpt with
    | none =>
      -- Invalid path (contains dots or slashes in segments)
      respond (.responseBuilder status403 [] "Forbidden".toUTF8)
    | some pieces =>
      let result ← settings.ssLookupFile pieces
      match result with
      | .lrFile file =>
        let headers := cacheHeaders settings.ssMaxAge
        respond (file.fileToResponse status200 headers)
      | .lrFolder => do
        if settings.ssRedirectToIndex then
          let indexFile ← tryIndices settings.ssLookupFile pieces settings.ssIndices
          match indexFile with
          | some file =>
            let headers := cacheHeaders settings.ssMaxAge
            respond (file.fileToResponse status200 headers)
          | none =>
            match settings.ssListing with
            | some listing =>
              let resp ← listing pieces
              respond resp
            | none =>
              respond (.responseBuilder status404 [] "Not Found".toUTF8)
        else
          respond (.responseBuilder status301
            [(hLocation, req.rawPathInfo ++ "/")]
            ByteArray.empty)
      | .lrNotFound =>
        respond (.responseBuilder status404 [] "Not Found".toUTF8)
      | .lrRedirect newPieces =>
        let newPath := "/" ++ "/".intercalate (newPieces.map toString)
        respond (.responseBuilder status301
          [(hLocation, newPath)] ByteArray.empty)

/-- Convenience: serve files from a filesystem directory.
    Equivalent to `staticApp (defaultFileServerSettings root)`.
    $$\text{static} : \text{String} \to \text{Application}$$ -/
def static (root : String) : Application :=
  staticApp (defaultFileServerSettings root)

end Network.Wai.Application
