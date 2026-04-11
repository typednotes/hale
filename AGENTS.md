# Std project

This library provides functionalities heavily inspired by haskell popular libraries but with a maximalist stance on typing.

## Typing approach

**Mantra: Extensive typing/proving with no compromise on performance.**

We'd like our implementations to explicitly state and prove the guarantees they provide.

Ideally the types give information about
- correctness
- useful properties and invariants
- performance guarantees
- algorithmic complexity
- resource usage

when proofs are feasible.

## Lazy vs Strict Evaluation

Haskell is lazily evaluated while Lean is strictly evaluated. When porting Haskell code, be aware that some idioms rely on laziness (e.g., infinite lists, guarded recursion, lazy fields in data types). Use `Stream` or `Thunk` in Lean to emulate Haskell's lazy behavior when necessary.

## Haskell → Lean Module Mapping

Use the `/haskell-mapping` skill to look up the full Haskell-to-Lean module mapping tables and folder organization policy.

## Module Organization

- **Foundational:** Basic types and combinators — `Void`, `Function`, `Newtype`
- **Core Abstractions:** Functor variants and composition — `Bifunctor`, `Contravariant`, `Const`, `Identity`, `Compose`, `Category`
- **Data Structures:** Concrete data types — `NonEmpty`, `Either`, `Ord`, `Tuple`
- **Traversals:** Fold and traverse abstractions — `Foldable`, `Traversable`
- **Numeric Types:** Exact arithmetic — `Ratio`, `Complex`, `Fixed`
- **Advanced Abstractions:** Arrow computations — `Arrow`
- **Concurrency:** Thread management and synchronisation — `Concurrent`, `MVar`, `Chan`, `QSem`, `QSemN`

## Build & Test

```bash
# Nix users: enter shell with OpenSSL + pkg-config
nix-shell

# Build the library (requires pkg-config openssl)
lake build

# Run smoke tests
lake exe hale

# Build and run the test suite
lake build hale-tests
lake exe hale-tests

# Run Haskell cross-verification (requires GHC)
bash tests/cross-check/run-all.sh
```

## Porting Approach

When porting a Haskell library:

1. **Same API, adapted implementation.** Port the same public API surface. Use the same implementation approach unless Lean's standard library provides a better backing (e.g., `ByteArray`, `HashMap`, `Array`, `IO.FS`) or language differences (lazy vs strict evaluation) make a different implementation more appropriate.
2. **Port the value-add:** Focus on typed invariants, O(1) slicing, algebraic proofs, and API surface that Lean lacks.
3. **Port transitive dependencies first.** If the Haskell library depends on another unported Haskell library, port that dependency before proceeding.
4. **Lean stdlib preference:** When Lean's stdlib already provides equivalent functionality, use it as the backing implementation and provide Haskell-compatible naming on top.
5. **Cross-platform C FFI / glibc wrappers:** When porting libraries that wrap OS/glibc facilities (sockets, file I/O, signals, etc.), get inspiration from **both** Haskell's implementation and **Lean's standard library** (`Init.System`, `Std.Internal`). Use `#ifdef` guards for platform-specific code (macOS/kqueue, Linux/epoll). Target macOS and Linux first; Windows support can be added later. Always return proper `IO.Error` from C FFI — never crash or segfault.
6. **FFI preferred for glibc, implementation preferred otherwise:** C FFI should be the default approach for wrapping glibc/OS system calls (sockets, file descriptors, signals, process management, etc.) — these are inherently C APIs and FFI gives the best fidelity. For everything else (protocol logic, data structures, algorithms, type-level guarantees), prefer a native Lean implementation. This gives us proofs, type safety, and platform independence where it matters most.
7. **Maximalist typing for FFI protocols:** When an FFI-wrapped resource implements a protocol (TCP, QUIC, HTTP/2, etc.), the Lean types should encode the main constraints and guarantees of the protocol. For example: a socket in LISTEN state should have a different type than a connected socket; a QUIC stream ID should carry its directionality (client/server, bidi/uni) in the type; an HTTP/2 stream should encode its lifecycle state. Use opaque types, phantom type parameters, and proof obligations to make protocol violations unrepresentable.
8. **Align with official Lean FFI patterns:** Follow the Lean 4 standard library's C FFI conventions exactly. Reference implementation: [Std.Internal.Async.TCP](https://github.com/leanprover/lean4/blob/8f6411ad576cc0bec3e9a891c60df223da300a71/stage0/stdlib/Std/Internal/Async/TCP.c#L58). Key patterns:
   - Use `lean_alloc_external` with `lean_register_external_class` for opaque OS handles (sockets, file descriptors, event loops) — NOT `lean_box(fd)` / `USize`
   - Register a finalizer that closes the resource on GC (e.g., `close(fd)`)
   - Use `lean_get_external_data` to extract the handle in C functions
   - Declare the Lean type as `opaque FooHandle : NonemptyType` / `def Foo := FooHandle.type`
   - FFI functions take `@& Foo` (borrowed reference) or `Foo` (owned)

