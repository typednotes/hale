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
  if hsize : col.values.size = df.nRows then
    some { columns := df.columns.push col
         , nRows := df.nRows
         , columns_aligned := fun i h => by
             simp only [Array.size_push] at h
             simp only [Array.getElem_push]
             split
             · exact df.columns_aligned _ ‹_›
             · exact hsize }
  else none

/-- Add a computed column by applying a function to each row.
    The function receives the values of all columns for each row index. -/
def DataFrame.derive (df : DataFrame) (name : String) (colType : ColumnType)
    (f : Nat → Array Value → Value) : DataFrame :=
  { columns := df.columns.push
      ⟨name
      , (Array.range df.nRows).map fun rowIdx =>
          let row := df.columns.map fun col =>
            if h : rowIdx < col.values.size then col.values[rowIdx]
            else Value.null
          f rowIdx row
      , colType⟩
  , nRows := df.nRows
  , columns_aligned := fun i h => by
      simp only [Array.size_push] at h
      simp only [Array.getElem_push]
      split
      · exact df.columns_aligned _ ‹_›
      · simp [Array.size_map, Array.size_range] }

/-- Apply a function to transform all values in a named column. -/
def DataFrame.mapColumn (df : DataFrame) (colName : String) (f : Value → Value) : DataFrame :=
  { columns := df.columns.map fun col =>
      if col.name == colName then
        { col with values := col.values.map f }
      else col
  , nRows := df.nRows
  , columns_aligned := fun i h => by
      simp only [Array.size_map] at h
      simp only [Array.getElem_map]
      split
      · simp only [Array.size_map]; exact df.columns_aligned i h
      · exact df.columns_aligned i h }

/-- Drop a column by name. -/
def DataFrame.dropColumn (df : DataFrame) (colName : String) : DataFrame :=
  { columns := df.columns.filter fun col => col.name != colName
  , nRows := df.nRows
  , columns_aligned := fun i h => by
      have hmem : (df.columns.filter _)[i] ∈ df.columns :=
        (Array.mem_filter.mp (Array.getElem_mem h)).1
      obtain ⟨j, hj, hjv⟩ := Array.mem_iff_getElem.mp hmem
      have := df.columns_aligned j hj
      rwa [hjv] at this }

/-- Rename a single column. -/
def DataFrame.renameColumn (df : DataFrame) (oldName newName : String) : DataFrame :=
  { columns := df.columns.map fun col =>
      if col.name == oldName then { col with name := newName } else col
  , nRows := df.nRows
  , columns_aligned := fun i h => by
      simp only [Array.size_map] at h
      simp only [Array.getElem_map]
      split <;> exact df.columns_aligned i h }

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
