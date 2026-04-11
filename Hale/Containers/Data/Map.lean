import Lean.Data.RBMap

/-
  Hale.Containers.Data.Map — Ordered finite maps

  Port of Haskell's `Data.Map` from the `containers` package.
  Backed by Lean's `Lean.RBMap` (a red-black tree with well-formedness proof),
  providing $O(\log n)$ lookup, insertion, and deletion.

  ## Design

  Lean's `Lean.RBMap α β compare` is structurally identical to Haskell's
  `Data.Map.Map k v` — both are size-balanced/red-black trees keyed by a
  comparison function. We define `Map k v` as a transparent abbreviation
  and expose the Haskell-compatible API surface on top.

  Reference: https://hackage.haskell.org/package/containers/docs/Data-Map.html
-/

namespace Data

/-- An ordered finite map from keys `k` to values `v`, backed by a red-black tree.
    $$\text{Map}(k, v) \cong \text{RBMap}(k, v, \text{compare})$$
    Provides $O(\log n)$ lookup, insert, and delete. -/
abbrev Map (k : Type u) (v : Type w) [Ord k] :=
  Lean.RBMap k v compare

namespace Map

variable {k : Type u} {v : Type w} [Ord k]

-- ── Construction ───────────────────────────────

/-- The empty map.
    $$\text{empty} = \emptyset$$ -/
@[inline] def empty : Map k v :=
  Lean.RBMap.empty

/-- A map with a single key-value pair.
    $$\text{singleton}(k, v) = \{k \mapsto v\}$$ -/
@[inline] def singleton (key : k) (val : v) : Map k v :=
  Lean.RBMap.empty.insert key val

/-- Build a map from an association list. Later entries override earlier ones
    for duplicate keys.
    $$\text{fromList}([(k_1,v_1),\ldots,(k_n,v_n)])$$ -/
@[inline] def fromList (l : List (k × v)) : Map k v :=
  Lean.RBMap.ofList l

-- ── Query ──────────────────────────────────────

/-- Look up a key.
    $$\text{lookup}(k, m) = \begin{cases} \text{some}(v) & \text{if } k \mapsto v \in m \\ \text{none} & \text{otherwise} \end{cases}$$ -/
@[inline] def lookup (key : k) (m : Map k v) : Option v :=
  Lean.RBMap.find? m key

/-- Look up a key, returning a default if absent.
    $$\text{findWithDefault}(d, k, m) = \begin{cases} v & \text{if } k \mapsto v \in m \\ d & \text{otherwise} \end{cases}$$ -/
@[inline] def findWithDefault (dflt : v) (key : k) (m : Map k v) : v :=
  Lean.RBMap.findD m key dflt

/-- Test whether a key is in the map.
    $$\text{member}(k, m) \iff k \in \text{dom}(m)$$ -/
@[inline] def member (key : k) (m : Map k v) : Bool :=
  Lean.RBMap.contains m key

/-- Is the map empty?
    $$\text{null}(m) \iff m = \emptyset$$ -/
@[inline] def null (m : Map k v) : Bool :=
  Lean.RBMap.isEmpty m

/-- The number of entries.
    $$\text{size}(m) = |m|$$ -/
@[inline] def size' (m : Map k v) : Nat :=
  Lean.RBMap.size m

-- ── Insertion / Update / Delete ────────────────

/-- Insert a key-value pair. If the key already exists, the value is replaced.
    $$\text{insert}(k, v, m) = m[k \mapsto v]$$ -/
@[inline] def insert' (key : k) (val : v) (m : Map k v) : Map k v :=
  Lean.RBMap.insert m key val

/-- Delete a key from the map.
    $$\text{delete}(k, m) = m \setminus \{k\}$$ -/
@[inline] def delete (key : k) (m : Map k v) : Map k v :=
  Lean.RBMap.erase m key

/-- Adjust the value at a key, if present.
    $$\text{adjust}(f, k, m) = \begin{cases} m[k \mapsto f(v)] & \text{if } k \mapsto v \in m \\ m & \text{otherwise} \end{cases}$$ -/
def adjust (f : v → v) (key : k) (m : Map k v) : Map k v :=
  match Lean.RBMap.find? m key with
  | some val => Lean.RBMap.insert m key (f val)
  | none => m

-- ── Combine ────────────────────────────────────

/-- Left-biased union of two maps. Keys in both maps take the value from the
    first (left) map.
    $$\text{union}(m_1, m_2) = m_1 \cup m_2 \quad (\text{left-biased})$$ -/
def union (m1 m2 : Map k v) : Map k v :=
  Lean.RBMap.mergeBy (fun _ v1 _ => v1) m1 m2

