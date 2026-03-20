# Ord
**Lean:** `LeanStd.Base.Ord` | **Haskell:** `Data.Ord`

## Overview
Ordering utilities. `Down` reverses the comparison order. `comparing` lifts comparisons through projections. `clamp` returns a proof-carrying bounded value.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Down` | `Down` | Type |
| `comparing` | `comparing` | Function |
| `clampWith` | `clamp` | Function (returns `{y // lo <= y /\ y <= hi}`) |

## Instances
- `BEq (Down a)` (requires `BEq a`)
- `Ord (Down a)` (requires `Ord a`, reversed)
- `ToString (Down a)` (requires `ToString a`)

## Proofs & Guarantees
- `get_mk` — `(Down.mk x).get = x`
- `compare_reverse` — `compare (Down.mk a) (Down.mk b) = compare b a`

## Example
```lean
-- Down reverses comparison order
compare (Down.mk 3) (Down.mk 7)
-- => Ordering.gt  (because 3 < 7, but Down reverses it)
```
