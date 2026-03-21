# Contravariant
**Lean:** `LeanStd.Base.Contravariant` | **Haskell:** `Data.Functor.Contravariant`

## Overview
Contravariant functors — types that consume values rather than produce them. Where a covariant functor maps over outputs, a contravariant functor maps over inputs.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Contravariant` class | `Contravariant` | Typeclass |
| `contramap` | `contramap` | Method |
| `Predicate` | `Predicate` | Type |
| `Equivalence` | `Equivalence` | Type |
| `LawfulContravariant` class | *(lawful)* | Typeclass |

## Instances
- `Contravariant Predicate`
- `Contravariant Equivalence`
- `LawfulContravariant Predicate`
- `LawfulContravariant Equivalence`

## Proofs & Guarantees
- `contramap_id` — `contramap id = id` (via `LawfulContravariant`)
- `contramap_comp` — `contramap (f . g) = contramap g . contramap f` (via `LawfulContravariant`)

## Example
```lean
-- Adapt a predicate on Nat to work on String via length
Contravariant.contramap String.length (Predicate.mk (· > 3))
-- Now accepts strings with length > 3
```
