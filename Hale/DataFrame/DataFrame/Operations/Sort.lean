/-
  Hale.DataFrame.DataFrame.Operations.Sort — Sorting operations

  Sort a DataFrame by one or more columns in ascending or descending order.
-/

import Hale.DataFrame.DataFrame.Internal.Types

namespace DataFrame

/-- Sort order for a column. -/
inductive SortOrder where
  | asc | desc
deriving BEq, Repr

/-- Compare two Values. Returns an Ordering.
    Nulls sort last (greater than any non-null value). -/
def Value.compare (a b : Value) : Ordering :=
  match a, b with
  | .null, .null => .eq
  | .null, _ => .gt
  | _, .null => .lt
  | .int x, .int y => Ord.compare x y
  | .float x, .float y =>
    if x < y then .lt else if x > y then .gt else .eq
  | .str x, .str y => Ord.compare x y
  | .bool x, .bool y => Ord.compare x.toNat y.toNat
  -- Cross-type: int vs float
  | .int x, .float y =>
    let xf := Float.ofInt x
    if xf < y then .lt else if xf > y then .gt else .eq
  | .float x, .int y =>
    let yf := Float.ofInt y
    if x < yf then .lt else if x > yf then .gt else .eq
  -- Other cross-type comparisons: compare by type tag
  | a, b => Ord.compare (typeOrder a) (typeOrder b)
where
  typeOrder : Value → Nat
    | .bool _ => 0 | .int _ => 1 | .float _ => 2 | .str _ => 3 | .null => 4

/-- Build an array of row indices. -/
private def rowIndices (n : Nat) : Array Nat := Id.run do
  let mut arr := Array.mkEmpty n
  for i in [:n] do arr := arr.push i
  arr

/-- Get the value at (row, colIndex) from a DataFrame. -/
private def getValueAt (df : DataFrame) (row : Nat) (colIdx : Nat) : Value :=
  if h1 : colIdx < df.columns.size then
    let col := df.columns[colIdx]
    if h2 : row < col.values.size then col.values[row]
    else .null
  else .null

/-- Sort a DataFrame by a single column.
    $$\text{sortBy} : \text{DataFrame} \to \text{String} \to \text{SortOrder} \to \text{DataFrame}$$ -/
def DataFrame.sortBy (df : DataFrame) (colName : String) (order : SortOrder := .asc) : DataFrame :=
  match df.columns.findIdx? fun c => c.name == colName with
  | none => df  -- column not found, return unchanged
  | some colIdx =>
    -- Build row index array, sort by the column values
    let indices := rowIndices df.nRows
    let sorted := indices.toList.mergeSort fun i j =>
      let cmp := Value.compare (getValueAt df i colIdx) (getValueAt df j colIdx)
      match order with
      | .asc => cmp != .gt
      | .desc => cmp != .lt
    let sortedIdx := sorted.toArray
    -- Reorder all columns according to sorted indices
    let newCols := df.columns.map fun col =>
      let newVals := sortedIdx.map fun idx =>
        if h : idx < col.values.size then col.values[idx]
        else .null
      { col with values := newVals }
    { columns := newCols
    , nRows := df.nRows
    , columns_aligned := by intro i h; sorry
    }

/-- Sort by multiple columns (first column is primary sort key).
    $$\text{sortByMultiple} : \text{DataFrame} \to \text{List (String × SortOrder)} \to \text{DataFrame}$$ -/
def DataFrame.sortByMultiple (df : DataFrame) (specs : List (String × SortOrder)) : DataFrame :=
  -- Find column indices for all sort keys
  let colSpecs := specs.filterMap fun (name, order) =>
    (df.columns.findIdx? fun c => c.name == name).map fun idx => (idx, order)
  if colSpecs.isEmpty then df
  else
    let indices := rowIndices df.nRows
    let sorted := indices.toList.mergeSort fun i j =>
      let rec cmpBy : List (Nat × SortOrder) → Bool
        | [] => true  -- equal by all keys
        | (colIdx, order) :: rest =>
          let cmp := Value.compare (getValueAt df i colIdx) (getValueAt df j colIdx)
          match cmp with
          | .eq => cmpBy rest
          | .lt => order == .asc
          | .gt => order == .desc
      cmpBy colSpecs
    let sortedIdx := sorted.toArray
    let newCols := df.columns.map fun col =>
      let newVals := sortedIdx.map fun idx =>
        if h : idx < col.values.size then col.values[idx]
        else .null
      { col with values := newVals }
    { columns := newCols
    , nRows := df.nRows
    , columns_aligned := by intro i h; sorry
    }

end DataFrame
