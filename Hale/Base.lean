/-
  LeanStd.Base — Haskell `base` for Lean 4

  Re-exports all Base sub-modules. Inspired by Haskell's `base` package,
  with a maximalist approach to typing: types encode correctness proofs,
  invariants, and guarantees.
-/

-- Phase 0: Foundational
import LeanStd.Base.Data.Void
import LeanStd.Base.Data.Function
import LeanStd.Base.Data.Newtype

-- Phase 1: Core Abstractions
import LeanStd.Base.Data.Bifunctor
import LeanStd.Base.Data.Functor.Contravariant
import LeanStd.Base.Data.Functor.Const
import LeanStd.Base.Data.Functor.Identity
import LeanStd.Base.Data.Functor.Compose
import LeanStd.Base.Control.Category

-- Phase 2: Data Structures
import LeanStd.Base.Data.List.NonEmpty
import LeanStd.Base.Data.Either
import LeanStd.Base.Data.Ord
import LeanStd.Base.Data.Tuple

-- Phase 3: Traversals
import LeanStd.Base.Data.Foldable
import LeanStd.Base.Data.Traversable

-- Phase 4: Numeric Types
import LeanStd.Base.Data.Ratio
import LeanStd.Base.Data.Complex
import LeanStd.Base.Data.Fixed

-- Phase 5: Advanced Abstractions
import LeanStd.Base.Control.Arrow

-- Concurrency
import LeanStd.Base.Control.Concurrent
import LeanStd.Base.Control.Concurrent.MVar
import LeanStd.Base.Control.Concurrent.Chan
import LeanStd.Base.Control.Concurrent.QSem
import LeanStd.Base.Control.Concurrent.QSemN
