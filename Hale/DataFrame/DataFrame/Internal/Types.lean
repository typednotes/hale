/-
  Hale.DataFrame.DataFrame.Internal.Types — Core DataFrame types

  A strongly-typed tabular data structure with a proven rectangular invariant.

  ## Design

  The central guarantee is `DataFrame.columns_aligned`: a proof that every
  column has exactly `nRows` elements.  This proof is carried as a field on
  the structure and is erased at runtime (zero cost).  All smart constructors
  discharge this obligation, so users never encounter unproven obligations
  when building frames from valid data.

  ## Typing Guarantees

  - **Rectangular invariant** (`columns_aligned`): all columns have the same
    length — column access and row access are always in-bounds when the index
    is within `nRows` / `nColumns`.
  - **ColumnType tag** on every column: allows downstream code to dispatch
    on the predominant element type without scanning the column.
  - **Value.null** as an explicit variant — no `Option` wrapper needed, and
    null propagation is visible in the types.

  ## Performance

  - Columnar storage (`Array Value` per column) for cache-friendly scans.
  - All proofs are erased at runtime; the runtime representation is
    `Array Column × Nat`.
-/

namespace DataFrame

-- ============================================================
-- ColumnType
-- ============================================================

/-- Runtime type tag for column values.
    $$\text{ColumnType} \in \{ \text{int}, \text{float}, \text{str}, \text{bool}, \text{mixed} \}$$ -/
inductive ColumnType where
  | int
  | float
  | str
  | bool
  | mixed
deriving BEq, DecidableEq, Repr, Inhabited

instance : ToString ColumnType where
  toString
    | .int   => "int"
    | .float => "float"
    | .str   => "str"
    | .bool  => "bool"
    | .mixed => "mixed"

-- ============================================================
-- Value
-- ============================================================

/-- A heterogeneous cell value.
    $$\text{Value} = \text{int}(\mathbb{Z}) \mid \text{float}(\mathbb{R}_{64})
      \mid \text{str}(\text{String}) \mid \text{bool}(\mathbb{B}) \mid \text{null}$$ -/
inductive Value where
  | int   : Int    → Value
  | float : Float  → Value
  | str   : String → Value
  | bool  : Bool   → Value
  | null  : Value
deriving BEq, Repr, Inhabited

instance : ToString Value where
  toString
    | .int n   => toString n
    | .float f => toString f
    | .str s   => s
    | .bool b  => if b then "true" else "false"
    | .null    => "null"

/-- Assign a numeric tag to each Value variant for cross-variant ordering.
    int=0 < float=1 < str=2 < bool=3 < null=4. -/
private def Value.variantOrd : Value → Nat
  | .int _   => 0
  | .float _ => 1
  | .str _   => 2
  | .bool _  => 3
  | .null    => 4

/-- Ordering on `Value`.  Nulls sort last. Within the same variant, natural
    ordering applies.  Cross-variant ordering: int < float < str < bool < null. -/
instance : Ord Value where
  compare a b := match a, b with
    | .int x,   .int y   => compare x y
    | .float x, .float y =>
      if x < y then .lt else if x == y then .eq else .gt
    | .str x,   .str y   => compare x y
    | .bool x,  .bool y  => compare (if x then 1 else 0 : Nat) (if y then 1 else 0)
    | x,        y        => compare x.variantOrd y.variantOrd

namespace Value

/-- Attempt to extract a `Float` from a numeric value.
    $$\text{toFloat?}(\text{int}\ n) = \text{some}\ (\text{Float.ofInt}\ n)$$
    $$\text{toFloat?}(\text{float}\ f) = \text{some}\ f$$
    $$\text{toFloat?}(\_) = \text{none}$$ -/
def toFloat? : Value → Option Float
  | .int n   => some (Float.ofInt n)
  | .float f => some f
  | _        => none

/-- The `ColumnType` tag for a single value.
    $$\text{columnType}(\text{int}\ \_) = \text{int}, \ldots$$ -/
def columnType : Value → ColumnType
  | .int _   => .int
  | .float _ => .float
  | .str _   => .str
  | .bool _  => .bool
  | .null    => .mixed   -- null is type-agnostic

