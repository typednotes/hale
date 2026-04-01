/-
  Hale.DataFrame.DataFrame.Internal.Column — Column-level operations

  Provides column construction, type inference, and element-wise transformations.

  ## Design

  Columns are the primary unit of storage in a DataFrame.  This module adds
  operations that work on individual columns without requiring the DataFrame
  rectangular invariant.  All functions are pure and total.

  ## Key Operations

  - `inferType` — scans values to determine the predominant `ColumnType`
  - `mk'` — smart constructor that auto-infers the column type
  - `mapValues` — apply a function to every cell
  - `filterByMask` — select elements by a boolean mask
  - `toFloats` — extract numeric values as `Option Float`
  - `toStrings` — render every value as `String`

  ## Performance

  - Single-pass type inference via fold
  - `filterByMask` uses `Array.zipWith` semantics (stops at shorter array)
-/

import Hale.DataFrame.DataFrame.Internal.Types

namespace DataFrame
namespace Column

/-- Infer the predominant `ColumnType` from an array of values.

    Algorithm: scan all non-null values.  If they are all the same variant,
    return that variant; otherwise return `mixed`.  An all-null (or empty)
    array returns `mixed`.

    $$\text{inferType}(vs) = \begin{cases}
      t & \text{if all non-null } v_i \text{ have } v_i.\text{columnType} = t \\
      \text{mixed} & \text{otherwise}
    \end{cases}$$ -/
def inferType (values : Array Value) : ColumnType :=
  let nonNull := values.filter (· != Value.null)
  if nonNull.size == 0 then
    .mixed
  else
    let first := (nonNull[0]!).columnType
    if nonNull.all (·.columnType == first) then first
    else .mixed

/-- Smart constructor: build a `Column` from a name and values, automatically
    inferring the column type.

    $$\text{mk'}(\text{name}, \text{vals}) = \text{Column}(\text{name}, \text{vals}, \text{inferType}(\text{vals}))$$ -/
def mk' (name : String) (values : Array Value) : Column :=
  { name := name, values := values, colType := inferType values }

/-- Map a function over every value in the column.  The resulting column
    has `mixed` type since the function may change value types.

    $$\text{mapValues}(f, c) = c[\text{values} \mapsto f^*(\text{values}), \text{colType} \mapsto \text{mixed}]$$ -/
def mapValues (f : Value → Value) (c : Column) : Column :=
  { name := c.name, values := c.values.map f, colType := .mixed }

/-- Re-infer the column type after a transformation.  Useful after `mapValues`
    to restore a precise type tag. -/
def reInferType (c : Column) : Column :=
  { c with colType := inferType c.values }

/-- Filter elements by a boolean mask.  The mask and column are aligned
    positionally; if the mask is shorter than the column, trailing elements
    are dropped.  If the mask is longer, extra mask entries are ignored.

    $$\text{filterByMask}(\text{mask}, c) = c[\text{values} \mapsto
      \{v_i \mid \text{mask}[i] = \text{true}\}]$$ -/
def filterByMask (mask : Array Bool) (c : Column) : Column :=
  let filtered := Id.run do
    let mut result : Array Value := #[]
    let len := min mask.size c.values.size
    for i in [:len] do
      let v := c.values[i]!
      if i < mask.size then
        if mask[i]! then
          result := result.push v
    return result
  { name := c.name, values := filtered, colType := c.colType }

/-- Extract numeric values as `Option Float`.  Non-numeric values (including
    nulls) become `none`.

    $$\text{toFloats}(c)[i] = c.\text{values}[i].\text{toFloat?}$$ -/
def toFloats (c : Column) : Array (Option Float) :=
  c.values.map Value.toFloat?

/-- Render every value as a `String`.  Uses `ToString Value`.

    $$\text{toStrings}(c)[i] = \text{toString}(c.\text{values}[i])$$ -/
def toStrings (c : Column) : Array String :=
  c.values.map toString

/-- Count the number of null values in this column.

    $$\text{nullCount}(c) = |\{i \mid c.\text{values}[i] = \text{null}\}|$$ -/
def nullCount (c : Column) : Nat :=
  c.values.foldl (fun acc v => if v.isNull then acc + 1 else acc) 0

/-- Count the number of non-null values in this column.

    $$\text{nonNullCount}(c) = |c.\text{values}| - \text{nullCount}(c)$$ -/
def nonNullCount (c : Column) : Nat :=
  c.size - c.nullCount

/-- Take the first `n` elements of the column. -/
def take (n : Nat) (c : Column) : Column :=
  { name := c.name, values := c.values.extract 0 n, colType := c.colType }

/-- Drop the first `n` elements of the column. -/
def drop (n : Nat) (c : Column) : Column :=
  { name := c.name, values := c.values.extract n c.values.size, colType := c.colType }

/-- Unique values in the column (preserving first-occurrence order). -/
def unique (c : Column) : Array Value := Id.run do
  let mut seen : Array Value := #[]
  for v in c.values do
    unless seen.contains v do
      seen := seen.push v
  return seen

end Column
end DataFrame
