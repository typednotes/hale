/-
  Hale.Mtl.Control.Monad.State — StateT / State Haskell-compatible API

  Provides the Haskell-named combinators for `StateT` and `State`.
  Lean 4's prelude already defines `StateT`; this module re-exports it
  and adds Haskell-compatible function names.

  ## Design

  Lean 4 already provides:
  - `StateT σ m α` — the state monad transformer
  - `StateT.get` — get the current state
  - `StateT.set` — replace the state
  - `StateT.modifyGet` — modify state and extract a value
  - `StateT.run` — run with an initial state, returning `(α × σ)`

  This module adds:
  - `State σ α` — type alias for `StateT σ Id α`
  - `get`, `put`, `modify`, `gets` — Haskell MTL names
  - `runStateT`, `evalStateT`, `execStateT` — Haskell MTL names
  - `runState`, `evalState`, `execState` — pure variants

  ## Haskell source

  https://hackage.haskell.org/package/mtl-2.3.1/docs/Control-Monad-State-Strict.html
-/

namespace Control.Monad.State

/-- The `State` monad: `StateT` over `Id`.

    $$\text{State}\ \sigma\ \alpha = \text{StateT}\ \sigma\ \text{Id}\ \alpha = \sigma \to (\alpha \times \sigma)$$ -/
abbrev State (σ : Type) (α : Type) := StateT σ Id α

/-- Get the current state.

    $$\text{get} : \text{StateT}\ \sigma\ m\ \sigma$$ -/
@[inline] def get [Monad m] : StateT σ m σ :=
  StateT.get

/-- Replace the state with a new value.

    $$\text{put}(\sigma) : \text{StateT}\ \sigma\ m\ \text{Unit}$$ -/
@[inline] def put [Monad m] (s : σ) : StateT σ m Unit :=
  StateT.set s

/-- Modify the state by applying a function.

    $$\text{modify}(f) : \text{StateT}\ \sigma\ m\ \text{Unit}$$ -/
@[inline] def modify [Monad m] (f : σ → σ) : StateT σ m Unit :=
  StateT.modifyGet (fun s => ((), f s))

/-- Get a projection of the current state.

    $$\text{gets}(f) = f \circ \text{get}$$

    Equivalent to `f <$> get`. -/
@[inline] def gets [Monad m] (f : σ → α) : StateT σ m α := do
  let s ← StateT.get
  pure (f s)

/-- Run a `StateT` computation with an initial state.

    $$\text{runStateT}(ma, s_0) : m\ (\alpha \times \sigma)$$

    Alias for `StateT.run`. -/
@[inline] def runStateT [Monad m] (ma : StateT σ m α) (s : σ) : m (α × σ) :=
  ma.run s

/-- Run a `StateT` computation, returning only the final value.

    $$\text{evalStateT}(ma, s_0) : m\ \alpha$$ -/
@[inline] def evalStateT [Functor m] [Monad m] (ma : StateT σ m α) (s : σ) : m α :=
  Prod.fst <$> ma.run s

/-- Run a `StateT` computation, returning only the final state.

    $$\text{execStateT}(ma, s_0) : m\ \sigma$$ -/
@[inline] def execStateT [Functor m] [Monad m] (ma : StateT σ m α) (s : σ) : m σ :=
  Prod.snd <$> ma.run s

/-- Run a pure `State` computation with an initial state.

    $$\text{runState}(ma, s_0) : \alpha \times \sigma$$ -/
@[inline] def runState (ma : State σ α) (s : σ) : α × σ :=
  ma.run s

/-- Run a pure `State` computation, returning only the final value.

    $$\text{evalState}(ma, s_0) : \alpha$$ -/
@[inline] def evalState (ma : State σ α) (s : σ) : α :=
  (ma.run s).fst

/-- Run a pure `State` computation, returning only the final state.

    $$\text{execState}(ma, s_0) : \sigma$$ -/
@[inline] def execState (ma : State σ α) (s : σ) : σ :=
  (ma.run s).snd

-- ── Proofs ──────────────────────────────────────────

/-- `runState` of `pure a` returns `(a, s)`.
    $$\text{runState}(\text{pure}\ a, s) = (a, s)$$ -/
theorem runState_pure (a : α) (s : σ) : runState (pure a : State σ α) s = (a, s) := rfl

/-- `evalState` of `pure a` returns `a`.
    $$\text{evalState}(\text{pure}\ a, s) = a$$ -/
theorem evalState_pure (a : α) (s : σ) : evalState (pure a : State σ α) s = a := rfl

/-- `execState` of `pure a` returns the initial state unchanged.
    $$\text{execState}(\text{pure}\ a, s) = s$$ -/
theorem execState_pure (a : α) (s : σ) : execState (pure a : State σ α) s = s := rfl

/-- `get` returns the current state: `runState get s = (s, s)`.
    $$\text{runState}(\text{get}, s) = (s, s)$$ -/
theorem runState_get (s : σ) : runState (get : State σ σ) s = (s, s) := rfl

/-- `put` replaces the state: `execState (put s') s = s'`.
    $$\text{execState}(\text{put}(s'), s) = s'$$ -/
theorem execState_put (s s' : σ) : execState (put s' : State σ Unit) s = s' := rfl

end Control.Monad.State
