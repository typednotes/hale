/-
  LeanStd.Base.Ord — Ordering utilities

  Provides `Down` for reversed ordering, `comparing`, and `clamp` with proof.
-/

namespace LeanStd

/-- `Down α` reverses the ordering of `α`.

    If $a \leq b$ in `α`, then $\text{Down}(b) \leq \text{Down}(a)$.
    Useful for sorting in descending order without custom comparators.
    $$\text{compare}_{\text{Down}}(x, y) = \text{compare}(y, x)$$
-/
structure Down (α : Type u) where
  /-- Unwrap the reversed-order value. -/
  getDown : α
deriving Repr, Hashable

namespace Down

instance [BEq α] : BEq (Down α) where
  beq a b := a.getDown == b.getDown

/-- Reversed ordering: compares in the opposite direction. -/
instance [Ord α] : Ord (Down α) where
  compare a b := compare b.getDown a.getDown

instance [ToString α] : ToString (Down α) where
  toString d := s!"Down({d.getDown})"

/-- Wrapping and unwrapping `Down` is identity.
    $$\text{getDown}(\text{Down}(x)) = x$$
-/
theorem get_mk (a : α) : (Down.mk a).getDown = a := rfl

/-- `Down` comparison reverses the arguments. -/
theorem compare_reverse [Ord α] (a b : Down α) :
    compare a b = compare b.getDown a.getDown := rfl

end Down

/-- Compare two values by first applying a projection function.
    $$\text{comparing}(f, x, y) = \text{compare}(f(x), f(y))$$

    Useful with sorting: `list.mergeSort (comparing SomeStruct.field)` -/
@[inline] def comparing [Ord β] (f : α → β) (x y : α) : Ordering :=
  compare (f x) (f y)

/-- Clamp a value to the interval $[\text{lo}, \text{hi}]$.

    Returns a subtype proving the result lies within bounds:
    $$\text{clamp}(x, lo, hi) = \begin{cases}
      lo & \text{if } x \leq lo \\
      hi & \text{if } x \geq hi \\
      x  & \text{otherwise}
    \end{cases}$$

    **Precondition:** `lo ≤ hi` (provided as proof).
    **Guarantee:** The returned value `y` satisfies `lo ≤ y ∧ y ≤ hi`. -/
def clamp [LE α] [DecidableRel (α := α) (· ≤ ·)] (x lo hi : α)
    (hle : lo ≤ hi)
    (refl : ∀ a : α, a ≤ a)
    (total : ∀ a b : α, ¬(a ≤ b) → b ≤ a) : { y : α // lo ≤ y ∧ y ≤ hi } :=
  if h₁ : x ≤ lo then
    ⟨lo, refl lo, hle⟩
  else if h₂ : hi ≤ x then
    ⟨hi, hle, refl hi⟩
  else
    ⟨x, total x lo h₁, total hi x h₂⟩

end LeanStd
