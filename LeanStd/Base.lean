/-
  LeanStd.Base — Haskell `base` for Lean 4

  Re-exports all Base sub-modules. Inspired by Haskell's `base` package,
  with a maximalist approach to typing: types encode correctness proofs,
  invariants, and guarantees.
-/

-- Phase 0: Foundational
import LeanStd.Base.Void
import LeanStd.Base.Function
import LeanStd.Base.Newtype

-- Phase 1: Core Abstractions
import LeanStd.Base.Bifunctor
import LeanStd.Base.Contravariant
import LeanStd.Base.Const
import LeanStd.Base.Identity
import LeanStd.Base.Compose
import LeanStd.Base.Category

-- Phase 2: Data Structures
import LeanStd.Base.NonEmpty
import LeanStd.Base.Either
import LeanStd.Base.Ord
import LeanStd.Base.Tuple

-- Phase 3: Traversals
import LeanStd.Base.Foldable
import LeanStd.Base.Traversable

-- Phase 4: Numeric Types
import LeanStd.Base.Ratio
import LeanStd.Base.Complex
import LeanStd.Base.Fixed

-- Phase 5: Advanced Abstractions
import LeanStd.Base.Arrow
