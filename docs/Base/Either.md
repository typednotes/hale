# Either
**Lean:** `LeanStd.Base.Either` | **Haskell:** `Data.Either`

## Overview
Sum type with `Left` and `Right` constructors. Right-biased for `Functor`/`Monad` instances. Includes partitioning of lists of `Either` values.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Either` | `Either` | Type |
| `left` / `right` | `Left` / `Right` | Constructors |
| `isLeft` / `isRight` | `isLeft` / `isRight` | Predicate |
| `fromLeft` / `fromRight` | `fromLeft` / `fromRight` | Accessor |
| `either` | `either` | Eliminator |
| `mapLeft` / `mapRight` | `first` / `second` | Function |
| `swap` | N/A | Function |
| `partitionEithers` | `partitionEithers` | Function |

## Instances
- `Functor (Either a)`
- `Pure (Either a)`
- `Bind (Either a)`
- `Seq (Either a)`
- `Applicative (Either a)`
- `Monad (Either a)`
- `Bifunctor Either`
- `ToString (Either a b)` (requires `ToString a`, `ToString b`)

## Proofs & Guarantees
- `swap_swap` — `swap (swap e) = e` (involution)
- `isLeft_not_isRight` — `isLeft e = !isRight e`
- `partitionEithers_length` — total elements preserved after partitioning

## Example
```lean
-- Partition a list of Either values
Either.partitionEithers [.left "a", .right 1, .left "b", .right 2]
-- => (["a", "b"], [1, 2])
```
