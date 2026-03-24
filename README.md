# hale

A port of Haskell's `base` package to Lean 4 with a maximalist approach to typing.

## Overview

`hale` provides 19 modules covering the core functionality of Haskell's `base` library. Unlike a minimal port, types encode correctness proofs, invariants, and guarantees wherever feasible:

- **Correctness:** Lawful typeclasses (`LawfulBifunctor`, `LawfulCategory`, `LawfulTraversable`) with verified laws
- **Invariants:** `Ratio` enforces positive denominator and coprimality in its type; `NonEmpty` guarantees `length ≥ 1`
- **Proofs:** `clamp` returns `{y : α // lo ≤ y ∧ y ≤ hi}`; `Fixed.add_exact` proves addition preserves precision

## Quick Start

Add to your `lakefile.toml`:

```toml
[[require]]
name = "hale"
git = "<repository-url>"
rev = "main"
```

Then import:

```lean
import Hale
open Hale
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
| `Hale.Base.Data.Void` | `Data.Void` |
| `Hale.Base.Data.Function` | `Data.Function` |
| `Hale.Base.Data.Newtype` | `Data.Monoid` / `Data.Semigroup` |
| `Hale.Base.Data.Bifunctor` | `Data.Bifunctor` |
| `Hale.Base.Data.Functor.Contravariant` | `Data.Functor.Contravariant` |
| `Hale.Base.Data.Functor.Const` | `Data.Functor.Const` |
| `Hale.Base.Data.Functor.Identity` | `Data.Functor.Identity` |
| `Hale.Base.Data.Functor.Compose` | `Data.Functor.Compose` |
| `Hale.Base.Control.Category` | `Control.Category` |
| `Hale.Base.Data.List.NonEmpty` | `Data.List.NonEmpty` |
| `Hale.Base.Data.Either` | `Data.Either` |
| `Hale.Base.Data.Ord` | `Data.Ord` |
| `Hale.Base.Data.Tuple` | `Data.Tuple` + `Prelude` |
| `Hale.Base.Data.Foldable` | `Data.Foldable` |
| `Hale.Base.Data.Traversable` | `Data.Traversable` |
| `Hale.Base.Data.Ratio` | `Data.Ratio` |
| `Hale.Base.Data.Complex` | `Data.Complex` |
| `Hale.Base.Data.Fixed` | `Data.Fixed` |
| `Hale.Base.Control.Arrow` | `Control.Arrow` |
| `Hale.Base.Control.Concurrent` | `Control.Concurrent` |
| `Hale.Base.Control.Concurrent.MVar` | `Control.Concurrent.MVar` |
| `Hale.Base.Control.Concurrent.Chan` | `Control.Concurrent.Chan` |
| `Hale.Base.Control.Concurrent.QSem` | `Control.Concurrent.QSem` |
| `Hale.Base.Control.Concurrent.QSemN` | `Control.Concurrent.QSemN` |

## Typing Philosophy

Lean 4 is a dependently-typed proof assistant that compiles to efficient native
code. Hale leverages this to turn protocol specs, resource lifecycles, and
algebraic laws into **compile-time obligations** -- verified by the kernel,
then **erased at runtime** (zero overhead).

- **Phantom state machines:** `Socket (state : SocketState)` makes it a type
  error to `send` on an unconnected socket or `close` an already-closed one
  (proof obligation: `state ≠ .closed`, discharged by `decide`)
- **Indexed monads:** `AppM .pending .sent ResponseReceived` enforces that
  a WAI application calls `respond` exactly once -- double-respond is a
  compile-time error, not a runtime crash
- **Proof-carrying structures:** `Ratio` carries `den_pos` and `coprime`
  proofs; `Settings` carries `timeout_pos` -- all erased at runtime (zero cost)
- **Algebraic laws:** 230+ theorems (`bimap_id`, `bind_assoc`, `map_id`,
  `connAction_http11_default`, ...) verified by the Lean kernel

## Documentation

- [docs/](docs/README.md) — Per-module documentation with API mappings and examples
- [tests/](Tests/) — Lean test suite
- [tests/cross-check/](tests/cross-check/) — Haskell cross-verification scripts

## Build & Test

```bash
lake build                              # Build the library
lake exe hale                       # Run smoke tests
lake build hale-tests && lake exe hale-tests  # Run test suite
bash tests/cross-check/run-all.sh       # Cross-check with Haskell (requires GHC)
```

## License

See [LICENSE](LICENSE) for details.
