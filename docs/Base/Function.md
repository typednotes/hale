# Function
**Lean:** `LeanStd.Base.Function` | **Haskell:** `Data.Function`

## Overview
Standard function combinators: `on`, `applyTo` (`&`), `const` (K combinator), `flip` (C combinator).

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Function.on` | `on` | Combinator |
| `Function.applyTo` | `(&)` | Combinator |
| `Function.const` | `const` | Combinator |
| `Function.flip` | `flip` | Combinator |

## Instances
None (standalone functions).

## Proofs & Guarantees
- `on_apply` — `(f.on g) x y = f (g x) (g y)`
- `applyTo_apply` — `x.applyTo f = f x`
- `const_apply` — `Function.const a b = a`
- `flip_flip` — `flip (flip f) = f` (involution)
- `flip_apply` — `Function.flip f x y = f y x`

## Example
```lean
-- Compare strings by length
Function.on (· + ·) String.length "hi" "hello"
-- => 7
```
