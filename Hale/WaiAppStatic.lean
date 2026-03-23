/-
  Hale.WaiAppStatic -- Haskell `wai-app-static` for Lean 4

  Static file serving for WAI applications. Provides core types
  (`Piece`, `StaticSettings`, `LookupResult`) and a filesystem
  storage backend.

  Heavy dependencies (blaze-html, template-haskell, file-embed) are
  skipped; only the core serving functionality is ported.
-/
import Hale.WaiAppStatic.WaiAppStatic.Types
import Hale.WaiAppStatic.WaiAppStatic.Storage.Filesystem
import Hale.WaiAppStatic.Network.Wai.Application.Static
