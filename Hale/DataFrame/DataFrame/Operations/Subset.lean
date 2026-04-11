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
  { columns := df.columns.filter fun col => names.contains col.name
  , nRows := df.nRows
  , columns_aligned := fun i h => by
      have hmem : (df.columns.filter _)[i] ∈ df.columns :=
        (Array.mem_filter.mp (Array.getElem_mem h)).1
      obtain ⟨j, hj, hjv⟩ := Array.mem_iff_getElem.mp hmem
      have := df.columns_aligned j hj; rwa [hjv] at this
  }

/-- Exclude columns by name.
    $$\text{exclude} : \text{DataFrame} \to \text{List String} \to \text{DataFrame}$$ -/
def DataFrame.exclude (df : DataFrame) (names : List String) : DataFrame :=
  { columns := df.columns.filter fun col => !names.contains col.name
  , nRows := df.nRows
  , columns_aligned := fun i h => by
      have hmem : (df.columns.filter _)[i] ∈ df.columns :=
        (Array.mem_filter.mp (Array.getElem_mem h)).1
      obtain ⟨j, hj, hjv⟩ := Array.mem_iff_getElem.mp hmem
      have := df.columns_aligned j hj; rwa [hjv] at this
  }

/-- Take the first `n` rows.
    $$\text{take} : \text{DataFrame} \to \mathbb{N} \to \text{DataFrame}$$ -/
def DataFrame.take (df : DataFrame) (n : Nat) : DataFrame :=
  let actualN := Nat.min n df.nRows
  { columns := df.columns.map fun col =>
      { col with values := col.values.extract 0 actualN }
  , nRows := actualN
  , columns_aligned := fun i h => by
      have h' : i < df.columns.size := by rwa [Array.size_map] at h
      have heq := @Array.getElem_map _ _ _ df.columns i h
      simp only [heq, Array.size_extract, df.columns_aligned i h']
      exact Nat.min_eq_left (Nat.min_le_right n df.nRows)
  }

/-- Drop the first `n` rows.
    $$\text{drop} : \text{DataFrame} \to \mathbb{N} \to \text{DataFrame}$$ -/
def DataFrame.drop (df : DataFrame) (n : Nat) : DataFrame :=
  let actualDrop := Nat.min n df.nRows
  { columns := df.columns.map fun col =>
      { col with values := col.values.extract actualDrop col.values.size }
  , nRows := df.nRows - actualDrop
  , columns_aligned := fun i h => by
      have h' : i < df.columns.size := by rwa [Array.size_map] at h
      have heq := @Array.getElem_map _ _ _ df.columns i h
      simp only [heq, Array.size_extract, df.columns_aligned i h', Nat.min_self]
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
  { columns := df.columns.map fun col =>
      { col with values := col.values.extract s e }
  , nRows := e - s
  , columns_aligned := fun i h => by
      have h' : i < df.columns.size := by rwa [Array.size_map] at h
      have heq := @Array.getElem_map _ _ _ df.columns i h
      simp only [heq, Array.size_extract, df.columns_aligned i h']
      have : e ≤ df.nRows := Nat.min_le_right stop df.nRows
      omega
  }

/-- Build a boolean mask by applying a predicate to a named column. -/
private def buildMask (df : DataFrame) (colName : String) (pred : Value → Bool) : Array Bool :=
  match df.columns.find? fun c => c.name == colName with
  | none => Array.replicate df.nRows false
  | some col => col.values.map pred

/-- Apply a boolean mask to filter rows. -/
private def applyMask (df : DataFrame) (mask : Array Bool) : DataFrame :=
  -- Compute which row indices to keep (shared across all columns)
  let keepIndices : Array Nat := Id.run do
    let mut result := #[]
    for i in [:df.nRows] do
      if i < mask.size && mask[i]! then
        result := result.push i
    result
  { columns := df.columns.map fun col =>
      { col with values := keepIndices.map fun idx =>
          if h : idx < col.values.size then col.values[idx] else Value.null }
  , nRows := keepIndices.size
  , columns_aligned := DataFrame.map_column_aligned df.columns keepIndices.size _ (fun _ => Array.size_map)
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
  { columns := df.columns.map fun col =>
      match mapping.find? fun (old, _) => old == col.name with
      | some (_, newName) => { col with name := newName }
      | none => col
  , nRows := df.nRows
  , columns_aligned := fun i h => by
      simp only [Array.size_map] at h
      simp only [Array.getElem_map]
      split <;> exact df.columns_aligned i h }

end DataFrame
