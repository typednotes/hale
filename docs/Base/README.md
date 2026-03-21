# LeanStd.Base — Haskell `base` for Lean 4

Re-exports all Base sub-modules organized by phase.

## Design Philosophy (Concurrency)

All concurrency primitives are **promise-based**, not OS-thread-based. Blocking operations return `BaseIO (Task a)` rather than suspending an OS thread. This enables scaling to millions of concurrent "threads" on Lean's task-pool scheduler.

Cancellation is **cooperative**: `killThread` sets a `CancellationToken` rather than throwing an asynchronous exception. CPU-bound threads that never check the token will not be interrupted.

## Phase 0: Foundational
- [Void](Data/Void.md) — `Data.Void`
- [Function](Data/Function.md) — `Data.Function`
- [Newtype](Data/Newtype.md) — `Data.Monoid` / `Data.Semigroup`

## Phase 1: Core Abstractions
- [Bifunctor](Data/Bifunctor.md) — `Data.Bifunctor`
- [Contravariant](Data/Functor/Contravariant.md) — `Data.Functor.Contravariant`
- [Const](Data/Functor/Const.md) — `Data.Functor.Const`
- [Identity](Data/Functor/Identity.md) — `Data.Functor.Identity`
- [Compose](Data/Functor/Compose.md) — `Data.Functor.Compose`
- [Category](Control/Category.md) — `Control.Category`

## Phase 2: Data Structures
- [NonEmpty](Data/List/NonEmpty.md) — `Data.List.NonEmpty`
- [Either](Data/Either.md) — `Data.Either`
- [Ord](Data/Ord.md) — `Data.Ord`
- [Tuple](Data/Tuple.md) — `Data.Tuple` + `Prelude`

## Phase 3: Traversals
- [Foldable](Data/Foldable.md) — `Data.Foldable`
- [Traversable](Data/Traversable.md) — `Data.Traversable`

## Phase 4: Numeric Types
- [Ratio](Data/Ratio.md) — `Data.Ratio`
- [Complex](Data/Complex.md) — `Data.Complex`
- [Fixed](Data/Fixed.md) — `Data.Fixed`

## Phase 5: Advanced Abstractions
- [Arrow](Control/Arrow.md) — `Control.Arrow`

## Phase 6: Concurrency
- [Concurrent](Control/Concurrent.md) — `Control.Concurrent`
- [MVar](Control/Concurrent/MVar.md) — `Control.Concurrent.MVar`
- [Chan](Control/Concurrent/Chan.md) — `Control.Concurrent.Chan`
- [QSem](Control/Concurrent/QSem.md) — `Control.Concurrent.QSem`
- [QSemN](Control/Concurrent/QSemN.md) — `Control.Concurrent.QSemN`
