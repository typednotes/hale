# Arrow
**Lean:** `LeanStd.Base.Arrow` | **Haskell:** `Control.Arrow`

## Overview
Arrow abstraction for generalized function-like computations. Extends `Category` with lifting and product/sum operations.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Arrow` class | `Arrow` | Typeclass |
| `arr` | `arr` | Method |
| `first` | `first` | Method |
| `second` | `second` | Method |
| `split` | `(***)` | Method |
| `ArrowChoice` class | `ArrowChoice` | Typeclass |
| `left` | `left` | Method |
| `right` | `right` | Method |
| `fanin` | `(|||)` | Method |

## Instances
- `Arrow Fun`
- `ArrowChoice Fun`

## Proofs & Guarantees
None listed (laws follow from `LawfulCategory` and the arrow laws).

## Example
```lean
-- Lift a pure function into the Arrow
(Arrow.arr (Cat := Fun) (· * 2)).apply 3
-- => 6
```
