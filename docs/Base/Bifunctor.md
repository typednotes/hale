# Bifunctor
**Lean:** `LeanStd.Base.Bifunctor` | **Haskell:** `Data.Bifunctor`

## Overview
Typeclass for types with two covariant type parameters. Provides `bimap`, `mapFst`, `mapSnd`.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Bifunctor` class | `Bifunctor` | Typeclass |
| `bimap` | `bimap` | Method |
| `mapFst` | `first` | Method |
| `mapSnd` | `second` | Method |
| `LawfulBifunctor` | (lawful) | Typeclass |

## Instances
- `Bifunctor Prod`
- `Bifunctor Sum`
- `Bifunctor Except`
- `LawfulBifunctor Prod`
- `LawfulBifunctor Sum`
- `LawfulBifunctor Except`

## Proofs & Guarantees
- `bimap_id` — `bimap id id = id` (via `LawfulBifunctor`)
- `bimap_comp` — `bimap (f1 . f2) (g1 . g2) = bimap f1 g1 . bimap f2 g2` (via `LawfulBifunctor`)

## Example
```lean
-- Map over both components of a pair
Bifunctor.bimap (· * 10) (· ++ "!") (1, "hello")
-- => (10, "hello!")
```
