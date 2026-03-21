/-
  LeanStd.Base.Contravariant — Contravariant functor

  A contravariant functor reverses the direction of morphisms.
-/

namespace Data.Functor

/-- A **contravariant functor** $F : \mathsf{Type}^{\text{op}} \to \mathsf{Type}$.
Unlike a covariant functor which preserves morphism direction, a contravariant
functor reverses it: given $f : \alpha \to \beta$, we obtain

$$\text{contramap}\; f : F\;\beta \to F\;\alpha$$ -/
class Contravariant (F : Type u → Type v) where
  /-- Map contravariantly: given $f : \alpha \to \beta$, produce
  $\text{contramap}\;f : F\;\beta \to F\;\alpha$. -/
  contramap : (α → β) → F β → F α

/-- Laws for a lawful contravariant functor:

1. **Identity:** $\text{contramap}\;\text{id} = \text{id}$
2. **Composition:** $\text{contramap}\;(f \circ g) = \text{contramap}\;g \circ \text{contramap}\;f$

Note the reversal in the composition law — this is dual to the covariant functor law. -/
class LawfulContravariant (F : Type u → Type v) [Contravariant F] : Prop where
  /-- **Identity law:** $\text{contramap}\;\text{id}\;x = x$. -/
  contramap_id : ∀ (x : F α), Contravariant.contramap id x = x
  /-- **Composition law:**
  $\text{contramap}\;(f \circ g)\;x = \text{contramap}\;g\;(\text{contramap}\;f\;x)$. -/
  contramap_comp : ∀ (f : β → γ) (g : α → β) (x : F γ),
    Contravariant.contramap (f ∘ g) x = Contravariant.contramap g (Contravariant.contramap f x)

-- ── Predicate ──────────────────────────────────

/-- A predicate $P : \alpha \to \text{Prop}$, wrapped as a contravariant functor.

Given $f : \alpha \to \beta$ and a predicate $P$ on $\beta$, the contramapped
predicate is $P \circ f$, i.e., $(\text{contramap}\;f\;P)(x) = P(f(x))$. -/
structure Predicate (α : Type u) where
  getPredicate : α → Prop

/-- `Contravariant` instance for `Predicate`:
$\text{contramap}\;f\;P = P \circ f$. -/
instance : Contravariant Predicate where
  contramap f p := ⟨p.getPredicate ∘ f⟩

/-- `Predicate` is a lawful contravariant functor — both laws hold definitionally. -/
instance : LawfulContravariant Predicate where
  contramap_id _ := rfl
  contramap_comp _ _ _ := rfl

-- ── Equivalence ────────────────────────────────

/-- An equivalence relation $R : \alpha \to \alpha \to \text{Prop}$, wrapped as a
contravariant functor.

Given $f : \alpha \to \beta$ and an equivalence $R$ on $\beta$, the contramapped
equivalence is: $(\text{contramap}\;f\;R)(a, b) = R(f(a), f(b))$. -/
structure Equivalence (α : Type u) where
  getEquivalence : α → α → Prop

/-- `Contravariant` instance for `Equivalence`:
$(\text{contramap}\;f\;R)(a, b) = R(f(a),\, f(b))$. -/
instance : Contravariant Equivalence where
  contramap f e := ⟨fun a b => e.getEquivalence (f a) (f b)⟩

/-- `Equivalence` is a lawful contravariant functor — both laws hold definitionally. -/
instance : LawfulContravariant Equivalence where
  contramap_id _ := rfl
  contramap_comp _ _ _ := rfl

end Data.Functor
