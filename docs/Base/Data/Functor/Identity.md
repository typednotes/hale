# Identity
**Lean:** `LeanStd.Base.Identity` | **Haskell:** `Data.Functor.Identity`

## Overview
Identity functor/monad — trivial wrapper. Useful as a base case for monad transformer stacks and as a witness that a computation is pure.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Identity` | `Identity` | Type |
| `runIdentity` | `runIdentity` | Accessor |

## Instances
- `Functor Identity`
- `Pure Identity`
- `Bind Identity`
- `Seq Identity`
- `Applicative Identity`
- `Monad Identity`
- `BEq (Identity a)` (derived)
- `Ord (Identity a)` (derived)
- `Repr (Identity a)` (derived)
- `Hashable (Identity a)` (derived)
- `Inhabited (Identity a)` (derived)
- `ToString (Identity a)`

## Proofs & Guarantees
- `map_id` — `Functor.map id = id`
- `map_comp` — `Functor.map (f . g) = Functor.map f . Functor.map g`
- `pure_bind` — left identity: `pure a >>= f = f a`
- `bind_pure` — right identity: `m >>= pure = m`
- `bind_assoc` — associativity: `(m >>= f) >>= g = m >>= (fun x => f x >>= g)`

## Example
```lean
-- Identity monad is just a trivial wrapper
(Identity.mk 42 >>= fun n => Identity.mk (n + 1)).runIdentity
-- => 43
```
