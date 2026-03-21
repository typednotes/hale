# Complex
**Lean:** `LeanStd.Base.Complex` | **Haskell:** `Data.Complex`

## Overview
Complex numbers parameterized by coefficient type. Supports arithmetic operations and conjugation.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Complex` | `Complex` | Type |
| `re` / `im` | `realPart` / `imagPart` | Accessor |
| `ofReal` | `(:+ 0)` | Constructor |
| `i` | `0 :+ 1` | Constant |
| `conjugate` | `conjugate` | Function |
| `magnitudeSquared` | `magnitude ^2` | Function |

## Instances
- `Inhabited (Complex a)` (requires `Inhabited a`)
- `ToString (Complex a)` (requires `ToString a`)
- `Add (Complex a)` (requires `Add a`)
- `Neg (Complex a)` (requires `Neg a`)
- `Sub (Complex a)` (requires `Sub a`)
- `Mul (Complex a)` (requires `Add a`, `Sub a`, `Mul a`)
- `BEq (Complex a)` (derived)
- `Ord (Complex a)` (derived)
- `Repr (Complex a)` (derived)
- `Hashable (Complex a)` (derived)

## Proofs & Guarantees
- `conjugate_conjugate` — `conjugate (conjugate z) = z` (involution)
- `add_comm'` — `z1 + z2 = z2 + z1`

## Example
```lean
-- Compute magnitude squared of 3 + 4i
Complex.magnitudeSquared ⟨3, 4⟩
-- => 25  (since 3^2 + 4^2 = 25)
```
