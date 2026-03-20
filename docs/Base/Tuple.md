# Tuple
**Lean:** `LeanStd.Base.Tuple` | **Haskell:** `Data.Tuple` + `Prelude`

## Overview
Pair operations: swap, map components, curry/uncurry. Provides bidirectional conversions between curried and uncurried function forms.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Tuple.swap` | `swap` | Function |
| `Tuple.mapFst` | `first` (Control.Arrow) | Function |
| `Tuple.mapSnd` | `second` | Function |
| `Tuple.bimap` | `bimap` | Function |
| `Tuple.curry` | `curry` | Function |
| `Tuple.uncurry` | `uncurry` | Function |

## Instances
None (standalone functions on `Prod`).

## Proofs & Guarantees
- `swap_swap` — `swap (swap p) = p` (involution)
- `curry_uncurry` — `curry (uncurry f) = f`
- `uncurry_curry` — `uncurry (curry f) = f`
- `bimap_id` — `bimap id id = id`
- `bimap_comp` — `bimap (f1 . f2) (g1 . g2) = bimap f1 g1 . bimap f2 g2`
- `mapFst_eq_bimap` — `mapFst f = bimap f id`
- `mapSnd_eq_bimap` — `mapSnd f = bimap id f`

## Example
```lean
-- Curry converts a function on pairs to a curried function
Tuple.curry (fun p => p.1 + p.2) 2 3
-- => 5
```
