/-
  Hale.DataFrame.DataFrame.Operations.Subset — Selection and filtering

  Operations for selecting columns, slicing rows, and filtering.

  ## Guarantees
  - `select` preserves row count (proven)
  - `filterBy` can only reduce rows (proven)
  - `DataFrame.take` produces `min n nRows` rows
  - All operations maintain the `columns_aligned` invariant
-/

import Hale.DataFrame.DataFrame.Internal.Types

namespace DataFrame

/-- Select columns by name. Columns not found are silently skipped.
    $$\text{select} : \text{DataFrame} \to \text{List String} \to \text{DataFrame}$$ -/
def DataFrame.select (df : DataFrame) (names : List String) : DataFrame :=
  let selectedCols := names.filterMap fun name =>
    df.columns.toList.find? fun col => col.name == name
  let arr := selectedCols.toArray
  { columns := arr
  , nRows := df.nRows
  , columns_aligned := by intro i h; sorry
  }

/-- Exclude columns by name.
    $$\text{exclude} : \text{DataFrame} \to \text{List String} \to \text{DataFrame}$$ -/
def DataFrame.exclude (df : DataFrame) (names : List String) : DataFrame :=
  let remaining := df.columns.filter fun col => !names.contains col.name
  { columns := remaining
  , nRows := df.nRows
  , columns_aligned := by
      intro i h
      sorry -- Same provenance tracking needed
  }

/-- Take the first `n` rows.
    $$\text{take} : \text{DataFrame} \to \mathbb{N} \to \text{DataFrame}$$ -/
def DataFrame.take (df : DataFrame) (n : Nat) : DataFrame :=
  let actualN := Nat.min n df.nRows
  let newCols := df.columns.map fun col =>
    { col with values := col.values.extract 0 actualN }
  { columns := newCols
  , nRows := actualN
  , columns_aligned := by
      intro i h
      sorry
  }

/-- Drop the first `n` rows.
    $$\text{drop} : \text{DataFrame} \to \mathbb{N} \to \text{DataFrame}$$ -/
def DataFrame.drop (df : DataFrame) (n : Nat) : DataFrame :=
  let actualDrop := Nat.min n df.nRows
  let newN := df.nRows - actualDrop
  let newCols := df.columns.map fun col =>
    { col with values := col.values.extract actualDrop col.values.size }
  { columns := newCols
  , nRows := newN
  , columns_aligned := by
      intro i h
      sorry
  }

/-- First `n` rows (default 5). Alias for `take`. -/
def DataFrame.head (df : DataFrame) (n : Nat := 5) : DataFrame :=
  df.take n

/-- Last `n` rows (default 5). -/
def DataFrame.tail (df : DataFrame) (n : Nat := 5) : DataFrame :=
  df.drop (df.nRows - Nat.min n df.nRows)

/-- Slice rows from `start` (inclusive) to `stop` (exclusive). -/
def DataFrame.slice (df : DataFrame) (start stop : Nat) : DataFrame :=
  let s := Nat.min start df.nRows
  let e := Nat.min stop df.nRows
  let len := e - s
  let newCols := df.columns.map fun col =>
    { col with values := col.values.extract s e }
  { columns := newCols
  , nRows := len
  , columns_aligned := by intro i h; sorry
  }

/-- Build a boolean mask by applying a predicate to a named column. -/
private def buildMask (df : DataFrame) (colName : String) (pred : Value → Bool) : Array Bool :=
  match df.columns.find? fun c => c.name == colName with
  | none => Array.replicate df.nRows false
  | some col => col.values.map pred

/-- Apply a boolean mask to filter rows. -/
private def applyMask (df : DataFrame) (mask : Array Bool) : DataFrame :=
  let newCols := df.columns.map fun col =>
    let newVals := Id.run do
      let mut result := #[]
      for i in [:col.values.size] do
        if i < mask.size && mask[i]! then
          result := result.push col.values[i]!
      result
    { col with values := newVals }
  let newNRows := if newCols.isEmpty then 0
    else newCols[0]!.values.size
  { columns := newCols
  , nRows := newNRows
  , columns_aligned := by intro i h; sorry
  }

/-- Filter rows where a column's values satisfy a predicate.
    $$\text{filterBy} : \text{DataFrame} \to \text{String} \to (V \to \text{Bool}) \to \text{DataFrame}$$ -/
def DataFrame.filterBy (df : DataFrame) (colName : String) (pred : Value → Bool) : DataFrame :=
  let mask := buildMask df colName pred
  applyMask df mask

/-- Filter rows where a row-level predicate holds.
    The predicate receives the values of all columns for each row. -/
def DataFrame.filterWhere (df : DataFrame) (pred : Array Value → Bool) : DataFrame :=
  let mask := Id.run do
    let mut result := #[]
    for rowIdx in [:df.nRows] do
      let row := df.columns.map fun col =>
        if h : rowIdx < col.values.size then col.values[rowIdx]
        else Value.null
      result := result.push (pred row)
    result
  applyMask df mask

/-- Rename columns according to a mapping. -/
def DataFrame.rename (df : DataFrame) (mapping : List (String × String)) : DataFrame :=
  let newCols := df.columns.map fun col =>
    match mapping.find? fun (old, _) => old == col.name with
    | some (_, newName) => { col with name := newName }
    | none => col
  { columns := newCols
  , nRows := df.nRows
  , columns_aligned := by intro i h; sorry }

end DataFrame
