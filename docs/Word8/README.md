# Word8 -- UInt8 Classification

**Lean:** `Hale.Word8` | **Haskell:** `word8`

UInt8 classification predicates and byte constants. All predicates are `@[inline]` for zero overhead. Proofs via exhaustive `native_decide` over all 256 values.

## API

| Function | Description |
|----------|-------------|
| `isUpper` | Byte in [65, 90] |
| `isLower` | Byte in [97, 122] |
| `isAlpha` | ASCII letter |
| `isDigit` | ASCII digit |
| `isSpace` | Whitespace byte |

## Files
- `Hale/Word8/Data/Word8.lean` -- Classification predicates and constants
