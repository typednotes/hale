# Newtype
**Lean:** `LeanStd.Base.Newtype` | **Haskell:** `Data.Monoid` / `Data.Semigroup`

## Overview
Monoid/semigroup wrappers: `Dual`, `Endo`, `First`, `Last`, `Sum`, `Product`, `All`, `Any`. Each wraps a value and provides an `Append` instance with specific combining semantics.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `Dual` | `Dual` | Wrapper |
| `Endo` | `Endo` | Wrapper |
| `First` | `First` | Wrapper |
| `Last` | `Last` | Wrapper |
| `Sum` / `Sum.getSum` | `Sum` / `getSum` | Wrapper |
| `Product` / `Product.getProduct` | `Product` / `getProduct` | Wrapper |
| `All` | `All` | Wrapper |
| `Any` | `Any` | Wrapper |

## Instances

**All wrappers** provide `Append`.

| Wrapper | `BEq` | `Ord` | `Repr` | `Hashable` | `ToString` |
|---------|-------|-------|--------|------------|------------|
| `Dual` | yes | yes | yes | yes | yes |
| `Sum` | yes | yes | yes | yes | yes |
| `Product` | yes | yes | yes | yes | yes |
| `All` | yes | yes | yes | yes | yes |
| `Any` | yes | yes | yes | yes | yes |
| `First` | yes | — | yes | — | yes |
| `Last` | yes | — | yes | — | yes |
| `Endo` | — | — | — | — | — |

## Proofs & Guarantees
- `append_assoc` — associativity of `Append` for each wrapper

## Example
```lean
-- Sum combines via addition
Sum.mk 3 ++ Sum.mk 4
-- => Sum 7
```
