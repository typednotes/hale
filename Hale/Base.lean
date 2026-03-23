/-
  Hale.Base — Haskell `base` for Lean 4

  Re-exports all Base sub-modules. Inspired by Haskell's `base` package,
  with a maximalist approach to typing: types encode correctness proofs,
  invariants, and guarantees.
-/

-- Foundational
import Hale.Base.Data.Void
import Hale.Base.Data.Function
import Hale.Base.Data.Newtype
import Hale.Base.Data.Bool
import Hale.Base.Data.Proxy

-- Core Abstractions
import Hale.Base.Data.Bifunctor
import Hale.Base.Data.Functor.Contravariant
import Hale.Base.Data.Functor.Const
import Hale.Base.Data.Functor.Identity
import Hale.Base.Data.Functor.Compose
import Hale.Base.Data.Functor.Product
import Hale.Base.Data.Functor.Sum
import Hale.Base.Control.Category
import Hale.Base.Control.Applicative
import Hale.Base.Control.Monad

-- Data Structures
import Hale.Base.Data.List.NonEmpty
import Hale.Base.Data.List
import Hale.Base.Data.Either
import Hale.Base.Data.Maybe
import Hale.Base.Data.Ord
import Hale.Base.Data.Tuple
import Hale.Base.Data.Char
import Hale.Base.Data.String
import Hale.Base.Data.Unique

-- Traversals
import Hale.Base.Data.Foldable
import Hale.Base.Data.Traversable

-- Numeric Types
import Hale.Base.Data.Ratio
import Hale.Base.Data.Complex
import Hale.Base.Data.Fixed
import Hale.Base.Data.Bits
import Hale.Base.Data.Ix

-- IO and References
import Hale.Base.Data.IORef

-- Advanced Abstractions
import Hale.Base.Control.Arrow
import Hale.Base.Control.Exception

-- Concurrency
import Hale.Base.Control.Concurrent.Scheduler
import Hale.Base.Control.Concurrent
import Hale.Base.Control.Concurrent.Green
import Hale.Base.Control.Concurrent.MVar
import Hale.Base.Control.Concurrent.Chan
import Hale.Base.Control.Concurrent.QSem
import Hale.Base.Control.Concurrent.QSemN

-- System
import Hale.Base.System.IO
import Hale.Base.System.Exit
import Hale.Base.System.Environment
