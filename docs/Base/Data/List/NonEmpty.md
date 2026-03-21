# NonEmpty
**Lean:** `LeanStd.Base.NonEmpty` | **Haskell:** `Data.List.NonEmpty`

## Overview
Non-empty list with a guaranteed minimum of one element. The `length` function returns a subtype `{n : Nat // n >= 1}`, encoding the non-emptiness invariant at the type level.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `NonEmpty` | `NonEmpty` | Type |
| `head` | `head` | Accessor |
| `last` | `last` | Accessor |
| `length` | `length` | Function |
| `toList` | `toList` | Function |
| `singleton` | `singleton` | Constructor |
| `cons` | `cons` | Constructor |
| `append` | `append` | Function |
| `map` | `map` | Function |
| `reverse` | `reverse` | Function |
| `foldr` | `foldr` | Function |
| `foldr1` | `foldr1` | Function |
| `foldl1` | `foldl1` | Function |
| `fromList?` | `nonEmpty` | Function |
| `fromList` | `fromList` | Function |

## Instances
- `Append (NonEmpty a)`
- `Functor NonEmpty`
- `Pure NonEmpty`
- `Bind NonEmpty`
- `Monad NonEmpty`
- `ToString (NonEmpty a)` (requires `ToString a`)
- `BEq (NonEmpty a)` (derived)
- `Ord (NonEmpty a)` (derived)
- `Repr (NonEmpty a)` (derived)
- `Hashable (NonEmpty a)` (derived)

## Proofs & Guarantees
- `toList_ne_nil` — `toList ne != []` (the list is never empty)
- `reverse_length` — reversing preserves length
- `toList_length` — `toList` length agrees with `NonEmpty.length`
- `map_length` — mapping preserves length

## Example
```lean
-- Construct a non-empty list
let ne := NonEmpty.mk 1 [2, 3]
ne.head    -- => 1
ne.last    -- => 3
ne.length  -- => ⟨3, by omega⟩
```
