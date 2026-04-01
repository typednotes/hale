/-
  Hale.DataFrame.DataFrame.Operations.Aggregation — GroupBy and aggregation

  Group a DataFrame by column values, then aggregate each group
  using functions like sum, mean, count, min, max.
-/

import Hale.DataFrame.DataFrame.Internal.Types
import Hale.DataFrame.DataFrame.Operations.Statistics

namespace DataFrame

/-- Aggregation function to apply to a column within each group. -/
inductive AggFunc where
  | sum | mean | count | min | max | first | last | std | var
deriving BEq, Repr

instance : ToString AggFunc where
  toString
    | .sum => "sum" | .mean => "mean" | .count => "count"
    | .min => "min" | .max => "max" | .first => "first"
    | .last => "last" | .std => "std" | .var => "var"

/-- Group a DataFrame by one or more columns.
    Rows with equal values in the specified columns are collected into sub-DataFrames.
    $$\text{groupBy} : \text{DataFrame} \to \text{List String} \to \text{GroupedDataFrame}$$ -/
def DataFrame.groupBy (df : DataFrame) (groupCols : List String) : GroupedDataFrame :=
  -- Find the key column indices
  let keyIndices := groupCols.filterMap fun name =>
    df.columns.findIdx? fun c => c.name == name
  -- Build groups by unique key combinations
  let groups := Id.run do
    -- Map from key values to row indices
    let mut groupMap : List (Array Value × Array Nat) := []
    for rowIdx in [:df.nRows] do
      let keyVals := keyIndices.map (fun colIdx =>
        if h1 : colIdx < df.columns.size then
          let col := df.columns[colIdx]
          if h2 : rowIdx < col.values.size then col.values[rowIdx]
          else Value.null
        else Value.null) |>.toArray
      -- Find or create group
      match groupMap.findIdx? fun (k, _) => k == keyVals with
      | some idx =>
        let (k, rows) := groupMap[idx]!
        groupMap := groupMap.set idx (k, rows.push rowIdx)
      | none =>
        groupMap := groupMap ++ [(keyVals, #[rowIdx])]
    -- Convert to GroupedDataFrame
    let mut result : Array (Array Value × DataFrame) := #[]
    for (keyVals, rowIndices) in groupMap do
      let newCols := df.columns.map fun col =>
        let newVals := rowIndices.map fun idx =>
          if h : idx < col.values.size then col.values[idx]
          else Value.null
        { col with values := newVals }
      let subDf : DataFrame :=
        { columns := newCols
        , nRows := rowIndices.size
        , columns_aligned := by intro i h; sorry
        }
      result := result.push (keyVals, subDf)
    result
  { groups, groupKeys := groupCols }

/-- Apply an aggregation function to a column. -/
private def applyAgg (aggFunc : AggFunc) (col : Column) : Value :=
  match aggFunc with
  | .count => .int col.values.size
  | .sum =>
    match Column.Stats.sum col with
    | some f => .float f
    | none => .null
  | .mean =>
    match Column.Stats.mean col with
    | some f => .float f
    | none => .null
  | .min =>
    match Column.Stats.minValue col with
    | some v => v
    | none => .null
  | .max =>
    match Column.Stats.maxValue col with
    | some v => v
    | none => .null
  | .first =>
    if col.values.isEmpty then .null else col.values[0]!
  | .last =>
    if col.values.isEmpty then .null else col.values[col.values.size - 1]!
  | .std =>
    match Column.Stats.std col with
    | some f => .float f
    | none => .null
  | .var =>
    match Column.Stats.variance col with
    | some f => .float f
    | none => .null

/-- Aggregate a grouped DataFrame.
    Each `(colName, aggFunc)` pair produces one column in the result.
    The group key columns are always included first.
    $$\text{aggregate} : \text{GroupedDataFrame} \to \text{List (String × AggFunc)} \to \text{DataFrame}$$ -/
def GroupedDataFrame.aggregate (gdf : GroupedDataFrame) (specs : List (String × AggFunc)) : DataFrame :=
  let nGroups := gdf.groups.size
  -- Build key columns
  let keyArr := gdf.groupKeys.toArray
  let keyCols := (Array.range keyArr.size).map fun idx =>
    let name := if h : idx < keyArr.size then keyArr[idx] else ""
    let vals := gdf.groups.map fun (keyVals, _) =>
      if h : idx < keyVals.size then keyVals[idx]
      else Value.null
    Column.mk name vals .mixed
  -- Build aggregated columns
  let aggCols := specs.map fun (colName, aggFunc) =>
    let vals := gdf.groups.map fun (_, subDf) =>
      match subDf.columns.find? fun c => c.name == colName with
      | some col => applyAgg aggFunc col
      | none => Value.null
    let aggName := s!"{colName}_{aggFunc}"
    Column.mk aggName vals .mixed
  let allCols := keyCols ++ aggCols.toArray
  { columns := allCols
  , nRows := nGroups
  , columns_aligned := by intro i h; sorry
  }

end DataFrame
