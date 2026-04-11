/-
  Hale.Mtl.Control.Monad.Reader — ReaderT / Reader Haskell-compatible API

  Provides the Haskell-named combinators for `ReaderT` and `Reader`.
  Lean 4's prelude already defines `ReaderT`; this module re-exports it
  and adds Haskell-compatible function names.

  ## Design

  Lean 4 already provides:
  - `ReaderT ρ m α` — the reader monad transformer
  - `read` — read the environment (Lean name for Haskell's `ask`)
  - `ReaderT.adapt` — modify the environment (Lean name for Haskell's `local`)
  - `ReaderT.run` — run with a given environment

  This module adds:
  - `Reader ρ α` — type alias for `ReaderT ρ Id α`
  - `ask` — Haskell MTL name for `read`
  - `asks` — project a function over the environment
  - `local` — Haskell MTL name for `ReaderT.adapt`
  - `runReaderT` — Haskell name for `ReaderT.run`
  - `mapReaderT` — map over the inner computation

  ## Haskell source

  https://hackage.haskell.org/package/mtl-2.3.1/docs/Control-Monad-Reader.html
-/

namespace Control.Monad.Reader

/-- The `Reader` monad: `ReaderT` over `Id`.

    $$\text{Reader}\ \rho\ \alpha = \text{ReaderT}\ \rho\ \text{Id}\ \alpha = \rho \to \alpha$$ -/
abbrev Reader (ρ : Type) (α : Type) := ReaderT ρ Id α

/-- Read the environment.

    $$\text{ask} : \text{ReaderT}\ \rho\ m\ \rho$$

    Alias for Lean's `read`. -/
@[inline] def ask [Monad m] : ReaderT ρ m ρ :=
  read

/-- Project a function over the environment.

    $$\text{asks}(f) = f \circ \text{ask}$$

    Equivalent to `f <$> ask`. -/
@[inline] def asks [Monad m] (f : ρ → α) : ReaderT ρ m α :=
  f <$> read

/-- Run a computation in a modified environment.

    $$\text{local}(f, ma) : \text{ReaderT}\ \rho\ m\ \alpha$$

    Runs `ma` with the environment transformed by `f`.
    Alias for Lean's `ReaderT.adapt`. -/
@[inline] def «local» (f : ρ → ρ) (ma : ReaderT ρ m α) : ReaderT ρ m α :=
  ReaderT.adapt f ma

/-- Run a `ReaderT` computation with a given environment.

    $$\text{runReaderT}(ma, \rho) : m\ \alpha$$

    Alias for `ReaderT.run`. -/
@[inline] def runReaderT (ma : ReaderT ρ m α) (env : ρ) : m α :=
  ma.run env

/-- Run a `Reader` computation with a given environment.

    $$\text{runReader}(ma, \rho) : \alpha$$ -/
@[inline] def runReader (ma : Reader ρ α) (env : ρ) : α :=
  ma.run env

/-- Map over the inner monadic computation.

    $$\text{mapReaderT}(f, ma) : \text{ReaderT}\ \rho\ n\ \beta$$

    where $f : m\ \alpha \to n\ \beta$. -/
@[inline] def mapReaderT (f : m α → n β) (ma : ReaderT ρ m α) : ReaderT ρ n β :=
  fun env => f (ma.run env)

-- ── Proofs ──────────────────────────────────────────

/-- `ask` returns the environment: `runReaderT ask env = pure env`.
    $$\text{runReaderT}(\text{ask}, \rho) = \text{pure}(\rho)$$ -/
theorem ask_run [Monad m] (env : ρ) :
    runReaderT (ask : ReaderT ρ m ρ) env = pure env := rfl

/-- `local id` is identity: does not change the computation.
    $$\text{local}(\text{id}, ma) = ma$$ -/
theorem local_id (ma : ReaderT ρ m α) : «local» id ma = ma := by
  rfl

/-- `runReader` of `pure a` returns `a`.
    $$\text{runReader}(\text{pure}\ a, \rho) = a$$ -/
theorem runReader_pure (a : α) (env : ρ) : runReader (pure a : Reader ρ α) env = a := rfl

end Control.Monad.Reader
