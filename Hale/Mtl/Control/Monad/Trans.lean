/-
  Hale.Mtl.Control.Monad.Trans — MonadTrans class

  Provides the `MonadTrans` typeclass from Haskell's `mtl`, which
  abstracts over monad transformers. Lean 4 has `MonadLift` which serves
  a similar purpose, but `MonadTrans` is the standard Haskell API name.

  ## Design

  $$\text{MonadTrans}\ t \implies \forall m.\; \text{Monad}\ m \to
    \text{lift} : m\ \alpha \to t\ m\ \alpha$$

  ## Laws

  - `lift (pure a) = pure a` (identity)
  - `lift (m >>= f) = lift m >>= (lift ∘ f)` (composition)

  ## Haskell source

  https://hackage.haskell.org/package/mtl-2.3.1/docs/Control-Monad-Trans.html
-/

namespace Control.Monad.Trans

/-- The `MonadTrans` class abstracts the `lift` operation for monad transformers.

    $$\text{lift} : m\ \alpha \to t\ m\ \alpha$$

    Transforms a computation in the inner monad `m` into one in the
    transformed monad `t m`. -/
class MonadTrans (t : (Type → Type) → Type → Type) where
  /-- Lift a computation from the inner monad into the transformer. -/
  lift : [Monad m] → m α → t m α

-- ── Instances ─────────────────────────────────────

/-- `ExceptT` lifts by wrapping the inner result in `Except.ok`. -/
instance : MonadTrans (ExceptT ε) where
  lift ma := ExceptT.mk (Except.ok <$> ma)

/-- `ReaderT` lifts by ignoring the environment. -/
instance : MonadTrans (ReaderT ρ) where
  lift ma := fun _ => ma

/-- `StateT` lifts by threading the state through unchanged. -/
instance : MonadTrans (StateT σ) where
  lift ma := fun s => do
    let a ← ma
    pure (a, s)

-- ── Laws ─────────────────────────────────────────

/-- `ReaderT.lift` preserves `pure`: `lift (pure a) = pure a`.
    $$\text{lift}(\text{pure}\ a) = \text{pure}\ a$$ -/
theorem readerT_lift_pure [Monad m] (a : α) :
    (MonadTrans.lift (t := ReaderT ρ) (pure a) : ReaderT ρ m α) = pure a := rfl

/-- `ExceptT.lift` preserves `pure`: `lift (pure a) = pure a`.
    $$\text{lift}(\text{pure}\ a) = \text{pure}\ a$$ -/
theorem exceptT_lift_pure [Monad m] [LawfulMonad m] (a : α) :
    (MonadTrans.lift (t := ExceptT ε) (pure a) : ExceptT ε m α) = pure a := by
  simp [MonadTrans.lift, ExceptT.mk, ExceptT.pure, pure]

/-- `StateT.lift` preserves `pure`: `lift (pure a) = pure a`.
    $$\text{lift}(\text{pure}\ a) = \text{pure}\ a$$ -/
theorem stateT_lift_pure [Monad m] [LawfulMonad m] (a : α) :
    (MonadTrans.lift (t := StateT σ) (pure a) : StateT σ m α) = pure a := by
  funext s
  simp [MonadTrans.lift, pure, StateT.pure]

end Control.Monad.Trans
