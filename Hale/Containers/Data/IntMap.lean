import Std.Data.HashMap

/-
  Hale.Containers.Data.IntMap — Maps with `Nat` keys

  Port of Haskell's `Data.IntMap` from the `containers` package.
  Backed by `Std.HashMap Nat v`, which gives amortised $O(1)$
  lookup and insertion (compared to Haskell's Patricia trie which gives
  $O(\min(n, W))$ where $W$ is the word size).

  ## Design

  Haskell's `IntMap` uses a big-endian Patricia trie for `Int` keys.
  In Lean we use `Nat` keys (non-negative) and back the structure with
  `Std.HashMap`, which provides excellent average-case performance.
  The sorted-order operations (`toAscList`, `lookupMin`, `lookupMax`)
  sort on demand, since `HashMap` does not maintain key order.

  Reference: https://hackage.haskell.org/package/containers/docs/Data-IntMap.html
-/

namespace Data

/-- A map from `Nat` keys to values, backed by a hash map.
    $$\text{IntMap}(v) \cong \text{HashMap}(\mathbb{N}, v)$$
    Provides amortised $O(1)$ lookup and insert. -/
abbrev IntMap (v : Type u) :=
  Std.HashMap Nat v

namespace IntMap

variable {v : Type u}

-- ── Construction ───────────────────────────────

/-- The empty map.
    $$\text{empty} = \emptyset$$ -/
@[inline] def empty : IntMap v :=
  ∅

/-- A map with a single key-value pair.
    $$\text{singleton}(k, v) = \{k \mapsto v\}$$ -/
@[inline] def singleton (key : Nat) (val : v) : IntMap v :=
  (∅ : IntMap v).insert key val

/-- Build a map from an association list. Later entries override earlier ones
    for duplicate keys.
    $$\text{fromList}([(k_1,v_1),\ldots,(k_n,v_n)])$$ -/
@[inline] def fromList (l : List (Nat × v)) : IntMap v :=
  Std.HashMap.ofList l

-- ── Query ──────────────────────────────────────

/-- Look up a key.
    $$\text{lookup}(k, m) = \begin{cases} \text{some}(v) & \text{if } k \mapsto v \in m \\ \text{none} & \text{otherwise} \end{cases}$$ -/
@[inline] def lookup (key : Nat) (m : IntMap v) : Option v :=
  Std.HashMap.get? m key

/-- Look up a key, returning a default if absent.
    $$\text{findWithDefault}(d, k, m) = \begin{cases} v & \text{if } k \mapsto v \in m \\ d & \text{otherwise} \end{cases}$$ -/
@[inline] def findWithDefault (dflt : v) (key : Nat) (m : IntMap v) : v :=
  (Std.HashMap.get? m key).getD dflt

/-- Test whether a key is in the map.
    $$\text{member}(k, m) \iff k \in \text{dom}(m)$$ -/
@[inline] def member (key : Nat) (m : IntMap v) : Bool :=
  Std.HashMap.contains m key

/-- Is the map empty?
    $$\text{null}(m) \iff m = \emptyset$$ -/
@[inline] def null (m : IntMap v) : Bool :=
  Std.HashMap.isEmpty m

