/-
  LeanStd.Base.Traversable — Traversable typeclass

  Structures that can be traversed with an applicative effect.

  ## Design

  `Traversable` extends `Functor` and requires `Foldable`.
  Provides `traverse` and `sequence` operations.
-/

import LeanStd.Base.Foldable
import LeanStd.Base.Identity

namespace LeanStd

/-- `Traversable` captures structures that can be traversed left-to-right,
    performing an applicative action at each element and collecting results.

    For a traversable $T$ and applicative $G$:
    $$\text{traverse} : (\alpha \to G\,\beta) \to T\,\alpha \to G\,(T\,\beta)$$
    $$\text{sequence} : T\,(G\,\alpha) \to G\,(T\,\alpha)$$

    The key insight: `traverse` generalizes both `map` (using `Identity`)
    and `foldMap` (using `Const`). -/
class Traversable (T : Type u → Type u) extends Functor T where
  /-- Traverse a structure, applying an effectful function to each element
      and collecting results.
      $$\text{traverse}(f, [x_1, \ldots, x_n]) = f(x_1) \circledast f(x_2) \circledast \cdots \circledast f(x_n)$$
      where $\circledast$ denotes applicative combination. -/
  traverse {G : Type u → Type u} [Applicative G] : (α → G β) → T α → G (T β)

namespace Traversable

/-- Sequence effectful values left-to-right.
    $$\text{sequence}([m_1, \ldots, m_n]) = m_1 \circledast m_2 \circledast \cdots \circledast m_n$$
    Equivalent to `traverse id`. -/
@[inline] def sequence [Traversable T] {G : Type u → Type u} [Applicative G]
    (t : T (G α)) : G (T α) :=
  Traversable.traverse id t

end Traversable

/-- Laws for a lawful traversable functor.

    **Identity:** Traversing with `pure` is `pure`.
    $$\text{traverse}(\text{pure}) = \text{pure}$$

    **Naturality:** Natural transformations commute with `traverse`. -/
class LawfulTraversable (T : Type u → Type u) [Traversable T] : Prop where
  /-- Traversing with `pure` (Identity) is identity.
      $$\text{traverse}(\text{Identity.mk}) = \text{Identity.mk}$$
  -/
  traverse_identity : ∀ (t : T α),
    Traversable.traverse (G := Identity) Identity.mk t = Identity.mk t

-- ── Instances ──────────────────────────────────

instance : Traversable List where
  traverse f l :=
    l.foldr (fun a acc => (· :: ·) <$> f a <*> acc) (pure [])

instance : Traversable Option where
  traverse f
    | some a => some <$> f a
    | none => pure none

instance : Traversable NonEmpty where
  traverse f ne :=
    let head := f ne.head
    let tail := ne.tail.foldr (fun a acc => (· :: ·) <$> f a <*> acc) (pure [])
    NonEmpty.mk <$> head <*> tail

-- Note: `Either α` cannot have a `Traversable` instance due to universe constraints.
-- `Either (α : Type u) (β : Type v)` gives `Either α : Type v → Type (max u v)`,
-- which doesn't match `Type u → Type u` required by `Traversable`.

end LeanStd
