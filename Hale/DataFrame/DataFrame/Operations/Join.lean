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

/-- Generic join implementation. -/
private def joinImpl (left right : DataFrame) (on : List String) (how : JoinType) : DataFrame :=
  -- Find key column indices in both DataFrames
  let leftKeyIdx := on.filterMap fun name =>
    left.columns.findIdx? fun c => c.name == name
  let rightKeyIdx := on.filterMap fun name =>
    right.columns.findIdx? fun c => c.name == name
  -- Non-key columns from right (avoid duplicating key columns)
  let rightNonKeyCols := right.columns.filter fun c => !on.contains c.name
  -- Build result rows
  let (leftRows, rightRows) := Id.run do
    let mut lRows : Array Nat := #[]          -- left row indices
    let mut rRows : Array (Option Nat) := #[]  -- right row indices (none = null row)
    let mut rightMatched : Array Bool := Array.replicate right.nRows false
    -- For each left row, find matching right rows
    for li in [:left.nRows] do
      let leftKey := extractKeyValues left leftKeyIdx.toArray li
      let mut matched := false
      for ri in [:right.nRows] do
        let rightKey := extractKeyValues right rightKeyIdx.toArray ri
        if leftKey == rightKey then
          lRows := lRows.push li
          rRows := rRows.push (some ri)
          rightMatched := rightMatched.set! ri true
          matched := true
      -- Left/outer join: include unmatched left rows
      if !matched && (how == .left || how == .outer) then
        lRows := lRows.push li
        rRows := rRows.push none
    -- Right/outer join: include unmatched right rows
    if how == .right || how == .outer then
      for ri in [:right.nRows] do
        if !rightMatched[ri]! then
          lRows := lRows.push left.nRows  -- sentinel for "no left row"
          rRows := rRows.push (some ri)
    (lRows, rRows)
  -- Build result columns
  let nResultRows := leftRows.size
  -- Left columns (all)
  let leftResultCols := left.columns.map fun col =>
    let vals := leftRows.map fun li =>
      if li < left.nRows then
        if h : li < col.values.size then col.values[li] else .null
      else .null
    { col with values := vals }
  -- Right non-key columns
  let rightResultCols := rightNonKeyCols.map fun col =>
    let vals := rightRows.map fun ri? =>
      match ri? with
      | some ri => if h : ri < col.values.size then col.values[ri] else .null
      | none => .null
    { col with values := vals }
  { columns := leftResultCols ++ rightResultCols
  , nRows := nResultRows
  , columns_aligned := by intro i h; sorry
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
