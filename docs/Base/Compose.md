# Compose
**Lean:** `LeanStd.Base.Compose` | **Haskell:** `Data.Functor.Compose`

## Overview
Composition of functors/applicatives. `Compose F G a` wraps `F (G a)`, allowing two functors to be composed into a single functor (or two applicatives into a single applicative).

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Compose` | `Compose` | Type |
| `getCompose` | `getCompose` | Accessor |

## Instances
- `Functor (Compose F G)` (requires `Functor F`, `Functor G`)
- `Pure (Compose F G)` (requires `Pure F`, `Pure G`)
- `Seq (Compose F G)` (requires `Seq F`, `Seq G`, `Functor F`)
- `Applicative (Compose F G)` (requires `Applicative F`, `Applicative G`)

## Proofs & Guarantees
- `map_id` — `Functor.map id = id` (with lawful functors)
- `map_comp` — `Functor.map (f . g) = Functor.map f . Functor.map g` (with lawful functors)

## Example
```lean
-- Compose List and Option into a single functor
Compose.mk [some 1, none, some 3]
-- : Compose List Option Nat
```