/-- Union with a combining function.
    $$\text{unionWith}(f, m_1, m_2)[k] = \begin{cases} f(v_1, v_2) & \text{if } k \mapsto v_1 \in m_1 \text{ and } k \mapsto v_2 \in m_2 \\ v_1 & \text{if } k \in m_1 \text{ only} \\ v_2 & \text{if } k \in m_2 \text{ only} \end{cases}$$ -/
def unionWith (f : v → v → v) (m1 m2 : Map k v) : Map k v :=
  Lean.RBMap.mergeBy (fun _ v1 v2 => f v1 v2) m1 m2

/-- Intersection of two maps, keeping values from the first.
    $$\text{intersection}(m_1, m_2) = \{k \mapsto v \mid k \mapsto v \in m_1, k \in \text{dom}(m_2)\}$$ -/
def intersection (m1 : Map k v) (m2 : Map k v) : Map k v :=
  Lean.RBMap.intersectBy (fun _ v1 _ => v1) m1 m2

/-- Intersection with a combining function.
    $$\text{intersectionWith}(f, m_1, m_2)[k] = f(v_1, v_2) \text{ for } k \in \text{dom}(m_1) \cap \text{dom}(m_2)$$ -/
def intersectionWith (f : v → v → v) (m1 m2 : Map k v) : Map k v :=
  Lean.RBMap.intersectBy (fun _ v1 v2 => f v1 v2) m1 m2

/-- Difference of two maps.
    $$\text{difference}(m_1, m_2) = \{k \mapsto v \mid k \mapsto v \in m_1, k \notin \text{dom}(m_2)\}$$ -/
def difference (m1 : Map k v) (m2 : Map k v) : Map k v :=
  Lean.RBMap.filter (fun key _ => !(Lean.RBMap.contains m2 key)) m1

-- ── Traversal ──────────────────────────────────

/-- Left fold over key-value pairs in ascending key order.
    $$\text{foldlWithKey}(f, z, m) = f(\ldots f(f(z, k_1, v_1), k_2, v_2) \ldots, k_n, v_n)$$ -/
@[inline] def foldlWithKey (f : α → k → v → α) (init : α) (m : Map k v) : α :=
  Lean.RBMap.fold f init m

/-- Right fold over key-value pairs in ascending key order.
    $$\text{foldrWithKey}(f, z, m) = f(k_1, v_1, f(k_2, v_2, \ldots f(k_n, v_n, z)))$$ -/
@[inline] def foldrWithKey (f : k → v → α → α) (init : α) (m : Map k v) : α :=
  Lean.RBMap.revFold (fun acc key val => f key val acc) init m

/-- Map a function over all values.
    $$\text{map}(f, m)[k] = f(m[k])$$ -/
def mapValues (f : v → w) (m : Map k v) : Map k w :=
  Lean.RBMap.fold (fun acc key val => Lean.RBMap.insert acc key (f val)) Lean.RBMap.empty m

/-- Map a function over all key-value pairs.
    $$\text{mapWithKey}(f, m)[k] = f(k, m[k])$$ -/
def mapWithKey (f : k → v → w) (m : Map k v) : Map k w :=
  Lean.RBMap.fold (fun acc key val => Lean.RBMap.insert acc key (f key val)) Lean.RBMap.empty m

/-- Map a function over all keys. The resulting map may be smaller if the
    function maps distinct keys to the same value (last wins).
    $$\text{mapKeys}(f, m) = \text{fromList}([(f(k), v) \mid k \mapsto v \in m])$$ -/
def mapKeys [Ord k₂] (f : k → k₂) (m : Map k v) : Map k₂ v :=
  Lean.RBMap.fold (fun acc key val => Lean.RBMap.insert acc (f key) val) Lean.RBMap.empty m

/-- Filter entries by a predicate on keys and values.
    $$\text{filterWithKey}(p, m) = \{k \mapsto v \mid k \mapsto v \in m, p(k, v)\}$$ -/
@[inline] def filterWithKey (p : k → v → Bool) (m : Map k v) : Map k v :=
  Lean.RBMap.filter p m

-- ── Conversion ─────────────────────────────────

/-- Convert the map to a list of key-value pairs in ascending key order.
    $$\text{toList}(m) = [(k_1, v_1), \ldots, (k_n, v_n)]$$ where $k_1 < \cdots < k_n$. -/
@[inline] def toList' (m : Map k v) : List (k × v) :=
  Lean.RBMap.toList m

/-- Convert the map to an ascending list (same as `toList` for an ordered map).
    $$\text{toAscList} = \text{toList}$$ -/
@[inline] def toAscList (m : Map k v) : List (k × v) :=
  Lean.RBMap.toList m