/-- Attempt to extract an `Int`. -/
def toInt? : Value → Option Int
  | .int n => some n
  | _      => none

/-- Attempt to extract a `String`. -/
def toStr? : Value → Option String
  | .str s => some s
  | _      => none

/-- Attempt to extract a `Bool`. -/
def toBool? : Value → Option Bool
  | .bool b => some b
  | _       => none

/-- Is this value null? -/
def isNull : Value → Bool
  | .null => true
  | _     => false

end Value

-- ============================================================
-- Column
-- ============================================================

/-- A named column with tracked element type.
    $$\text{Column} = (\text{name} : \text{String}) \times
      (\text{values} : \text{Array Value}) \times (\text{colType} : \text{ColumnType})$$ -/
structure Column where
  /-- Human-readable column name. -/
  name : String
  /-- The column data, stored as a flat array. -/
  values : Array Value
  /-- The predominant type of elements. -/
  colType : ColumnType
deriving Repr, Inhabited

namespace Column

/-- Number of elements in this column.
    $$\text{size}(c) = |c.\text{values}|$$ -/
def size (c : Column) : Nat := c.values.size

/-- Retrieve the value at index `i`, if in bounds.
    $$\text{get?}(c, i) = \begin{cases} \text{some}\ c_i & i < |c| \\ \text{none} & \text{otherwise} \end{cases}$$ -/
def get? (c : Column) (i : Nat) : Option Value :=
  if h : i < c.values.size then some c.values[i] else none

/-- Map a function over every value in the column, producing a new column
    with the same name and `mixed` type (since the function may change types). -/
def map (f : Value → Value) (c : Column) : Column :=
  { name := c.name, values := c.values.map f, colType := .mixed }

/-- Filter elements by a predicate, keeping only values for which `p` returns `true`. -/
def filter (p : Value → Bool) (c : Column) : Column :=
  { name := c.name, values := c.values.filter p, colType := c.colType }

instance : ToString Column where
  toString c := s!"Column({c.name}, {c.colType}, n={c.size})"

end Column

-- ============================================================
-- DataFrame
-- ============================================================

/-- A tabular data structure with a proven rectangular invariant.

    **Invariant (compile-time, zero-cost):** every column has exactly `nRows`
    elements — encoded as the `columns_aligned` proof field which is erased
    at runtime.

    $$\forall\, i < |\text{columns}|,\; |\text{columns}[i].\text{values}| = \text{nRows}$$ -/
structure DataFrame where
  /-- The array of named columns. -/
  columns : Array Column
  /-- Number of rows (shared by all columns). -/
  nRows : Nat
  /-- Proof that every column has exactly `nRows` elements.
      This field is erased at runtime; it exists solely for the kernel. -/
  columns_aligned : ∀ (i : Nat) (h : i < columns.size), columns[i].values.size = nRows

namespace DataFrame

-- ----------------------------------------------------------
-- Proof helpers
-- ----------------------------------------------------------

/-- When every column produced by `f` has `nRows` values, the mapped array
    satisfies the alignment invariant. -/
protected theorem map_column_aligned {α : Type} (src : Array α) (nRows : Nat)
    (f : α → Column) (hf : ∀ a, (f a).values.size = nRows)
    (i : Nat) (h : i < (src.map f).size) :
    (src.map f)[i].values.size = nRows := by
  rw [@Array.getElem_map _ _ f src i h]; exact hf _

-- ----------------------------------------------------------
-- Basic accessors
-- ----------------------------------------------------------

/-- The empty DataFrame: zero columns, zero rows. -/
def empty : DataFrame where
  columns := #[]
  nRows := 0
  columns_aligned := fun _ h => absurd h (Nat.not_lt_zero _)

/-- Number of columns.
    $$\text{nColumns}(\text{df}) = |\text{df}.\text{columns}|$$ -/
def nColumns (df : DataFrame) : Nat := df.columns.size

/-- List of column names, in order. -/
def columnNames (df : DataFrame) : List String :=
  df.columns.toList.map Column.name

/-- Look up a column by name.  Returns the first match or `none`. -/
def getColumn? (df : DataFrame) (name : String) : Option Column :=
  df.columns.find? (·.name == name)

