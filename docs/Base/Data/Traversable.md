# Traversable
**Lean:** `LeanStd.Base.Traversable` | **Haskell:** `Data.Traversable`

## Overview
Typeclass for structures that can be traversed with effects. Extends `Functor` by allowing each element to produce an applicative effect, then collecting those effects.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Traversable` class | `Traversable` | Typeclass |
| `traverse` | `traverse` | Method |
| `sequence` | `sequenceA` | Method |
| `LawfulTraversable` | (lawful) | Typeclass |

## Instances
- `Traversable List`
- `Traversable Option`
- `Traversable NonEmpty`

**Note:** `Either α` cannot have a `Traversable` instance due to universe constraints in Lean 4.

## Proofs & Guarantees
- `traverse_identity` — traversing with the identity applicative is just `map` (via `LawfulTraversable`)

## Example
```lean
-- Sequence a list of Options: all must be Some to get Some
Traversable.sequence [some 1, some 2, some 3]
-- => some [1, 2, 3]

Traversable.sequence [some 1, none, some 3]
-- => none
```