/-- The list of all keys in ascending order.
    $$\text{keys}(m) = [k_1, \ldots, k_n]$$ where $k_1 < \cdots < k_n$. -/
def keys (m : Map k v) : List k :=
  Lean.RBMap.fold (fun acc key _ => acc ++ [key]) [] m

/-- The list of all values in ascending key order.
    $$\text{elems}(m) = [v_1, \ldots, v_n]$$ ordered by their corresponding keys. -/
def elems (m : Map k v) : List v :=
  Lean.RBMap.fold (fun acc _ val => acc ++ [val]) [] m

-- ── Submap ─────────────────────────────────────

/-- Restrict a map to only the keys in the given list.
    $$\text{restrictKeys}(m, ks) = \{k \mapsto v \mid k \mapsto v \in m, k \in ks\}$$ -/
def restrictKeys (m : Map k v) (ks : List k) : Map k v :=
  let keySet := ks.foldl (fun (s : Lean.RBMap k Unit compare) key =>
    Lean.RBMap.insert s key ()) Lean.RBMap.empty
  Lean.RBMap.filter (fun key _ => Lean.RBMap.contains keySet key) m

/-- Remove all keys in the given list from the map.
    $$\text{withoutKeys}(m, ks) = \{k \mapsto v \mid k \mapsto v \in m, k \notin ks\}$$ -/
def withoutKeys (m : Map k v) (ks : List k) : Map k v :=
  let keySet := ks.foldl (fun (s : Lean.RBMap k Unit compare) key =>
    Lean.RBMap.insert s key ()) Lean.RBMap.empty
  Lean.RBMap.filter (fun key _ => !(Lean.RBMap.contains keySet key)) m

/-- Is `m1` a submap of `m2`? Every key in `m1` must be in `m2` with an equal value.
    $$\text{isSubmapOf}(m_1, m_2) \iff \forall k \in \text{dom}(m_1),\; m_1[k] = m_2[k]$$ -/
def isSubmapOf [BEq v] (m1 m2 : Map k v) : Bool :=
  Lean.RBMap.all m1 (fun key val =>
    match Lean.RBMap.find? m2 key with
    | some v2 => val == v2
    | none => false)

-- ── Min / Max ──────────────────────────────────

/-- The smallest key-value pair, or `none` if the map is empty.
    $$\text{lookupMin}(m) = \min_{k} \{(k, v) \mid k \mapsto v \in m\}$$ -/
def lookupMin (m : Map k v) : Option (k × v) :=
  (Lean.RBNode.min m.val).map (fun ⟨key, val⟩ => (key, val))

/-- The largest key-value pair, or `none` if the map is empty.
    $$\text{lookupMax}(m) = \max_{k} \{(k, v) \mid k \mapsto v \in m\}$$ -/
def lookupMax (m : Map k v) : Option (k × v) :=
  (Lean.RBNode.max m.val).map (fun ⟨key, val⟩ => (key, val))

-- ── Instances ──────────────────────────────────

instance : EmptyCollection (Map k v) where
  emptyCollection := Map.empty

instance : Inhabited (Map k v) where
  default := Map.empty

instance [Repr k] [Repr v] : Repr (Map k v) where
  reprPrec m _ :=
    let pairs := (Lean.RBMap.toList m).map (fun (k, v) => repr k ++ " := " ++ repr v)
    "Map.fromList [" ++ Std.Format.joinSep pairs ", " ++ "]"

instance [BEq k] [BEq v] : BEq (Map k v) where
  beq m1 m2 := Lean.RBMap.toList m1 == Lean.RBMap.toList m2

-- ── Proofs ─────────────────────────────────────

/-- The empty map has no entries.
    $$\text{null}(\emptyset) = \text{true}$$ -/
theorem null_empty : null (Map.empty : Map k v) = true := rfl

/-- Lookup on the empty map always returns `none`.
    $$\text{lookup}(k, \emptyset) = \text{none}$$ -/
theorem lookup_empty (key : k) : lookup key (Map.empty : Map k v) = none := rfl

/-- The empty map has size zero.
    $$\text{size'}(\emptyset) = 0$$ -/
theorem size_empty : size' (Map.empty : Map k v) = 0 := rfl

/-- A singleton map is not null.
    $$\text{null}(\text{singleton}(k, v)) = \text{false}$$ -/
theorem null_singleton (key : k) (val : v) : null (singleton key val) = false := by
  simp [null, singleton, Lean.RBMap.isEmpty, Lean.RBMap.empty, Lean.RBMap.insert, Lean.RBNode.insert]
  rfl

/-- Membership in the empty map is always false.
    $$\text{member}(k, \emptyset) = \text{false}$$ -/
theorem member_empty (key : k) : member key (Map.empty : Map k v) = false := rfl

end Map
end Data
