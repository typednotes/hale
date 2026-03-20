# Std project

This library provides functionalities heavily inspired by haskell popular libraries but with a maximalist stance on typing.

## Typing approach

We'd like our implementations to explicitly state and prove the guarantees they provide.

Ideally the types give information about
- correctness
- useful properties and invariants
- performance guarantees
- algorithmic complexity
- resource usage

when proofs are feasible.

## Haskell → Lean Module Mapping

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

## Module Organization

- **Phase 0 (Foundational):** Basic types and combinators — `Void`, `Function`, `Newtype`
- **Phase 1 (Core Abstractions):** Functor variants and composition — `Bifunctor`, `Contravariant`, `Const`, `Identity`, `Compose`, `Category`
- **Phase 2 (Data Structures):** Concrete data types — `NonEmpty`, `Either`, `Ord`, `Tuple`
- **Phase 3 (Traversals):** Fold and traverse abstractions — `Foldable`, `Traversable`
- **Phase 4 (Numeric Types):** Exact arithmetic — `Ratio`, `Complex`, `Fixed`
- **Phase 5 (Advanced Abstractions):** Arrow computations — `Arrow`

## Build & Test

```bash
# Build the library
lake build

# Run smoke tests
lake exe lean-std

# Build and run the test suite
lake build lean-std-tests
lake exe lean-std-tests

# Run Haskell cross-verification (requires GHC)
bash tests/cross-check/run-all.sh
```

## For Downstream Porters

To port a Haskell library that depends on `base`, depend on `lean-std` for the base types. The mapping table above shows which Lean module corresponds to each Haskell `base` module.

## Adding Missing Modules or Functions

When porting a Haskell package that depends on `base` or on an already-ported package, you may discover that a module or function is missing from `lean-std`. In that case, add it directly to the appropriate dependency (`lean-std` for `base`, or the corresponding ported package) with the same level of rigor:

1. **Maximalist typing:** Encode correctness proofs, invariants, and guarantees in the types (see "Typing approach" above)
2. **Lawful instances:** If adding a typeclass instance, prove the relevant laws (identity, composition, associativity, etc.)
3. **Lean tests:** Add tests in `Tests/Base/Test<Module>.lean` covering construction, operations, instance behavior, and edge cases
4. **Documentation:** Add or update the corresponding `docs/Base/<Module>.md` with API mapping, instances, proofs, and examples
5. **Cross-check (when applicable):** If the function has observable output, add a Haskell cross-verification script in `tests/cross-check/`
6. **Update the mapping table:** Keep the Haskell-to-Lean mapping in this file and in `README.md` up to date

Do not add the missing functionality in the downstream package — always contribute it back to the ported dependency so all downstream consumers benefit.