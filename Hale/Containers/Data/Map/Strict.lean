import Hale.Containers.Data.Map

/-
  Hale.Containers.Data.Map.Strict — Strict ordered finite maps

  Port of Haskell's `Data.Map.Strict` from the `containers` package.
  Since Lean 4 is a strict language, this module simply re-exports
  `Data.Map` — there is no distinction between lazy and strict maps.

  Reference: https://hackage.haskell.org/package/containers/docs/Data-Map-Strict.html
-/

-- Re-export everything from Data.Map. In Lean (strict evaluation),
-- there is no difference between the lazy and strict variants.