## Haskell Cross-Verification

Every ported module must be cross-verified against Haskell's actual behavior:

1. **Haskell reference program:** `Tests/cross-check/haskell/<Module>.hs` — exercises key operations and prints deterministic output.
2. **Lean smoke test:** `Main.lean` (or a dedicated exe) produces identical output lines.
3. **Shell script:** `Tests/cross-check/check-<module>.sh` compares the outputs.
4. **Coverage targets:** construction, basic operations, edge cases (empty input, single element, boundaries), typeclass behavior (Eq, Ord, Monoid), and I/O roundtrips.
5. **Run all:** `bash Tests/cross-check/run-all.sh`

## For Downstream Porters

To port a Haskell library that depends on `base`, depend on `hale` for the base types. The mapping table above shows which Lean module corresponds to each Haskell `base` module.

## Adding Missing Modules or Functions

When porting a Haskell package that depends on `base` or on an already-ported package, you may discover that a module or function is missing from `hale`. In that case, add it directly to the appropriate dependency (`hale` for `base`, or the corresponding ported package) with the same level of rigor:

1. **Maximalist typing:** Encode correctness proofs, invariants, and guarantees in the types (see "Typing approach" above)
2. **Lawful instances:** If adding a typeclass instance, prove the relevant laws (identity, composition, associativity, etc.)
3. **Lean tests:** Add tests in `Tests/<HaskellPath>/Test<Module>.lean` covering construction, operations, instance behavior, and edge cases (e.g., `Tests/Control/TestMVar.lean` for `Control.Concurrent.MVar`)
4. **Documentation:** Add or update the corresponding `docs/<HaskellPath>/<Module>.md` with API mapping, instances, proofs, and examples (e.g., `docs/Control/MVar.md`)
5. **Cross-check (when applicable):** If the function has observable output, add a Haskell cross-verification script in `tests/cross-check/`
6. **Update the mapping table:** Keep the Haskell-to-Lean mapping in this file and in `README.md` up to date

Do not add the missing functionality in the downstream package — always contribute it back to the ported dependency so all downstream consumers benefit.

## Documentation Coverage Requirement

Every library (top-level directory under `Hale/`) **must** have corresponding documentation and be listed in the project index files. When adding or modifying code, ensure:

1. **Per-library docs:** A `docs/<LibName>/README.md` must exist for every `Hale/<LibName>/` directory, following the established format (title, Lean/Haskell package mapping, key types, API, files list)
2. **README.md:** Every library must appear in the appropriate table in the top-level `README.md` (Core Infrastructure, Networking, HTTP, Web Application Interface, Utilities, or Data)
3. **SUMMARY.md:** Every library must be listed in `docs/SUMMARY.md` so it appears in the mdBook navigation
4. **AGENTS.md mapping table:** Every library and its modules must be listed in the Haskell → Lean module mapping table in this file
5. **Counts stay accurate:** The library and module counts in `README.md` must reflect the actual numbers

When adding a new library, update all four files (docs README, README.md, SUMMARY.md, AGENTS.md) in the same change. When removing or renaming a library, update all references accordingly.

## Documentation Standards

Every public definition and module must be documented:

1. **Module-level docstring:** Purpose, design rationale, typing guarantees, axiom-dependent properties
2. **Definition-level docstring:** Include LaTeX equations for the type signature (e.g., `$$\text{take} : \text{MVar}\ \alpha \to \text{BaseIO}\ (\text{Task}\ \alpha)$$`)
3. **Docs folder:** Each module gets a corresponding `docs/<HaskellPath>/<Module>.md` with:
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

## Proofs on Objects, Not Wrapper Types

