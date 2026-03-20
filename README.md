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

## Module Mapping

| Lean Module | Haskell Module | Phase |
|---|---|---|
| `LeanStd.Base.Void` | `Data.Void` | 0: Foundational |
| `LeanStd.Base.Function` | `Data.Function` | 0: Foundational |
| `LeanStd.Base.Newtype` | `Data.Monoid` / `Data.Semigroup` | 0: Foundational |
| `LeanStd.Base.Bifunctor` | `Data.Bifunctor` | 1: Core Abstractions |
| `LeanStd.Base.Contravariant` | `Data.Functor.Contravariant` | 1: Core Abstractions |
| `LeanStd.Base.Const` | `Data.Functor.Const` | 1: Core Abstractions |
| `LeanStd.Base.Identity` | `Data.Functor.Identity` | 1: Core Abstractions |
| `LeanStd.Base.Compose` | `Data.Functor.Compose` | 1: Core Abstractions |
| `LeanStd.Base.Category` | `Control.Category` | 1: Core Abstractions |
| `LeanStd.Base.NonEmpty` | `Data.List.NonEmpty` | 2: Data Structures |
| `LeanStd.Base.Either` | `Data.Either` | 2: Data Structures |
| `LeanStd.Base.Ord` | `Data.Ord` | 2: Data Structures |
| `LeanStd.Base.Tuple` | `Data.Tuple` + `Prelude` | 2: Data Structures |
| `LeanStd.Base.Foldable` | `Data.Foldable` | 3: Traversals |
| `LeanStd.Base.Traversable` | `Data.Traversable` | 3: Traversals |
| `LeanStd.Base.Ratio` | `Data.Ratio` | 4: Numeric Types |
| `LeanStd.Base.Complex` | `Data.Complex` | 4: Numeric Types |
| `LeanStd.Base.Fixed` | `Data.Fixed` | 4: Numeric Types |
| `LeanStd.Base.Arrow` | `Control.Arrow` | 5: Advanced Abstractions |

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
