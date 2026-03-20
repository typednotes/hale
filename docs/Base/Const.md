# Const
**Lean:** `LeanStd.Base.Const` | **Haskell:** `Data.Functor.Const`

## Overview
Constant functor — ignores its second type parameter. Useful for phantom types and accumulating effects during traversals.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Const` | `Const` | Type |
| `getConst` | `getConst` | Accessor |
| `Functor Const` | `Functor (Const a)` | Instance |
| `Pure Const` | `Applicative (Const a)` | Instance |

## Instances
- `BEq (Const a b)` (requires `BEq a`)
- `Ord (Const a b)` (requires `Ord a`)
- `Repr (Const a b)` (requires `Repr a`)
- `ToString (Const a b)` (requires `ToString a`)
- `Functor (Const a)`
- `Pure (Const a)` (requires `Append a` and `Inhabited a`)

## Proofs & Guarantees
- `map_val` — mapping over `Const` preserves the wrapped value
- `map_id` — `Functor.map id = id`
- `map_comp` — `Functor.map (f . g) = Functor.map f . Functor.map g`

## Example
```lean
-- Mapping over Const does nothing to the stored value
(Functor.map f (Const.mk 42) : Const Nat String).getConst == 42
-- => true
```
