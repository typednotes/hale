# Ratio
**Lean:** `LeanStd.Base.Ratio` | **Haskell:** `Data.Ratio`

## Overview
Exact rational arithmetic. Invariants are enforced in the type: the denominator is always positive and the numerator and denominator are always coprime.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Ratio` | `Ratio` / `Rational` | Type |
| `mk'` | `%` | Constructor |
| `fromInt` | `fromIntegral` | Constructor |
| `fromNat` | `fromIntegral` | Constructor |
| `neg` | `negate` | Function |
| `abs` | `abs` | Function |
| `add` | `(+)` | Function |
| `sub` | `(-)` | Function |
| `mul` | `(*)` | Function |
| `inv` | `recip` | Function |
| `div` | `(/)` | Function |
| `floor` | `floor` | Function |
| `ceil` | `ceiling` | Function |
| `round` | `round` | Function |
| `zero` | `0` | Constant |
| `one` | `1` | Constant |

## Instances
- `OfNat Ratio 0` / `OfNat Ratio 1`
- `Inhabited Ratio`
- `LE Ratio` / `LT Ratio`
- `BEq Ratio`
- `Ord Ratio`
- `Add Ratio` / `Sub Ratio` / `Mul Ratio` / `Neg Ratio`
- `ToString Ratio`

## Proofs & Guarantees
Invariants maintained by construction via the `den_pos` and `coprime` fields in the `Ratio` structure:
- Denominator is always positive
- Numerator and denominator are always coprime

## Example
```lean
-- Exact rational arithmetic: 1/2 + 1/3 = 5/6
Ratio.mk' 1 2 (by omega) + Ratio.mk' 1 3 (by omega)
-- => 5/6
```
