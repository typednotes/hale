/-
  LeanStd.Base.Const — The constant functor

  `Const α β` holds a value of type `α`, ignoring `β`.
  Useful for accumulating in traversals.
-/

namespace Data.Functor

/-- The **constant functor** $\text{Const}\;\alpha\;\beta$: carries a value of type $\alpha$,
    with a phantom type parameter $\beta$.

    $$\text{Const}\;\alpha\;\beta \;\cong\; \alpha$$

    As a functor in $\beta$, mapping is a no-op (the $\beta$ is phantom).
    As an applicative (when $\alpha$ has `Append`), `<*>` accumulates the $\alpha$ values.
    This makes `Const` the key ingredient for implementing `foldMap` via `traverse`. -/
structure Const (α : Type u) (β : Type v) where
  /-- Extract the wrapped value. -/
  getConst : α

namespace Const

/-- `BEq` instance for `Const α β`: compares the underlying $\alpha$ values,
    ignoring the phantom $\beta$. -/
instance [BEq α] : BEq (Const α β) where
  beq a b := a.getConst == b.getConst

/-- `Ord` instance for `Const α β`: orders by the underlying $\alpha$ values. -/
instance [Ord α] : Ord (Const α β) where
  compare a b := compare a.getConst b.getConst

/-- `Repr` instance for `Const α β`: delegates to the underlying $\alpha$ representation. -/
instance [Repr α] : Repr (Const α β) where
  reprPrec c p := Repr.reprPrec c.getConst p

/-- `ToString` instance for `Const α β`: delegates to `ToString α`. -/
instance [ToString α] : ToString (Const α β) where
  toString c := toString c.getConst

/-- `Functor` instance for `Const α`: mapping over the phantom parameter is a no-op.

    $$\text{fmap}\;f\;(\text{Const}\;a) = \text{Const}\;a$$

    The function $f : \beta \to \gamma$ is discarded since no $\beta$ value exists to apply it to. -/
instance : Functor (Const α) where
  map _ c := ⟨c.getConst⟩

/-- Mapping preserves the underlying value:
    $(\text{fmap}\;f\;c).\text{getConst} = c.\text{getConst}$. -/
theorem map_val (f : β → γ) (c : Const α β) :
    (f <$> c).getConst = c.getConst := rfl

/-- **Identity law:** $\text{fmap}\;\text{id} = \text{id}$ for `Const`. -/
theorem map_id (c : Const α β) :
    (id <$> c) = c := rfl

/-- **Composition law:**
    $\text{fmap}\;(f \circ g) = \text{fmap}\;f \circ \text{fmap}\;g$ for `Const`. -/
theorem map_comp (f : γ → δ) (g : β → γ) (c : Const α β) :
    (f ∘ g) <$> c = f <$> (g <$> c) := rfl

/-- `Pure` instance for `Const α` (requires `Append α` and `Inhabited α`):
    $\text{pure}\;\_= \text{Const}(\text{default})$.

    The value is the monoidal identity (`default`), since `pure` should be
    the identity element for applicative combination. -/
instance [Append α] [Inhabited α] : Pure (Const α) where
  pure _ := ⟨default⟩

end Const
end Data.Functor
