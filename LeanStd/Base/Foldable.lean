/-
  LeanStd.Base.Foldable — Foldable typeclass

  Structures that can be folded to a summary value.

  ## Design

  Provides `foldr`, `foldl`, `toList`, and derived operations like
  `foldMap`, `any`, `all`, `find?`, `elem`, `minimum?`, `maximum?`, `sum`, `product`.
-/

import LeanStd.Base.NonEmpty
import LeanStd.Base.Either

namespace LeanStd

/-- `Foldable` captures the pattern of folding a structure into a single value.

    For a `Foldable` container $F$:
    $$\text{foldr}(f, z, [x_1, \ldots, x_n]) = f(x_1, f(x_2, \ldots f(x_n, z)))$$
    $$\text{foldl}(f, z, [x_1, \ldots, x_n]) = f(\ldots f(f(z, x_1), x_2) \ldots, x_n)$$
-/
class Foldable (F : Type u → Type v) where
  /-- Right fold: $\text{foldr}(f, z, t) = f(x_1, f(x_2, \ldots f(x_n, z)))$. -/
  foldr : (α → β → β) → β → F α → β
  /-- Left fold: $\text{foldl}(f, z, t) = f(\ldots f(f(z, x_1), x_2) \ldots, x_n)$. -/
  foldl : (β → α → β) → β → F α → β := fun f z t => foldr (fun a g b => g (f b a)) id t z
  /-- Convert to a list, preserving order. -/
  toList : F α → List α := fun t => foldr (· :: ·) [] t

namespace Foldable

/-- Map each element to a monoid and combine.
    $$\text{foldMap}(f, [x_1, \ldots, x_n]) = f(x_1) \mathbin{++} f(x_2) \mathbin{++} \cdots \mathbin{++} f(x_n)$$

    Uses `Append` and starts from `mempty`. -/
@[inline] def foldMap [Foldable F] [Append β] [Inhabited β] (f : α → β) (t : F α) : β :=
  Foldable.foldr (fun a b => f a ++ b) default t

/-- Is the structure empty?
    $$\text{null}(t) \iff |t| = 0$$
-/
@[inline] def null [Foldable F] (t : F α) : Bool :=
  Foldable.foldr (fun _ _ => false) true t

/-- Count of elements.
    $$\text{length}(t) = |t|$$
-/
@[inline] def length [Foldable F] (t : F α) : Nat :=
  Foldable.foldl (fun n _ => n + 1) 0 t

/-- Does any element satisfy the predicate?
    $$\text{any}(p, t) \iff \exists x \in t,\; p(x) = \text{true}$$
-/
@[inline] def any [Foldable F] (p : α → Bool) (t : F α) : Bool :=
  Foldable.foldr (fun a b => p a || b) false t

/-- Do all elements satisfy the predicate?
    $$\text{all}(p, t) \iff \forall x \in t,\; p(x) = \text{true}$$
-/
@[inline] def all [Foldable F] (p : α → Bool) (t : F α) : Bool :=
  Foldable.foldr (fun a b => p a && b) true t

/-- Find the first element satisfying a predicate. -/
@[inline] def find? [Foldable F] (p : α → Bool) (t : F α) : Option α :=
  Foldable.foldr (fun a b => if p a then some a else b) none t

/-- Is the element in the structure?
    $$\text{elem}(x, t) \iff \exists y \in t,\; x = y$$
-/
@[inline] def elem [Foldable F] [BEq α] (a : α) (t : F α) : Bool :=
  any (· == a) t

/-- The minimum element, if the structure is non-empty. -/
@[inline] def minimum? [Foldable F] [Min α] (t : F α) : Option α :=
  Foldable.foldl (fun acc a => some (match acc with | none => a | some m => Min.min m a)) none t

/-- The maximum element, if the structure is non-empty. -/
@[inline] def maximum? [Foldable F] [Max α] (t : F α) : Option α :=
  Foldable.foldl (fun acc a => some (match acc with | none => a | some m => Max.max m a)) none t

/-- Sum of all elements.
    $$\text{sum}(t) = \sum_{x \in t} x$$
-/
@[inline] def sum [Foldable F] [Add α] [OfNat α 0] (t : F α) : α :=
  Foldable.foldl (· + ·) 0 t

/-- Product of all elements.
    $$\text{product}(t) = \prod_{x \in t} x$$
-/
@[inline] def product [Foldable F] [Mul α] [OfNat α 1] (t : F α) : α :=
  Foldable.foldl (· * ·) 1 t

end Foldable

-- ── Instances ──────────────────────────────────

instance : Foldable List where
  foldr := List.foldr
  foldl := List.foldl
  toList := id

instance : Foldable Option where
  foldr f z
    | some a => f a z
    | none => z
  foldl f z
    | some a => f z a
    | none => z
  toList
    | some a => [a]
    | none => []

instance : Foldable NonEmpty where
  foldr f z ne := f ne.head (ne.tail.foldr f z)
  foldl f z ne := ne.tail.foldl f (f z ne.head)
  toList := NonEmpty.toList

instance : Foldable (Either α) where
  foldr f z
    | .right b => f b z
    | .left _ => z
  foldl f z
    | .right b => f z b
    | .left _ => z
  toList
    | .right b => [b]
    | .left _ => []

end LeanStd
