# Vault -- Type-Safe Heterogeneous Map

**Lean:** `Hale.Vault` | **Haskell:** `vault`

Type-safe heterogeneous container keyed by `Key α` tokens. Backed by `Std.HashMap` mapping unique `Nat` IDs to type-erased values.

## Key Types

| Type | Description |
|------|-------------|
| `Key α` | Typed key (globally unique) |
| `Vault` | Heterogeneous map |

## Axiom-Dependent Properties
- Type safety of `lookup` depends on axiom that `unsafeCast` is safe when the original value was of type `α`

## Files
- `Hale/Vault/Data/Vault.lean` -- Key, Vault, insert, lookup, delete
