/-
  Hale.Text — Haskell `text` for Lean 4

  Re-exports all Text sub-modules. Inspired by Haskell's `text` package.

  ## Haskell equivalent
  `text` (https://hackage.haskell.org/package/text)

  ## Design
  `Text` is `abbrev Text := String`. Lean's `String` is already UTF-8 encoded
  Unicode, so we reuse it directly and layer Haskell-compatible naming on top.

  ## Lean stdlib reuse
  Uses `String`, `Char`, `List`, `ByteArray` from Lean's stdlib.
-/

-- Core Text type and operations
import Hale.Text.Data.Text

-- UTF-8 encoding/decoding
import Hale.Text.Data.Text.Encoding
