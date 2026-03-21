# Category
**Lean:** `LeanStd.Base.Category` | **Haskell:** `Control.Category`

## Overview
Abstract category with identity and composition. Uses diagrammatic order (`f >>> g = g . f`), which reads left-to-right as a pipeline.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Category` class | `Category` | Typeclass |
| `Category.id` | `id` | Method |
| `Category.comp` / `>>>` | `>>>` | Method |
| `Fun` | `(->)` | Type |
| `LawfulCategory` class | *(lawful)* | Typeclass |

## Instances
- `Category Fun` — the function arrow as a category
- `LawfulCategory Fun` — all three laws hold definitionally

## Proofs & Guarantees
- `id_comp` — `id >>> f = f` (via `LawfulCategory`)
- `comp_id` — `f >>> id = f` (via `LawfulCategory`)
- `comp_assoc` — `(f >>> g) >>> h = f >>> (g >>> h)` (via `LawfulCategory`)

## Example
```lean
-- Compose functions in diagrammatic (left-to-right) order
(Fun.mk (· + 1) >>> Fun.mk (· * 2)).apply 3
-- => 8  (first add 1, then multiply by 2)
```
