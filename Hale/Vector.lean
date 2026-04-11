/-
  Hale.Vector — Haskell `vector` for Lean 4

  Re-exports all Vector sub-modules. Inspired by Haskell's `vector` package.

  ## Haskell equivalent
  `vector` (https://hackage.haskell.org/package/vector)

  ## Design
  `Vector` is `abbrev Vector := Array`. Lean's `Array` is already a dynamic
  array with O(1) amortized push and O(1) indexed access.

  ## Lean stdlib reuse
  Uses `Array` from Lean's stdlib. Adds Haskell-compatible naming.
-/

-- Core Vector type and operations
import Hale.Vector.Data.Vector
