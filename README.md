# lean-std

A port of Haskell's `base` package to Lean 4 with a maximalist approach to typing.

## Overview

`lean-std` provides 19 modules covering the core functionality of Haskell's `base` library. Unlike a minimal port, types encode correctness proofs, invariants, and guarantees wherever feasible:

- **Correctness:** Lawful typeclasses (`LawfulBifunctor`, `LawfulCategory`, `LawfulTraversable`) with verified laws
- **Invariants:** `Ratio` enforces positive denominator and coprimality in its type; `NonEmpty` guarantees `length ≥ 1`
- **Proofs:** `clamp` returns `{y : α // lo ≤ y ∧ y ≤ hi}`; `Fixed.add_exact` proves addition preserves precision

## Quick Start

Add to your `lakefile.toml`:

```toml
[[require]]
name = "lean-std"
git = "<repository-url>"
rev = "main"
```

Then import:

```lean
import LeanStd
open LeanStd
```

## List of libraries to port

https://github.com/Gabriella439/post-rfc/blob/main/sotu.md

The essential ones:
- base
- binary
- bytestring
- containers
- directory
- filepath
- network
- text
- time
- transformers
- unordered-containers
- vector

Essentials for web development:
- aeson
- http-types
- wai
- warp

Solves something really well:
- hspec
- criterion
- deepseq
- lens
- unliftio

Super handy:
- attoparsec



Dependencies from:
- https://hackage.haskell.org/package/lens
- https://hackage.haskell.org/package/pandoc
- https://hackage.haskell.org/package/async
- https://hackage.haskell.org/package/bytestring

Concurrent primitives
- https://wiki.haskell.org/Concurrency

Implement an async server:
- https://hackage.haskell.org/package/warp
  - https://github.com/yesodweb/wai
- https://www.servant.dev/
  - https://github.com/haskell-servant/servant

Implement an async client:
- 

Implemented
- Base
- Control.Concurrent (MVar, Chan, QSem, QSemN, ThreadId, forkIO)


## Module Mapping

| Lean Module | Haskell Module |
|---|---|
| `LeanStd.Base.Data.Void` | `Data.Void` |
| `LeanStd.Base.Data.Function` | `Data.Function` |
| `LeanStd.Base.Data.Newtype` | `Data.Monoid` / `Data.Semigroup` |
| `LeanStd.Base.Data.Bifunctor` | `Data.Bifunctor` |
| `LeanStd.Base.Data.Functor.Contravariant` | `Data.Functor.Contravariant` |
| `LeanStd.Base.Data.Functor.Const` | `Data.Functor.Const` |
| `LeanStd.Base.Data.Functor.Identity` | `Data.Functor.Identity` |
| `LeanStd.Base.Data.Functor.Compose` | `Data.Functor.Compose` |
| `LeanStd.Base.Control.Category` | `Control.Category` |
| `LeanStd.Base.Data.List.NonEmpty` | `Data.List.NonEmpty` |
| `LeanStd.Base.Data.Either` | `Data.Either` |
| `LeanStd.Base.Data.Ord` | `Data.Ord` |
| `LeanStd.Base.Data.Tuple` | `Data.Tuple` + `Prelude` |
| `LeanStd.Base.Data.Foldable` | `Data.Foldable` |
| `LeanStd.Base.Data.Traversable` | `Data.Traversable` |
| `LeanStd.Base.Data.Ratio` | `Data.Ratio` |
| `LeanStd.Base.Data.Complex` | `Data.Complex` |
| `LeanStd.Base.Data.Fixed` | `Data.Fixed` |
| `LeanStd.Base.Control.Arrow` | `Control.Arrow` |
| `LeanStd.Base.Control.Concurrent` | `Control.Concurrent` |
| `LeanStd.Base.Control.Concurrent.MVar` | `Control.Concurrent.MVar` |
| `LeanStd.Base.Control.Concurrent.Chan` | `Control.Concurrent.Chan` |
| `LeanStd.Base.Control.Concurrent.QSem` | `Control.Concurrent.QSem` |
| `LeanStd.Base.Control.Concurrent.QSemN` | `Control.Concurrent.QSemN` |

## Typing Philosophy

Types encode not just data shapes but guarantees:

- **Correctness proofs:** Typeclass laws are stated and proved (e.g., `bimap_id`, `bind_assoc`)
- **Structural invariants:** `Ratio` carries `den_pos` and `coprime` proofs; `NonEmpty.length` returns `{n // n ≥ 1}`
- **Precision guarantees:** `Fixed.add_exact` proves fixed-point addition is lossless
- **Uniqueness:** `Void.eq_absurd` proves all functions from `Void` are equal

## Documentation

- [docs/](docs/README.md) — Per-module documentation with API mappings and examples
- [tests/](Tests/) — Lean test suite
- [tests/cross-check/](tests/cross-check/) — Haskell cross-verification scripts

## Build & Test

```bash
lake build                              # Build the library
lake exe lean-std                       # Run smoke tests
lake build lean-std-tests && lake exe lean-std-tests  # Run test suite
bash tests/cross-check/run-all.sh       # Cross-check with Haskell (requires GHC)
```

## License

See [LICENSE](LICENSE) for details.
