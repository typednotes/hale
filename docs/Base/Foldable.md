# Foldable
**Lean:** `LeanStd.Base.Foldable` | **Haskell:** `Data.Foldable`

## Overview
Typeclass for structures that can be folded to a summary value. Provides a rich API with many derived operations built on top of `foldr`.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Foldable` class | `Foldable` | Typeclass |
| `foldr` | `foldr` | Method |
| `foldl` | `foldl'` | Method |
| `toList` | `toList` | Method |
| `foldMap` | `foldMap` | Function |
| `null` | `null` | Function |
| `length` | `length` | Function |
| `any` | `any` | Function |
| `all` | `all` | Function |
| `find?` | `find` | Function |
| `elem` | `elem` | Function |
| `minimum?` | `minimum` | Function |
| `maximum?` | `maximum` | Function |
| `sum` | `sum` | Function |
| `product` | `product` | Function |

## Instances
- `Foldable List`
- `Foldable Option`
- `Foldable NonEmpty`
- `Foldable (Either a)`

## Proofs & Guarantees
None listed (correctness follows from typeclass laws).

## Example
```lean
-- Sum all elements in a list
Foldable.sum [1, 2, 3]
-- => 6
```
