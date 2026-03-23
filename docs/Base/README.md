# Hale.Base — Haskell `base` for Lean 4

> **API Reference:** [Hale.Base](../../Hale/Base.html)

Re-exports all Base sub-modules.

## Design Philosophy (Concurrency)

All concurrency primitives are **promise-based**, not OS-thread-based. Blocking operations return `BaseIO (Task a)` rather than suspending an OS thread. This enables scaling to millions of concurrent "threads" on Lean's task-pool scheduler.

Cancellation is **cooperative**: `killThread` sets a `CancellationToken` rather than throwing an asynchronous exception. CPU-bound threads that never check the token will not be interrupted.

## Foundational
- [Void](Data/Void.md) — `Data.Void`
- [Function](Data/Function.md) — `Data.Function`
- [Newtype](Data/Newtype.md) — `Data.Monoid` / `Data.Semigroup`

## Core Abstractions
- [Bifunctor](Data/Bifunctor.md) — `Data.Bifunctor`
- [Contravariant](Data/Functor/Contravariant.md) — `Data.Functor.Contravariant`
- [Const](Data/Functor/Const.md) — `Data.Functor.Const`
- [Identity](Data/Functor/Identity.md) — `Data.Functor.Identity`
- [Compose](Data/Functor/Compose.md) — `Data.Functor.Compose`
- [Category](Control/Category.md) — `Control.Category`

## Data Structures
- [NonEmpty](Data/List/NonEmpty.md) — `Data.List.NonEmpty`
- [Either](Data/Either.md) — `Data.Either`
- [Ord](Data/Ord.md) — `Data.Ord`
- [Tuple](Data/Tuple.md) — `Data.Tuple` + `Prelude`

## Traversals
- [Foldable](Data/Foldable.md) — `Data.Foldable`
- [Traversable](Data/Traversable.md) — `Data.Traversable`

## Numeric Types
- [Ratio](Data/Ratio.md) — `Data.Ratio`
- [Complex](Data/Complex.md) — `Data.Complex`
- [Fixed](Data/Fixed.md) — `Data.Fixed`

## Advanced Abstractions
- [Arrow](Control/Arrow.md) — `Control.Arrow`

## Concurrency
- [Concurrent](Control/Concurrent.md) — `Control.Concurrent`
- [MVar](Control/Concurrent/MVar.md) — `Control.Concurrent.MVar`
- [Chan](Control/Concurrent/Chan.md) — `Control.Concurrent.Chan`
- [QSem](Control/Concurrent/QSem.md) — `Control.Concurrent.QSem`
- [QSemN](Control/Concurrent/QSemN.md) — `Control.Concurrent.QSemN`
