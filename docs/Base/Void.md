# Void
**Lean:** `LeanStd.Base.Void` | **Haskell:** `Data.Void`

## Overview
Uninhabited type (alias for `Empty`). Provides `absurd` for ex falso reasoning.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Void` | `Void` | Type |
| `Void.absurd` | `absurd` | Function |

## Instances
- `BEq Void`
- `Ord Void`
- `ToString Void`
- `Repr Void`
- `Hashable Void`
- `Inhabited (Void -> a)` — functions from `Void` are always inhabited

## Proofs & Guarantees
- `eq_absurd` — uniqueness of void functions: any two functions from `Void` are equal

## Example
```lean
-- A function from Void to any type is unique
def fromVoid : Void -> Nat := Void.absurd
```
