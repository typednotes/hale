/-
  LeanStd.Base.Compose — Functor/Applicative composition

  `Compose F G α` wraps `F (G α)`. The composition of two functors is a functor;
  the composition of two applicatives is an applicative.
-/

namespace Data.Functor

/-- Functor/applicative composition: $(\text{Compose}\;F\;G)\;\alpha = F\,(G\;\alpha)$.

    This witnesses the classical result that **the composition of two functors is a functor**,
    and **the composition of two applicatives is an applicative**.

    Use cases:
    - Combining effects: `Compose IO Option α` represents an IO action that may fail
    - Nested mapping: `map f` on `Compose F G` maps through both layers -/
structure Compose (F : Type u → Type v) (G : Type w → Type u) (α : Type w) where
  /-- Unwrap the composed value: $F\,(G\;\alpha)$. -/
  getCompose : F (G α)

namespace Compose

/-- `Functor` instance for `Compose F G`: maps through both layers.

    $$\text{fmap}\;f\;(\text{Compose}\;x) = \text{Compose}\;(\text{fmap}\;(\text{fmap}\;f)\;x)$$ -/
instance [Functor F] [Functor G] : Functor (Compose F G) where
  map f c := ⟨(f <$> ·) <$> c.getCompose⟩

/-- **Identity law** for composed functors: $\text{fmap}\;\text{id} = \text{id}$.

    If $F$ and $G$ are both lawful functors, their composition is also lawful. -/
theorem map_id [Functor F] [Functor G]
    [LawfulFunctor F] [LawfulFunctor G]
    (x : Compose F G α) :
    (id <$> x) = x := by
  simp [Functor.map, id_map]

/-- **Composition law** for composed functors:
    $\text{fmap}\;(f \circ g) = \text{fmap}\;f \circ \text{fmap}\;g$.

    Follows from the composition laws of $F$ and $G$ individually. -/
theorem map_comp [Functor F] [Functor G]
    [LawfulFunctor F] [LawfulFunctor G]
    (f : β → γ) (g : α → β) (x : Compose F G α) :
    ((f ∘ g) <$> x) = (f <$> (g <$> x)) := by
  simp [Functor.map, comp_map]

/-- `Pure` instance for `Compose F G`: wraps a value in both layers.

    $$\text{pure}\;a = \text{Compose}\;(\text{pure}\;(\text{pure}\;a))$$ -/
instance [Applicative F] [Applicative G] : Pure (Compose F G) where
  pure a := ⟨pure (pure a)⟩

/-- `Seq` instance for `Compose F G`: applies through both layers using
    the applicative structure of $F$ and $G$.

    $$\text{Compose}\;f \mathbin{<*>} \text{Compose}\;x
      = \text{Compose}\;((\mathbin{<*>}) \mathbin{<\$>} f \mathbin{<*>} x)$$ -/
instance [Applicative F] [Applicative G] : Seq (Compose F G) where
  seq f x := ⟨Seq.seq ((· <*> ·) <$> f.getCompose) (fun () => (x ()).getCompose)⟩

/-- `Applicative` instance for `Compose F G`: the composition of two applicatives
    is an applicative. -/
instance [Applicative F] [Applicative G] : Applicative (Compose F G) where

end Compose
end Data.Functor
