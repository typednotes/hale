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

## Adding Missing Modules or Functions

When porting a Haskell package that depends on `base` or on an already-ported package, you may discover that a module or function is missing from `lean-std`. In that case, add it directly to the appropriate dependency (`lean-std` for `base`, or the corresponding ported package) with the same level of rigor:

1. **Maximalist typing:** Encode correctness proofs, invariants, and guarantees in the types (see "Typing approach" above)
2. **Lawful instances:** If adding a typeclass instance, prove the relevant laws (identity, composition, associativity, etc.)
3. **Lean tests:** Add tests in `Tests/Base/Test<Module>.lean` covering construction, operations, instance behavior, and edge cases
4. **Documentation:** Add or update the corresponding `docs/Base/<Module>.md` with API mapping, instances, proofs, and examples
5. **Cross-check (when applicable):** If the function has observable output, add a Haskell cross-verification script in `tests/cross-check/`
6. **Update the mapping table:** Keep the Haskell-to-Lean mapping in `CLAUDE.md` and in `README.md` up to date

Do not add the missing functionality in the downstream package — always contribute it back to the ported dependency so all downstream consumers benefit.