/-- Retrieve a full row as an array of values, if the index is in bounds.
    Uses a fold to collect values from each column at the given row index. -/
def getRow? (df : DataFrame) (i : Nat) : Option (Array Value) :=
  if hi : i < df.nRows then
    some (getRowSafe df i hi)
  else none
where
  /-- Safe row access: retrieves a full row using the alignment proof.
      Iterates columns with index tracking to discharge bounds. -/
  getRowSafe (df : DataFrame) (i : Nat) (hi : i < df.nRows) : Array Value :=
    let rec go (j : Nat) (acc : Array Value) : Array Value :=
      if hj : j < df.columns.size then
        let col := df.columns[j]
        let val := col.values[i]'(by rw [df.columns_aligned j hj]; exact hi)
        go (j + 1) (acc.push val)
      else acc
    go 0 #[]

-- ----------------------------------------------------------
-- Smart constructors
-- ----------------------------------------------------------

/-- Validates that all columns have the same size, returning the common size
    or `none` if inconsistent.  Helper for `fromColumns`. -/
private def validateColumnLengths (cols : Array Column) : Option Nat :=
  if h : cols.size = 0 then
    some 0
  else
    let col0 : Column := cols[0]'(by omega)
    let nRows := col0.values.size
    if cols.all (·.values.size == nRows) then some nRows
    else none

/-- Construct a `DataFrame` from an array of columns.
    Returns `none` if the columns have inconsistent lengths.

    $$\text{fromColumns}(\text{cols}) = \begin{cases}
      \text{some}(\text{df}) & \text{if all columns have equal length} \\
      \text{none} & \text{otherwise}
    \end{cases}$$ -/
def fromColumns (cols : Array Column) : Option DataFrame :=
  if h0 : cols.size = 0 then
    some empty
  else
    let col0 : Column := cols[0]'(by omega)
    let nRows := col0.values.size
    -- Check that every column has the expected number of rows
    let allMatch := cols.all (·.values.size == nRows)
    if hallMatch : allMatch then
      some {
        columns := cols
        nRows := nRows
        columns_aligned := fun i hi =>
          eq_of_beq ((Array.all_eq_true.mp hallMatch) i hi)
      }
    else none

/-- Construct from row-oriented data.  Every row must have the same length
    as the header; short rows are padded with `Value.null`, extra cells are
    dropped.

    This constructor always succeeds and builds a valid `DataFrame`. -/
def fromRows (header : Array String) (rows : Array (Array Value)) : DataFrame :=
  let nRows := rows.size
  {
    columns := (Array.range header.size).map fun j =>
      let name := if h : j < header.size then header[j] else ""
      let vals := rows.map fun row =>
        if h : j < row.size then row[j] else Value.null
      { name := name, values := vals, colType := ColumnType.mixed : Column }
    nRows := nRows
    columns_aligned := fun i hi => by
      simp only [Array.size_map, Array.size_range] at hi
      simp only [Array.getElem_map, Array.getElem_range, Array.size_map]; rfl
  }

/-- Construct from named column pairs.  Returns `none` if the arrays have
    inconsistent lengths. -/
def fromNamedColumns (pairs : Array (String × Array Value)) : Option DataFrame :=
  let cols := pairs.map fun (name, vals) =>
    { name := name, values := vals, colType := ColumnType.mixed : Column }
  fromColumns cols

end DataFrame

-- ============================================================
-- GroupedDataFrame
-- ============================================================

/-- A DataFrame that has been split into groups by one or more key columns.

    Each group is a pair of (key values, sub-DataFrame).  `groupKeys` records
    which columns were used for grouping.

    $$\text{GroupedDataFrame} = (\text{groups} : \text{Array}(\text{Array Value} \times \text{DataFrame}))
      \times (\text{groupKeys} : \text{List String})$$ -/
structure GroupedDataFrame where
  /-- Each entry is (key-value tuple, sub-frame). -/
  groups : Array (Array Value × DataFrame)
  /-- Names of the columns that were used for grouping. -/
  groupKeys : List String

end DataFrame
