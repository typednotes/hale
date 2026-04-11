# DataDefault -- Default Values

**Lean:** `Hale.DataDefault` | **Haskell:** `data-default`

`Default` typeclass providing sensible starting values, distinct from `Inhabited`.

## Key Types

```lean
class Default (α : Type) where
  default : α
```

Instances for: `Bool`, `Nat`, `Int`, `String`, `List`, `Array`, `Option`, `Unit`, products.

## Files
- `Hale/DataDefault/Data/Default.lean` -- Default class and instances
