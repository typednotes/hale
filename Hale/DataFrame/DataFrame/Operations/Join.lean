/-
  Hale.DataFrame.DataFrame.Operations.Join — Table join operations

  Inner, left, right, and outer joins on shared key columns.
-/

import Hale.DataFrame.DataFrame.Internal.Types

namespace DataFrame

/-- Join type. -/
inductive JoinType where
  | inner | left | right | outer
deriving BEq, Repr

/-- Extract key values for a row from specified column indices. -/
private def extractKeyValues (df : DataFrame) (colIndices : Array Nat) (row : Nat) : Array Value :=
  colIndices.map fun ci =>
    if h1 : ci < df.columns.size then
      let col := df.columns[ci]
      if h2 : row < col.values.size then col.values[row]
      else .null
    else .null

/-- Get a row value from a column safely. -/
private def getVal (df : DataFrame) (colIdx row : Nat) : Value :=
  if h1 : colIdx < df.columns.size then
    let col := df.columns[colIdx]
    if h2 : row < col.values.size then col.values[row]
    else .null
  else .null

/-- Build a null row for a DataFrame (all null values). -/
private def nullRow (df : DataFrame) : Array Value :=
  df.columns.map fun _ => Value.null

/-- Reindex a column by a set of row pairs (for join operations). -/
private def reindexLeft (rowPairs : Array (Nat × Option Nat)) (nLeftRows : Nat) (col : Column) : Column :=
  { col with values := rowPairs.map fun (li, _) =>
      if li < nLeftRows then
        if h : li < col.values.size then col.values[li] else .null
      else .null }

/-- Reindex a right column by a set of row pairs (for join operations). -/
private def reindexRight (rowPairs : Array (Nat × Option Nat)) (col : Column) : Column :=
  { col with values := rowPairs.map fun (_, ri?) =>
      match ri? with
      | some ri => if h : ri < col.values.size then col.values[ri] else .null
      | none => .null }

/-- Generic join implementation. -/
private def joinImpl (left right : DataFrame) (on : List String) (how : JoinType) : DataFrame :=
  -- Find key column indices in both DataFrames
  let leftKeyIdx := on.filterMap fun name =>
    left.columns.findIdx? fun c => c.name == name
  let rightKeyIdx := on.filterMap fun name =>
    right.columns.findIdx? fun c => c.name == name
  -- Non-key columns from right (avoid duplicating key columns)
  let rightNonKeyCols := right.columns.filter fun c => !on.contains c.name
  -- Build result row pairs (left index, right index option)
  let rowPairs : Array (Nat × Option Nat) := Id.run do
    let mut result : Array (Nat × Option Nat) := #[]
    let mut rightMatched : Array Bool := Array.replicate right.nRows false
    for li in [:left.nRows] do
      let leftKey := extractKeyValues left leftKeyIdx.toArray li
      let mut matched := false
      for ri in [:right.nRows] do
        let rightKey := extractKeyValues right rightKeyIdx.toArray ri
        if leftKey == rightKey then
          result := result.push (li, some ri)
          rightMatched := rightMatched.set! ri true
          matched := true
      if !matched && (how == .left || how == .outer) then
        result := result.push (li, none)
    if how == .right || how == .outer then
      for ri in [:right.nRows] do
        if !rightMatched[ri]! then
          result := result.push (left.nRows, some ri)
    result
  let nResultRows := rowPairs.size
  let leftResultCols := left.columns.map (reindexLeft rowPairs left.nRows)
  let rightResultCols := rightNonKeyCols.map (reindexRight rowPairs)
  { columns := leftResultCols ++ rightResultCols
  , nRows := nResultRows
  , columns_aligned := fun i h => by
      have hlc : leftResultCols.size = left.columns.size := Array.size_map
      have hrc : rightResultCols.size = rightNonKeyCols.size := Array.size_map
      simp only [Array.size_append] at h
      simp only [Array.getElem_append]
      split
      · rename_i hlt
        exact DataFrame.map_column_aligned left.columns nResultRows
          (reindexLeft rowPairs left.nRows) (fun _ => Array.size_map)
          i (by rw [Array.size_map]; omega)
      · rename_i hge
        exact DataFrame.map_column_aligned rightNonKeyCols nResultRows
          (reindexRight rowPairs) (fun _ => Array.size_map)
          (i - leftResultCols.size) (by simp only [Array.size_map, Array.size_append] at *; omega)
  }

/-- Join two DataFrames on shared key columns. -/
def DataFrame.join (left right : DataFrame) (on : List String) (how : JoinType := .inner) : DataFrame :=
  joinImpl left right on how

/-- Inner join. -/
def DataFrame.innerJoin (left right : DataFrame) (on : List String) : DataFrame :=
  joinImpl left right on .inner

/-- Left join. -/
def DataFrame.leftJoin (left right : DataFrame) (on : List String) : DataFrame :=
  joinImpl left right on .left

/-- Right join. -/
def DataFrame.rightJoin (left right : DataFrame) (on : List String) : DataFrame :=
  joinImpl left right on .right

/-- Outer join. -/
def DataFrame.outerJoin (left right : DataFrame) (on : List String) : DataFrame :=
  joinImpl left right on .outer

end DataFrame