**Principle:** Proofs and invariants must be added directly to the original type, not by creating a new wrapper type that carries the original plus a proof. Lean 4 erases proof terms at compile time, so proof fields on structures are zero-cost.

**Good (proof ON the object):**
```lean
structure Settings where
  settingsTimeout : Nat := 30
  timeout_pos : settingsTimeout > 0 := by omega   -- proof field, erased at runtime
```

```lean
structure Socket (state : SocketState) where        -- phantom param on original type
  raw : RawSocket
```

**Bad (wrapper carrying proof ABOUT another object):**
```lean
-- DON'T: creates a separate type just to pair an object with a proof
structure ValidSettings where
  settings : Settings
  timeout_pos : settings.settingsTimeout > 0
```

**Rationale:**
- Wrapper types obscure invariants by placing them outside the primary type
- They force users to unwrap (`.settings`, `.headers`) to access the data
- They duplicate the type surface (users must choose between `Settings` and `ValidSettings`)
- Proofs embedded directly in the structure are guaranteed by construction — no separate validation step
- This matches the established pattern in `Ratio` (`den_pos`, `coprime` are fields) and `Socket` (`SocketState` is a phantom parameter)

**When the original type is opaque or external:** use phantom type parameters (e.g., `Socket (state : SocketState)`) or standalone theorems about the type (e.g., `theorem status200_valid`). Never wrap it.

## Code Simplification Review

Before finalising any module, review for simplification:

1. **Factor common patterns:** If two functions share >50% of their logic, extract a shared helper
2. **Avoid redundant state copies:** Use `modify` over `get`/`set` when the entire state changes
3. **Prefer `Std.Mutex.atomically` with direct state operations** over manual lock/unlock
4. **No `sorry` allowed:** The codebase is `sorry`-free and must stay that way. Every proof obligation must be discharged with a real proof. Use `DataFrame.map_column_aligned` or `Array.getElem_map`/`Array.size_map` patterns for DataFrame alignment proofs. Every `panic!` must be unreachable by construction

## Standard Test Porting Procedure

### Port upstream Haskell tests

Every ported module must also port the corresponding Haskell test suite. The upstream tests are the primary source of test coverage — they define what behavior the port must match. Ported Haskell tests become part of the validation harness and must pass during generation.

### Proofs over tests

When porting a Haskell test, always ask: **can this test be expressed as a proof embedded in the types?** A type-checking theorem is strictly stronger than a runtime test — it holds for all inputs, not just the tested ones, and never needs to be run.

**Preference hierarchy:**
1. **Proof in source** (theorem in the module) — strongest, covers all cases, verified at compile time
2. **Runtime test in `Tests/`** — for IO, opaque primitives, or properties that are infeasible to prove
3. **No `sorry`** — all proof obligations must be fully discharged; `sorry` is forbidden in production code

**Examples of tests that become proofs:**
- "map id = id" → `theorem map_id (x : F α) : id <$> x = x := rfl`
- "pure a >>= f = f a" → `theorem pure_bind ...`
- "conjugate (conjugate z) = z" → `theorem conjugate_conjugate ...`
- "partition preserves length" → `theorem partitionEithers_length ...`

**Tests that stay as tests:**
- IO roundtrips (write then read back)
- Opaque ByteArray operations
- Concrete numeric edge cases (overflow, rounding)
- Thunk/lazy evaluation behavior

### Coverage rule

Every public `def`, `instance`, `structure`, `class`, or `theorem` must be covered by either a proof or a runtime test.

**Coverage table:**

| Category | Required |
|---|---|
| Typeclass instance | All laws (identity, composition, associativity) — prefer as proofs |
| Algebraic operation | Identity, commutativity, associativity, inverse — prefer as proofs |
| Constructor | Construction + accessor roundtrip |
| Conversion | Roundtrip identity (`pack`/`unpack`, `toStrict`/`fromStrict`) — prove when possible |
| Predicate | True case, false case, empty-input edge case |
| Fold/traversal | Empty, singleton, multi-element |

**Coverage header comment** required in each test file listing:
- Proofs in source (covered by type-checking)
- Tested here (runtime tests)
- Not yet covered (tracking gaps)

**`proofCovered` helper:** Use `proofCovered` in `Tests/Harness.lean` to record proof-based coverage in test output — a theorem in source always passes, but appears in the report.
