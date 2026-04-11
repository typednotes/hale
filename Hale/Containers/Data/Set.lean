import Lean.Data.RBMap

/-
  Hale.Containers.Data.Set — Ordered finite sets

  Port of Haskell's `Data.Set` from the `containers` package.
  Backed by `Lean.RBMap k Unit compare`, which gives $O(\log n)$
  membership, insertion, and deletion.

  ## Design

  We represent `Set' k` as `Lean.RBMap k Unit compare`, effectively using
  the ordered map with unit values. This mirrors Haskell's internal
  representation where `Data.Set` is backed by the same balanced tree
  structure as `Data.Map`. The name `Set'` avoids clashing with Lean's
  built-in `Set` (which is `α → Prop`).

  Reference: https://hackage.haskell.org/package/containers/docs/Data-Set.html
-/

namespace Data

/-- An ordered finite set of elements of type `k`, backed by a red-black tree.
    $$\text{Set'}(k) \cong \text{RBMap}(k, \text{Unit}, \text{compare})$$
    Provides $O(\log n)$ membership, insert, and delete.
    Named `Set'` to avoid clashing with Lean's `Set` (`α → Prop`). -/
abbrev Set' (k : Type u) [Ord k] :=
  Lean.RBMap k Unit compare

namespace Set'

variable {k : Type u} [Ord k]

-- ── Construction ───────────────────────────────

/-- The empty set.
    $$\text{empty} = \emptyset$$ -/
@[inline] def empty : Set' k :=
  Lean.RBMap.empty

/-- A set with a single element.
    $$\text{singleton}(x) = \{x\}$$ -/
@[inline] def singleton (x : k) : Set' k :=
  Lean.RBMap.insert Lean.RBMap.empty x ()

/-- Build a set from a list of elements.
    $$\text{fromList}([x_1, \ldots, x_n]) = \{x_1, \ldots, x_n\}$$ -/
def fromList (l : List k) : Set' k :=
  l.foldl (fun s x => Lean.RBMap.insert s x ()) Lean.RBMap.empty

-- ── Query ──────────────────────────────────────

/-- Test membership.
    $$\text{member}(x, s) \iff x \in s$$ -/
@[inline] def member (x : k) (s : Set' k) : Bool :=
  Lean.RBMap.contains s x

/-- Is the set empty?
    $$\text{null}(s) \iff s = \emptyset$$ -/
@[inline] def null (s : Set' k) : Bool :=
  Lean.RBMap.isEmpty s

/-- The number of elements.
    $$\text{size}(s) = |s|$$ -/
@[inline] def size' (s : Set' k) : Nat :=
  Lean.RBMap.size s

-- ── Insertion / Deletion ───────────────────────

/-- Insert an element.
    $$\text{insert}(x, s) = s \cup \{x\}$$ -/
@[inline] def insert' (x : k) (s : Set' k) : Set' k :=
  Lean.RBMap.insert s x ()

/-- Delete an element.
    $$\text{delete}(x, s) = s \setminus \{x\}$$ -/
@[inline] def delete (x : k) (s : Set' k) : Set' k :=
  Lean.RBMap.erase s x

-- ── Combine ────────────────────────────────────

/-- Union of two sets.
    $$\text{union}(s_1, s_2) = s_1 \cup s_2$$ -/
def union (s1 s2 : Set' k) : Set' k :=
  Lean.RBMap.mergeBy (fun _ _ _ => ()) s1 s2

/-- Intersection of two sets.
    $$\text{intersection}(s_1, s_2) = s_1 \cap s_2$$ -/
def intersection (s1 s2 : Set' k) : Set' k :=
  Lean.RBMap.intersectBy (fun _ _ _ => ()) s1 s2

/-- Difference of two sets.
    $$\text{difference}(s_1, s_2) = s_1 \setminus s_2$$ -/
def difference (s1 s2 : Set' k) : Set' k :=
  Lean.RBMap.filter (fun key _ => !(Lean.RBMap.contains s2 key)) s1

/-- Is `s1` a subset of `s2`?
    $$\text{isSubsetOf}(s_1, s_2) \iff s_1 \subseteq s_2$$ -/
def isSubsetOf (s1 s2 : Set' k) : Bool :=
  Lean.RBMap.all s1 (fun key _ => Lean.RBMap.contains s2 key)

-- ── Traversal ──────────────────────────────────

/-- Map a function over all elements. The result may be smaller if `f` maps
    distinct elements to the same value.
    $$\text{map}(f, s) = \{f(x) \mid x \in s\}$$ -/
def mapSet [Ord k₂] (f : k → k₂) (s : Set' k) : Set' k₂ :=
  Lean.RBMap.fold (fun acc key _ => Lean.RBMap.insert acc (f key) ()) Lean.RBMap.empty s

/-- Filter elements satisfying a predicate.
    $$\text{filter}(p, s) = \{x \in s \mid p(x)\}$$ -/
def filter (p : k → Bool) (s : Set' k) : Set' k :=
  Lean.RBMap.filter (fun key _ => p key) s

/-- Left fold over elements in ascending order.
    $$\text{foldl}(f, z, s) = f(\ldots f(f(z, x_1), x_2) \ldots, x_n)$$ -/
@[inline] def foldl (f : α → k → α) (init : α) (s : Set' k) : α :=
  Lean.RBMap.fold (fun acc key _ => f acc key) init s

/-- Right fold over elements in ascending order.
    $$\text{foldr}(f, z, s) = f(x_1, f(x_2, \ldots f(x_n, z)))$$ -/
@[inline] def foldr (f : k → α → α) (init : α) (s : Set' k) : α :=
  Lean.RBMap.revFold (fun acc key _ => f key acc) init s

-- ── Conversion ─────────────────────────────────

/-- Convert the set to a list in ascending order.
    $$\text{toList}(s) = [x_1, \ldots, x_n]$$ where $x_1 < \cdots < x_n$. -/
def toList' (s : Set' k) : List k :=
  Lean.RBMap.fold (fun acc key _ => acc ++ [key]) [] s

/-- Convert the set to an ascending list (same as `toList'` for an ordered set).
    $$\text{toAscList} = \text{toList'}$$ -/
@[inline] def toAscList (s : Set' k) : List k :=
  toList' s

-- ── Min / Max ──────────────────────────────────

/-- The smallest element, or `none` if the set is empty.
    $$\text{findMin}(s) = \min(s)$$ -/
def findMin (s : Set' k) : Option k :=
  (Lean.RBNode.min s.val).map (fun ⟨key, _⟩ => key)

/-- The largest element, or `none` if the set is empty.
    $$\text{findMax}(s) = \max(s)$$ -/
def findMax (s : Set' k) : Option k :=
  (Lean.RBNode.max s.val).map (fun ⟨key, _⟩ => key)

-- ── Instances ──────────────────────────────────

instance : EmptyCollection (Set' k) where
  emptyCollection := Set'.empty

instance : Inhabited (Set' k) where
  default := Set'.empty

instance [Repr k] : Repr (Set' k) where
  reprPrec s _ :=
    let elems := (toList' s).map repr
    "Set'.fromList [" ++ Std.Format.joinSep elems ", " ++ "]"

instance [BEq k] : BEq (Set' k) where
  beq s1 s2 := toList' s1 == toList' s2

-- ── Proofs ─────────────────────────────────────

/-- The empty set has no elements.
    $$\text{null}(\emptyset) = \text{true}$$ -/
theorem null_empty : null (Set'.empty : Set' k) = true := rfl

/-- Membership in the empty set is always false.
    $$\text{member}(x, \emptyset) = \text{false}$$ -/
theorem member_empty (x : k) : member x (Set'.empty : Set' k) = false := rfl

/-- The empty set has size zero.
    $$\text{size'}(\emptyset) = 0$$ -/
theorem size_empty : size' (Set'.empty : Set' k) = 0 := rfl

/-- A singleton set is not null.
    $$\text{null}(\text{singleton}(x)) = \text{false}$$ -/
theorem null_singleton (x : k) : null (singleton x) = false := by
  simp [null, singleton, Lean.RBMap.isEmpty, Lean.RBMap.empty, Lean.RBMap.insert, Lean.RBNode.insert]
  rfl

end Set'
end Data