/-- The number of entries.
    $$\text{size'}(m) = |m|$$ -/
@[inline] def size' (m : IntMap v) : Nat :=
  Std.HashMap.size m

-- ── Insertion / Update / Delete ────────────────

/-- Insert a key-value pair. If the key already exists, the value is replaced.
    $$\text{insert}(k, v, m) = m[k \mapsto v]$$ -/
@[inline] def insert' (key : Nat) (val : v) (m : IntMap v) : IntMap v :=
  Std.HashMap.insert m key val

/-- Delete a key from the map.
    $$\text{delete}(k, m) = m \setminus \{k\}$$ -/
@[inline] def delete (key : Nat) (m : IntMap v) : IntMap v :=
  Std.HashMap.erase m key

/-- Adjust the value at a key, if present.
    $$\text{adjust}(f, k, m) = \begin{cases} m[k \mapsto f(v)] & \text{if } k \mapsto v \in m \\ m & \text{otherwise} \end{cases}$$ -/
def adjust (f : v → v) (key : Nat) (m : IntMap v) : IntMap v :=
  match Std.HashMap.get? m key with
  | some val => Std.HashMap.insert m key (f val)
  | none => m

-- ── Combine ────────────────────────────────────

/-- Left-biased union of two maps.
    $$\text{union}(m_1, m_2) = m_1 \cup m_2 \quad (\text{left-biased})$$ -/
def union (m1 m2 : IntMap v) : IntMap v :=
  Std.HashMap.fold (fun acc key val =>
    if Std.HashMap.contains acc key then acc else Std.HashMap.insert acc key val) m1 m2

/-- Union with a combining function.
    $$\text{unionWith}(f, m_1, m_2)[k] = \begin{cases} f(v_1, v_2) & \text{if } k \in m_1 \cap m_2 \\ v_1 & \text{if } k \in m_1 \text{ only} \\ v_2 & \text{if } k \in m_2 \text{ only} \end{cases}$$ -/
def unionWith (f : v → v → v) (m1 m2 : IntMap v) : IntMap v :=
  Std.HashMap.fold (fun acc key val2 =>
    match Std.HashMap.get? acc key with
    | some val1 => Std.HashMap.insert acc key (f val1 val2)
    | none => Std.HashMap.insert acc key val2) m1 m2

/-- Intersection of two maps, keeping values from the first.
    $$\text{intersection}(m_1, m_2) = \{k \mapsto v \mid k \mapsto v \in m_1, k \in \text{dom}(m_2)\}$$ -/
def intersection (m1 : IntMap v) (m2 : IntMap v) : IntMap v :=
  Std.HashMap.filter (fun key _ => Std.HashMap.contains m2 key) m1

/-- Intersection with a combining function.
    $$\text{intersectionWith}(f, m_1, m_2)[k] = f(v_1, v_2) \text{ for } k \in \text{dom}(m_1) \cap \text{dom}(m_2)$$ -/
def intersectionWith (f : v → v → v) (m1 : IntMap v) (m2 : IntMap v) : IntMap v :=
  Std.HashMap.fold (fun acc key val1 =>
    match Std.HashMap.get? m2 key with
    | some val2 => Std.HashMap.insert acc key (f val1 val2)
    | none => acc) (∅ : IntMap v) m1

/-- Difference of two maps.
    $$\text{difference}(m_1, m_2) = \{k \mapsto v \mid k \mapsto v \in m_1, k \notin \text{dom}(m_2)\}$$ -/
def difference (m1 : IntMap v) (m2 : IntMap v) : IntMap v :=
  Std.HashMap.filter (fun key _ => !(Std.HashMap.contains m2 key)) m1

-- ── Traversal ──────────────────────────────────

/-- Left fold over key-value pairs (unspecified order).
    $$\text{foldlWithKey}(f, z, m)$$ -/
@[inline] def foldlWithKey (f : α → Nat → v → α) (init : α) (m : IntMap v) : α :=
  Std.HashMap.fold (fun acc key val => f acc key val) init m

/-- Right fold over key-value pairs (unspecified order).
    $$\text{foldrWithKey}(f, z, m)$$ -/
def foldrWithKey (f : Nat → v → α → α) (init : α) (m : IntMap v) : α :=
  let pairs := Std.HashMap.toList m
  pairs.foldr (fun (key, val) acc => f key val acc) init

/-- Map a function over all values.
    $$\text{mapValues}(f, m)[k] = f(m[k])$$ -/
@[inline] def mapValues (f : v → w) (m : IntMap v) : IntMap w :=
  Std.HashMap.map (fun _ val => f val) m

/-- Map a function over all key-value pairs.
    $$\text{mapWithKey}(f, m)[k] = f(k, m[k])$$ -/
@[inline] def mapWithKey (f : Nat → v → w) (m : IntMap v) : IntMap w :=
  Std.HashMap.map (fun key val => f key val) m

/-- Filter entries by a predicate on keys and values.
    $$\text{filterWithKey}(p, m) = \{k \mapsto v \mid k \mapsto v \in m, p(k, v)\}$$ -/
@[inline] def filterWithKey (p : Nat → v → Bool) (m : IntMap v) : IntMap v :=
  Std.HashMap.filter p m

-- ── Conversion ─────────────────────────────────

/-- Convert the map to a list of key-value pairs (unspecified order).
    $$\text{toList'}(m) = [(k_1, v_1), \ldots, (k_n, v_n)]$$ -/
@[inline] def toList' (m : IntMap v) : List (Nat × v) :=
  Std.HashMap.toList m

/-- Convert the map to an association list sorted by ascending key.
    $$\text{toAscList}(m) = [(k_1, v_1), \ldots, (k_n, v_n)]$$ where $k_1 < \cdots < k_n$.
    Note: requires $O(n \log n)$ sort since the backing `HashMap` is unordered. -/
def toAscList (m : IntMap v) : List (Nat × v) :=
  (Std.HashMap.toList m).toArray.qsort (fun a b => a.1 < b.1) |>.toList

/-- The list of all keys (unspecified order).
    $$\text{keys}(m) = [k_1, \ldots, k_n]$$ -/
def keys (m : IntMap v) : List Nat :=
  Std.HashMap.fold (fun acc key _ => key :: acc) [] m

/-- The list of all values (unspecified order).
    $$\text{elems}(m) = [v_1, \ldots, v_n]$$ -/
def elems (m : IntMap v) : List v :=
  Std.HashMap.fold (fun acc _ val => val :: acc) [] m

-- ── Submap ─────────────────────────────────────

/-- Restrict a map to only the keys in the given list.
    $$\text{restrictKeys}(m, ks) = \{k \mapsto v \mid k \mapsto v \in m, k \in ks\}$$ -/
def restrictKeys (m : IntMap v) (ks : List Nat) : IntMap v :=
  let keySet := ks.foldl (fun (s : Std.HashMap Nat Unit) key =>
    Std.HashMap.insert s key ()) (∅ : Std.HashMap Nat Unit)
  Std.HashMap.filter (fun key _ => Std.HashMap.contains keySet key) m

/-- Remove all keys in the given list from the map.
    $$\text{withoutKeys}(m, ks) = \{k \mapsto v \mid k \mapsto v \in m, k \notin ks\}$$ -/
def withoutKeys (m : IntMap v) (ks : List Nat) : IntMap v :=
  let keySet := ks.foldl (fun (s : Std.HashMap Nat Unit) key =>
    Std.HashMap.insert s key ()) (∅ : Std.HashMap Nat Unit)
  Std.HashMap.filter (fun key _ => !(Std.HashMap.contains keySet key)) m

/-- Is `m1` a submap of `m2`?
    $$\text{isSubmapOf}(m_1, m_2) \iff \forall k \in \text{dom}(m_1),\; m_1[k] = m_2[k]$$ -/
def isSubmapOf [BEq v] (m1 m2 : IntMap v) : Bool :=
  Std.HashMap.fold (fun acc key val =>
    acc && match Std.HashMap.get? m2 key with
    | some v2 => val == v2
    | none => false) true m1

-- ── Min / Max ──────────────────────────────────

/-- The smallest key-value pair, or `none` if the map is empty.
    $$\text{lookupMin}(m) = \min_{k} \{(k, v) \mid k \mapsto v \in m\}$$
    Note: $O(n)$ since the backing `HashMap` is unordered. -/
def lookupMin (m : IntMap v) : Option (Nat × v) :=
  Std.HashMap.fold (fun acc key val =>
    match acc with
    | none => some (key, val)
    | some (k', _) => if key < k' then some (key, val) else acc) none m

/-- The largest key-value pair, or `none` if the map is empty.
    $$\text{lookupMax}(m) = \max_{k} \{(k, v) \mid k \mapsto v \in m\}$$
    Note: $O(n)$ since the backing `HashMap` is unordered. -/
def lookupMax (m : IntMap v) : Option (Nat × v) :=
  Std.HashMap.fold (fun acc key val =>
    match acc with
    | none => some (key, val)
    | some (k', _) => if key > k' then some (key, val) else acc) none m

-- ── Instances ──────────────────────────────────

instance [Repr v] : Repr (IntMap v) where
  reprPrec m _ :=
    let pairs := (toAscList m).map (fun (k, v) => repr k ++ " := " ++ repr v)
    "IntMap.fromList [" ++ Std.Format.joinSep pairs ", " ++ "]"

end IntMap
end Data
