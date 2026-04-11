/-
  Hale.Vector.Data.Vector — Boxed vectors (arrays)

  Provides Haskell's `Data.Vector` API on top of Lean's built-in `Array`.

  ## Haskell equivalent
  `Data.Vector` (https://hackage.haskell.org/package/vector/docs/Data-Vector.html)

  ## Design
  `Vector` is `abbrev Vector := Array`. Lean's `Array` is already a dynamic
  array with O(1) amortized push and O(1) indexed access, matching Haskell's
  boxed `Vector` semantics.

  $$\text{Vector}\ \alpha \cong \text{Array}\ \alpha$$

  ## Lean stdlib reuse
  Most operations delegate to `Array` methods from Lean's stdlib.
  This module adds Haskell naming conventions and combinators Lean lacks.
-/

namespace Data

/-- Boxed vector type. Lean's `Array` is already the equivalent of Haskell's `Vector`.
    $$\text{Vector}\ \alpha := \text{Array}\ \alpha$$ -/
abbrev Vector (α : Type u) := Array α

namespace Vector

-- ── Construction ─────────────────────────────────

/-- The empty vector.
    $$\text{empty} : \text{Vector}\ \alpha,\quad |\text{empty}| = 0$$ -/
@[inline] def empty : Vector α := #[]

/-- A vector containing a single element.
    $$\text{singleton}(x) = [x]$$ -/
@[inline] def singleton (x : α) : Vector α := #[x]

/-- Convert a list to a vector.
    $$\text{fromList}([x_1, \ldots, x_n]) = [x_1, \ldots, x_n]$$ -/
@[inline] def fromList (xs : List α) : Vector α := xs.toArray

/-- Convert a vector to a list.
    $$\text{toList}([x_1, \ldots, x_n]) = [x_1, \ldots, x_n]$$ -/
@[inline] def toList (v : Vector α) : List α := Array.toList v

/-- Create a vector of `n` copies of element `x`.
    $$\text{replicate}(n, x) = [x, x, \ldots, x],\quad |\text{result}| = n$$ -/
@[inline] def replicate (n : Nat) (x : α) : Vector α :=
  (List.replicate n x).toArray

/-- Create a vector of length `n` by applying `f` to each index.
    $$\text{generate}(n, f) = [f(0), f(1), \ldots, f(n-1)]$$ -/
def generate (n : Nat) (f : Nat → α) : Vector α :=
  go n 0 #[]
where
  go : Nat → Nat → Vector α → Vector α
  | 0, _, acc => acc
  | fuel + 1, i, acc => go fuel (i + 1) (acc.push (f i))

-- ── Basic interface ──────────────────────────────

/-- The number of elements.
    $$\text{length}(v) = |v|$$ -/
@[inline] def length (v : Vector α) : Nat := v.size

/-- Is the vector empty?
    $$\text{null}(v) \iff |v| = 0$$ -/
@[inline] def null (v : Vector α) : Bool := v.size == 0

/-- Index into the vector. Returns `none` if out of bounds.
    $$v\text{!}(i) = v_i$$ -/
@[inline] def getOp (v : Vector α) (i : Nat) : Option α :=
  if h : i < v.size then some v[i] else none

/-- The first element of a non-empty vector.
    $$\text{head}(v) = v_0,\quad \text{requires } |v| > 0$$ -/
def head (v : Vector α) (h : v.size > 0 := by omega) : α :=
  v[0]

/-- The last element of a non-empty vector.
    $$\text{last}(v) = v_{|v|-1},\quad \text{requires } |v| > 0$$ -/
def last (v : Vector α) (h : v.size > 0 := by omega) : α :=
  v[v.size - 1]'(by omega)

/-- Extract a slice from index `i` of length `n`.
    $$\text{slice}(i, n, v) = [v_i, v_{i+1}, \ldots, v_{i+n-1}]$$ -/
def slice (i n : Nat) (v : Vector α) : Vector α :=
  let lst := Array.toList v
  (lst.drop i |>.take n).toArray

/-- All elements except the last.
    $$\text{init}(v) = v[0..|v|-1],\quad \text{requires } |v| > 0$$ -/
def init (v : Vector α) (_ : v.size > 0 := by omega) : Vector α :=
  (Array.toList v).dropLast.toArray

/-- All elements except the first.
    $$\text{tail}(v) = v[1..],\quad \text{requires } |v| > 0$$ -/
def tail (v : Vector α) (_ : v.size > 0 := by omega) : Vector α :=
  ((Array.toList v).drop 1).toArray

/-- Take the first `n` elements.
    $$\text{take}(n, v) = v[0..n]$$ -/
@[inline] def take (n : Nat) (v : Vector α) : Vector α :=
  ((Array.toList v).take n).toArray

/-- Drop the first `n` elements.
    $$\text{drop}(n, v) = v[n..]$$ -/
@[inline] def drop (n : Nat) (v : Vector α) : Vector α :=
  ((Array.toList v).drop n).toArray

-- ── Mapping ──────────────────────────────────────

/-- Apply a function to every element.
    $$\text{map}(f, [x_1, \ldots, x_n]) = [f(x_1), \ldots, f(x_n)]$$ -/
@[inline] def map (f : α → β) (v : Vector α) : Vector β :=
  Array.map f v

/-- Map with index.
    $$\text{imap}(f, [x_0, \ldots, x_{n-1}]) = [f(0, x_0), \ldots, f(n-1, x_{n-1})]$$ -/
def imap (f : Nat → α → β) (v : Vector α) : Vector β :=
  go 0 #[]
where
  go (i : Nat) (acc : Array β) : Vector β :=
    if h : i < v.size then go (i + 1) (acc.push (f i v[i]))
    else acc

/-- Map and concatenate.
    $$\text{concatMap}(f, v) = \text{concat}(\text{map}(f, v))$$ -/
def concatMap (f : α → Vector β) (v : Vector α) : Vector β :=
  Array.foldl (fun acc x => acc ++ f x) #[] v

-- ── Filtering ────────────────────────────────────

/-- Keep elements satisfying a predicate.
    $$\text{filter}(p, v) = [x \in v \mid p(x)]$$ -/
@[inline] def filter (p : α → Bool) (v : Vector α) : Vector α :=
  Array.filter p v

/-- Filter with index.
    $$\text{ifilter}(p, v) = [v_i \mid p(i, v_i)]$$ -/
def ifilter (p : Nat → α → Bool) (v : Vector α) : Vector α :=
  go 0 #[]
where
  go (i : Nat) (acc : Array α) : Vector α :=
    if h : i < v.size then
      let acc' := if p i v[i] then acc.push v[i] else acc
      go (i + 1) acc'
    else acc

-- ── Folding ──────────────────────────────────────

/-- Strict left fold.
    $$\text{foldl'}(f, z, [x_1, \ldots, x_n]) = f(\ldots f(f(z, x_1), x_2) \ldots, x_n)$$ -/
@[inline] def foldl' (f : β → α → β) (z : β) (v : Vector α) : β :=
  Array.foldl f z v

/-- Strict left fold on non-empty vector using first element as seed.
    $$\text{foldl1'}(f, [x_1, \ldots, x_n]) = f(\ldots f(x_1, x_2) \ldots, x_n)$$ -/
def foldl1' (f : α → α → α) (v : Vector α) (h : v.size > 0 := by omega) : α :=
  go 1 v[0]
where
  go (i : Nat) (acc : α) : α :=
    if hi : i < v.size then go (i + 1) (f acc v[i])
    else acc

/-- Right fold.
    $$\text{foldr}(f, z, [x_1, \ldots, x_n]) = f(x_1, f(x_2, \ldots f(x_n, z)))$$ -/
@[inline] def foldr (f : α → β → β) (z : β) (v : Vector α) : β :=
  Array.foldr f z v

/-- Right fold on non-empty vector using last element as seed.
    $$\text{foldr1}(f, [x_1, \ldots, x_n]) = f(x_1, f(x_2, \ldots f(x_{n-1}, x_n)))$$ -/
def foldr1 (f : α → α → α) (v : Vector α) (h : v.size > 0 := by omega) : α :=
  have hlast : v.size - 1 < v.size := by omega
  go (v.size - 2) (v[v.size - 1])
where
  go : Nat → α → α
  | 0, acc =>
    if h0 : 0 < v.size then f v[0] acc
    else acc
  | i + 1, acc =>
    if hi : i + 1 < v.size then go i (f v[i + 1] acc)
    else acc

/-- Strict left fold with index.
    $$\text{ifoldl'}(f, z, v) = f(\ldots f(f(z, 0, v_0), 1, v_1) \ldots, n-1, v_{n-1})$$ -/
def ifoldl' (f : β → Nat → α → β) (z : β) (v : Vector α) : β :=
  go 0 z
where
  go (i : Nat) (acc : β) : β :=
    if h : i < v.size then go (i + 1) (f acc i v[i])
    else acc

/-- Right fold with index.
    $$\text{ifoldr}(f, z, v) = f(0, v_0, f(1, v_1, \ldots f(n-1, v_{n-1}, z)))$$ -/
def ifoldr (f : Nat → α → β → β) (z : β) (v : Vector α) : β :=
  go v.size z
where
  go : Nat → β → β
  | 0, acc => acc
  | i + 1, acc =>
    if h : i < v.size then go i (f i v[i] acc)
    else acc

-- ── Predicates ───────────────────────────────────

/-- Do all elements satisfy the predicate?
    $$\text{all}(p, v) = \forall x \in v.\; p(x)$$ -/
@[inline] def all (p : α → Bool) (v : Vector α) : Bool :=
  Array.all v p

/-- Does any element satisfy the predicate?
    $$\text{any}(p, v) = \exists x \in v.\; p(x)$$ -/
@[inline] def any (p : α → Bool) (v : Vector α) : Bool :=
  Array.any v p

/-- Are all elements `true`?
    $$\text{and}(v) = \bigwedge v$$ -/
def and (v : Vector Bool) : Bool :=
  Array.all v id

/-- Is any element `true`?
    $$\text{or}(v) = \bigvee v$$ -/
def or (v : Vector Bool) : Bool :=
  Array.any v id

/-- Sum of all elements.
    $$\text{sum}(v) = \sum v$$ -/
def sum [Add α] [OfNat α 0] (v : Vector α) : α :=
  Array.foldl (· + ·) 0 v

/-- Product of all elements.
    $$\text{product}(v) = \prod v$$ -/
def product [Mul α] [OfNat α 1] (v : Vector α) : α :=
  Array.foldl (· * ·) 1 v

/-- Maximum element of a non-empty vector.
    $$\text{maximum}(v) = \max(v),\quad \text{requires } |v| > 0$$ -/
def maximum [Ord α] (v : Vector α) (h : v.size > 0 := by omega) : α :=
  go 1 v[0]
where
  go (i : Nat) (best : α) : α :=
    if hi : i < v.size then
      let x := v[i]
      go (i + 1) (if compare x best == .gt then x else best)
    else best

/-- Minimum element of a non-empty vector.
    $$\text{minimum}(v) = \min(v),\quad \text{requires } |v| > 0$$ -/
def minimum [Ord α] (v : Vector α) (h : v.size > 0 := by omega) : α :=
  go 1 v[0]
where
  go (i : Nat) (best : α) : α :=
    if hi : i < v.size then
      let x := v[i]
      go (i + 1) (if compare x best == .lt then x else best)
    else best

-- ── Search ───────────────────────────────────────

/-- Does the element occur in the vector?
    $$\text{elem}(x, v) = \exists i.\; v_i = x$$ -/
def elem [BEq α] (x : α) (v : Vector α) : Bool :=
  Array.any v (· == x)

/-- Does the element NOT occur in the vector?
    $$\text{notElem}(x, v) = \neg\text{elem}(x, v)$$ -/
def notElem [BEq α] (x : α) (v : Vector α) : Bool :=
  !elem x v

/-- Find the first element satisfying a predicate.
    $$\text{find}(p, v)$$ -/
def find (p : α → Bool) (v : Vector α) : Option α :=
  go 0
where
  go (i : Nat) : Option α :=
    if h : i < v.size then
      if p v[i] then some v[i] else go (i + 1)
    else none

/-- Find the index of the first element satisfying a predicate.
    $$\text{findIndex}(p, v)$$ -/
def findIndex (p : α → Bool) (v : Vector α) : Option Nat :=
  go 0
where
  go (i : Nat) : Option Nat :=
    if h : i < v.size then
      if p v[i] then some i else go (i + 1)
    else none

-- ── Zipping ──────────────────────────────────────

/-- Zip two vectors into a vector of pairs.
    $$\text{zip}(u, v) = [(u_0, v_0), (u_1, v_1), \ldots]$$ -/
def zip (u : Vector α) (v : Vector β) : Vector (α × β) :=
  ((Array.toList u).zip (Array.toList v)).toArray

/-- Zip two vectors with a combining function.
    $$\text{zipWith}(f, u, v) = [f(u_0, v_0), f(u_1, v_1), \ldots]$$ -/
def zipWith (f : α → β → γ) (u : Vector α) (v : Vector β) : Vector γ :=
  (List.zipWith f (Array.toList u) (Array.toList v)).toArray

/-- Unzip a vector of pairs into a pair of vectors.
    $$\text{unzip}([(a_1, b_1), \ldots]) = ([a_1, \ldots], [b_1, \ldots])$$ -/
def unzip (v : Vector (α × β)) : Vector α × Vector β :=
  let (as_, bs_) := (Array.toList v).unzip
  (as_.toArray, bs_.toArray)

-- ── Reordering ───────────────────────────────────

/-- Reverse the elements.
    $$\text{reverse}([x_1, \ldots, x_n]) = [x_n, \ldots, x_1]$$ -/
@[inline] def reverse (v : Vector α) : Vector α :=
  Array.reverse v

/-- Permute elements according to an index vector.
    $$\text{backpermute}(v, is) = [v_{is_0}, v_{is_1}, \ldots]$$
    Out-of-bounds indices produce a default value. -/
def backpermute [Inhabited α] (v : Vector α) (is : Vector Nat) : Vector α :=
  Array.map (fun i =>
    if h : i < v.size then v[i]
    else default) is

-- ── Modification ─────────────────────────────────

/-- Modify the element at index `i` by applying `f`.
    $$\text{modify}(f, i, v)$$ returns $v$ with $v_i$ replaced by $f(v_i)$.
    If `i` is out of bounds, returns `v` unchanged. -/
def modify (f : α → α) (i : Nat) (v : Vector α) : Vector α :=
  if h : i < v.size then
    v.set i (f v[i])
  else v

/-- Append an element to the end.
    $$\text{snoc}(v, x) = [v_0, \ldots, v_{n-1}, x]$$ -/
@[inline] def snoc (v : Vector α) (x : α) : Vector α :=
  v.push x

/-- Prepend an element to the front.
    $$\text{cons}(x, v) = [x, v_0, \ldots, v_{n-1}]$$ -/
def cons (x : α) (v : Vector α) : Vector α :=
  #[x] ++ v

-- ── Proofs ───────────────────────────────────────

/-- `fromList` and `toList` are inverses.
    $$\text{toList}(\text{fromList}(xs)) = xs$$ -/
theorem toList_fromList (xs : List α) : toList (fromList xs) = xs := by
  simp [toList, fromList]

/-- `length` of `empty` is zero.
    $$\text{length}(\text{empty}) = 0$$ -/
theorem length_empty : length (empty : Vector α) = 0 := by
  simp [length, empty]

/-- `length` of `singleton` is one.
    $$\text{length}(\text{singleton}(x)) = 1$$ -/
theorem length_singleton (x : α) : length (singleton x) = 1 := by
  simp [length, singleton]

/-- `null` of `empty` is true.
    $$\text{null}(\text{empty}) = \text{true}$$ -/
theorem null_empty : null (empty : Vector α) = true := by
  simp [null, empty]

/-- `null` of `singleton` is false.
    $$\text{null}(\text{singleton}(x)) = \text{false}$$ -/
theorem null_singleton (x : α) : null (singleton x) = false := by
  simp [null, singleton]

/-- `fromList` preserves length.
    $$\text{length}(\text{fromList}(xs)) = \text{List.length}(xs)$$ -/
theorem length_fromList (xs : List α) : length (fromList xs) = xs.length := by
  simp [length, fromList]

/-- `reverse` preserves length.
    $$\text{length}(\text{reverse}(v)) = \text{length}(v)$$ -/
theorem length_reverse (v : Vector α) : length (reverse v) = length v := by
  simp [length, reverse]

/-- `map` preserves length.
    $$\text{length}(\text{map}(f, v)) = \text{length}(v)$$ -/
theorem length_map (f : α → β) (v : Vector α) : length (map f v) = length v := by
  simp [length, map]

/-- `reverse` is an involution.
    $$\text{reverse}(\text{reverse}(v)) = v$$ -/
theorem reverse_reverse (v : Vector α) : reverse (reverse v) = v := by
  simp [reverse]

end Vector
end Data
