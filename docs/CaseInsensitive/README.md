# CaseInsensitive -- Case-Insensitive Comparison

**Lean:** `Hale.CaseInsensitive` | **Haskell:** `case-insensitive`

Wrapper type `CI α` that compares values case-insensitively while preserving the original. Stores both `original` and pre-computed `foldedCase`. Equality, ordering, and hashing use only `foldedCase`.

## Key Types

| Type | Description |
|------|-------------|
| `FoldCase α` | Typeclass with `foldCase : α → α` |
| `CI α` | Case-insensitive wrapper |

## Files
- `Hale/CaseInsensitive/Data/CaseInsensitive.lean` -- FoldCase, CI
