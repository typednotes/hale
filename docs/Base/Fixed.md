# Fixed
**Lean:** `LeanStd.Base.Fixed` | **Haskell:** `Data.Fixed`

## Overview
Fixed-point decimal arithmetic. `Fixed p` stores integers scaled by `10^p`. Addition and subtraction are exact (no rounding).

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Fixed` | `Fixed` | Type |
| `raw` | `MkFixed` | Accessor |
| `scale` | `resolution` | Function |
| `fromInt` | `fromIntegral` | Constructor |
| `toRatio` | `toRational` | Function |

## Instances
- `Add (Fixed p)` / `Sub (Fixed p)` / `Neg (Fixed p)` / `Mul (Fixed p)`
- `OfNat (Fixed p) 0` / `OfNat (Fixed p) 1`
- `Inhabited (Fixed p)`
- `ToString (Fixed p)`

## Proofs & Guarantees
- `scale_pos` — the scale factor `10^p` is always positive
- `add_exact` — addition of fixed-point values is exact (no rounding)
- `sub_exact` — subtraction of fixed-point values is exact (no rounding)

## Example
```lean
-- Fixed-point with 2 decimal places: 3.00 + 1.57 = 4.57
Fixed.fromInt (p := 2) 3 + ⟨157⟩
-- => 4.57  (internally stored as raw 457)
```
