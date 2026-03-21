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

Reference: https://hackage.haskell.org/package/base

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

## Folder Organization Policy

The `LeanStd` project ports multiple Haskell libraries. Each Haskell library gets its own **top-level folder** named after the library (Lean naming convention). Within that folder, the **subfolder path mirrors the Haskell module path** exactly.

```
LeanStd/
  Base/                                  ← Haskell `base` library
    Data/
      Void.lean                          ← Data.Void
      Function.lean                      ← Data.Function
      Functor/
        Const.lean                       ← Data.Functor.Const
        Identity.lean                    ← Data.Functor.Identity
        Compose.lean                     ← Data.Functor.Compose
        Contravariant.lean               ← Data.Functor.Contravariant
      List/
        NonEmpty.lean                    ← Data.List.NonEmpty
      ...
    Control/
      Category.lean                      ← Control.Category
      Arrow.lean                         ← Control.Arrow
      Concurrent.lean                    ← Control.Concurrent
      Concurrent/
        MVar.lean                        ← Control.Concurrent.MVar
        Chan.lean                        ← Control.Concurrent.Chan
        ...
  Containers/                            ← Haskell `containers` (future)
    Data/
      Map.lean                           ← Data.Map
      Set.lean                           ← Data.Set
      ...
  Text/                                  ← Haskell `text` (future)
    Data/
      Text.lean                          ← Data.Text
      ...
```

**Rules:**
1. **Top-level folder = Haskell library name** in Lean naming convention (`Base` for `base`, `Containers` for `containers`, etc.)
2. **Subfolder path = Haskell module path** exactly (`Data/Functor/Const.lean` for `Data.Functor.Const`)
3. **Namespace = Haskell module path** — namespaces mirror the Haskell hierarchy, NOT the library name. Examples:
   - `LeanStd/Base/Data/Ratio.lean` → `namespace Data` (outer), `namespace Ratio` (inner for methods)
   - `LeanStd/Base/Data/Functor/Const.lean` → `namespace Data.Functor` (outer), `namespace Const` (inner)
   - `LeanStd/Base/Control/Concurrent/MVar.lean` → `namespace Control.Concurrent` (outer), `namespace MVar` (inner)
   - Users write `open Data` or `open Control.Concurrent` to access types, just like Haskell `import Data.Ratio` or `import Control.Concurrent.MVar`
4. **Sub-namespaces for methods** — use `namespace Ratio` within `namespace Data` for dot-notation methods (e.g., `Ratio.floor`)
5. **Re-export file** — each library has a re-export file (`LeanStd/Base.lean`) that imports all its modules

**Tests** mirror the Haskell module structure: `Tests/Control/TestMVar.lean` for `Control.Concurrent.MVar`.

**Docs** mirror the Haskell module structure: `docs/Control/MVar.md` for `Control.Concurrent.MVar`.

## Module Organization

- **Phase 0 (Foundational):** Basic types and combinators — `Void`, `Function`, `Newtype`
- **Phase 1 (Core Abstractions):** Functor variants and composition — `Bifunctor`, `Contravariant`, `Const`, `Identity`, `Compose`, `Category`
- **Phase 2 (Data Structures):** Concrete data types — `NonEmpty`, `Either`, `Ord`, `Tuple`
- **Phase 3 (Traversals):** Fold and traverse abstractions — `Foldable`, `Traversable`
- **Phase 4 (Numeric Types):** Exact arithmetic — `Ratio`, `Complex`, `Fixed`
- **Phase 5 (Advanced Abstractions):** Arrow computations — `Arrow`
- **Phase 6 (Concurrency):** Thread management and synchronisation — `Concurrent`, `MVar`, `Chan`, `QSem`, `QSemN`

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
3. **Lean tests:** Add tests in `Tests/<HaskellPath>/Test<Module>.lean` covering construction, operations, instance behavior, and edge cases (e.g., `Tests/Control/TestMVar.lean` for `Control.Concurrent.MVar`)
4. **Documentation:** Add or update the corresponding `docs/<HaskellPath>/<Module>.md` with API mapping, instances, proofs, and examples (e.g., `docs/Control/MVar.md`)
5. **Cross-check (when applicable):** If the function has observable output, add a Haskell cross-verification script in `tests/cross-check/`
6. **Update the mapping table:** Keep the Haskell-to-Lean mapping in this file and in `README.md` up to date

Do not add the missing functionality in the downstream package — always contribute it back to the ported dependency so all downstream consumers benefit.

## Documentation Standards

Every public definition and module must be documented:

1. **Module-level docstring:** Purpose, design rationale, typing guarantees, axiom-dependent properties
2. **Definition-level docstring:** Include LaTeX equations for the type signature (e.g., `$$\text{take} : \text{MVar}\ \alpha \to \text{BaseIO}\ (\text{Task}\ \alpha)$$`)
3. **Docs folder:** Each module gets a corresponding `docs/<Phase>/<Module>.md` with:
   - Haskell-to-Lean API mapping table
   - Instance documentation
   - Proof/invariant documentation
   - Usage examples
   - Performance/scalability notes

## Strict Typing Review

Before finalising any module, review every definition for stricter types:

1. **Return types:** Can the return type carry a proof? (e.g., `{n : Nat // n > 0}` instead of `Nat`)
2. **Arguments:** Can arguments be constrained? (e.g., `(n : Nat) (h : n > 0)` instead of bare `Nat`)
3. **Structures:** Can fields carry invariants? (e.g., state invariants as proof obligations)
4. **Type aliases:** Do they encode meaningful guarantees? (e.g., `Concurrent α := BaseIO (Task α)` encodes non-blocking)

When proofs are infeasible due to opaque runtime primitives (e.g., `Std.Mutex`, `IO.Promise`), document the invariant as an axiom-dependent property.

## Code Simplification Review

Before finalising any module, review for simplification:

1. **Factor common patterns:** If two functions share >50% of their logic, extract a shared helper
2. **Avoid redundant state copies:** Use `modify` over `get`/`set` when the entire state changes
3. **Prefer `Std.Mutex.atomically` with direct state operations** over manual lock/unlock
4. **Minimise `sorry` and `panic!`:** Every `sorry` must have a tracking comment; every `panic!` must be unreachable by construction