/-
  Hale.DataFrame.DataFrame.Operations.Transform — Column transformations

  Add, remove, rename, and transform columns.
-/

import Hale.DataFrame.DataFrame.Internal.Types

namespace DataFrame

/-- Add a new column to the DataFrame.
    The column must have exactly `nRows` values.
    $$\text{addColumn} : \text{DataFrame} \to \text{Column} \to \text{Option DataFrame}$$ -/
def DataFrame.addColumn (df : DataFrame) (col : Column) : Option DataFrame :=
  if col.values.size == df.nRows then
    some { columns := df.columns.push col
         , nRows := df.nRows
         , columns_aligned := by intro i h; sorry }
  else none

/-- Add a computed column by applying a function to each row.
    The function receives the values of all columns for each row index. -/
def DataFrame.derive (df : DataFrame) (name : String) (colType : ColumnType)
    (f : Nat → Array Value → Value) : DataFrame :=
  let newVals := Id.run do
    let mut result := Array.mkEmpty df.nRows
    for rowIdx in [:df.nRows] do
      let row := df.columns.map fun col =>
        if h : rowIdx < col.values.size then col.values[rowIdx]
        else Value.null
      result := result.push (f rowIdx row)
    result
  let newCol : Column := ⟨name, newVals, colType⟩
  { columns := df.columns.push newCol
  , nRows := df.nRows
  , columns_aligned := by intro i h; sorry }

/-- Apply a function to transform all values in a named column. -/
def DataFrame.mapColumn (df : DataFrame) (colName : String) (f : Value → Value) : DataFrame :=
  let newCols := df.columns.map fun col =>
    if col.name == colName then
      { col with values := col.values.map f }
    else col
  { columns := newCols
  , nRows := df.nRows
  , columns_aligned := by intro i h; sorry }

/-- Drop a column by name. -/
def DataFrame.dropColumn (df : DataFrame) (colName : String) : DataFrame :=
  let newCols := df.columns.filter fun col => col.name != colName
  { columns := newCols
  , nRows := df.nRows
  , columns_aligned := by intro i h; sorry }

/-- Rename a single column. -/
def DataFrame.renameColumn (df : DataFrame) (oldName newName : String) : DataFrame :=
  let newCols := df.columns.map fun col =>
    if col.name == oldName then { col with name := newName } else col
  { columns := newCols
  , nRows := df.nRows
  , columns_aligned := by intro i h; sorry }

/-- Get the dimensions as (nRows, nColumns). -/
def DataFrame.dimensions (df : DataFrame) : Nat × Nat :=
  (df.nRows, df.columns.size)

/-- Get descriptive info about columns. -/
def DataFrame.info (df : DataFrame) : String := Id.run do
  let mut lines := #[s!"DataFrame: {df.nRows} rows × {df.columns.size} columns"]
  for col in df.columns do
    let nonNull := col.values.foldl (fun acc v => if v != .null then acc + 1 else acc) 0
    lines := lines.push s!"  {col.name}: {col.colType} ({nonNull} non-null)"
  "\n".intercalate lines.toList

end DataFrame
