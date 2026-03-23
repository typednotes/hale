# ByteString

**Lean:** `Hale.ByteString` | **Haskell:** `bytestring` (https://hackage.haskell.org/package/bytestring)

> **API Reference:** [Hale.ByteString](../../Hale/ByteString.html)

## Overview

Port of Haskell's `bytestring` library to Lean 4 with maximalist typing. Provides:

- **Strict ByteString** (`Data.ByteString.ByteString`): Slice-based representation with O(1) `take`/`drop`/`splitAt`, bounds proofs in the type
- **Short ByteString** (`Data.ByteString.ShortByteString`): Thin newtype over `ByteArray` for API compatibility
- **Lazy ByteString** (`Data.ByteString.Lazy.LazyByteString`): Chunked, `Thunk`-based lazy evaluation with non-empty chunk invariant
- **Builder** (`Data.ByteString.Builder`): Continuation-based O(1) concatenation with proven Monoid laws
- **Char8** (`Data.ByteString.Char8`): Latin-1 character-oriented wrappers

## Lean Stdlib Reuse

Uses `ByteArray`, `UInt8`, `IO.FS.readBinFile`/`writeBinFile` from Lean's standard library. The port adds the slice representation, lazy chunking, and typed invariants that Lean lacks.

## Module Map

| Lean Module | Haskell Module |
|---|---|
| `Hale.ByteString.Data.ByteString.Internal` | `Data.ByteString.Internal` |
| `Hale.ByteString.Data.ByteString` | `Data.ByteString` |
| `Hale.ByteString.Data.ByteString.Char8` | `Data.ByteString.Char8` |
| `Hale.ByteString.Data.ByteString.Short` | `Data.ByteString.Short` |
| `Hale.ByteString.Data.ByteString.Lazy.Internal` | `Data.ByteString.Lazy.Internal` |
| `Hale.ByteString.Data.ByteString.Lazy` | `Data.ByteString.Lazy` |
| `Hale.ByteString.Data.ByteString.Lazy.Char8` | `Data.ByteString.Lazy.Char8` |
| `Hale.ByteString.Data.ByteString.Builder` | `Data.ByteString.Builder` |
