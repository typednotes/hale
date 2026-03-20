# LeanStd.Base — Haskell `base` for Lean 4

Re-exports all Base sub-modules organized by phase.

## Phase 0: Foundational
- [Void](Void.md) — `Data.Void`
- [Function](Function.md) — `Data.Function`
- [Newtype](Newtype.md) — `Data.Monoid` / `Data.Semigroup`

## Phase 1: Core Abstractions
- [Bifunctor](Bifunctor.md) — `Data.Bifunctor`
- [Contravariant](Contravariant.md) — `Data.Functor.Contravariant`
- [Const](Const.md) — `Data.Functor.Const`
- [Identity](Identity.md) — `Data.Functor.Identity`
- [Compose](Compose.md) — `Data.Functor.Compose`
- [Category](Category.md) — `Control.Category`

## Phase 2: Data Structures
- [NonEmpty](NonEmpty.md) — `Data.List.NonEmpty`
- [Either](Either.md) — `Data.Either`
- [Ord](Ord.md) — `Data.Ord`
- [Tuple](Tuple.md) — `Data.Tuple` + `Prelude`

## Phase 3: Traversals
- [Foldable](Foldable.md) — `Data.Foldable`
- [Traversable](Traversable.md) — `Data.Traversable`

## Phase 4: Numeric Types
- [Ratio](Ratio.md) — `Data.Ratio`
- [Complex](Complex.md) — `Data.Complex`
- [Fixed](Fixed.md) — `Data.Fixed`

## Phase 5: Advanced Abstractions
- [Arrow](Arrow.md) — `Control.Arrow`
