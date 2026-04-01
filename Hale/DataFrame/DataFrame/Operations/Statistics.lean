/-
  Hale.DataFrame.DataFrame.Operations.Statistics — Statistical functions

  Column-level statistical computations: sum, mean, variance, standard
  deviation, median, min, max, count.

  ## Design
  All functions return `Option Float` to handle columns with no numeric
  values. Non-numeric values are silently skipped.
-/

import Hale.DataFrame.DataFrame.Internal.Types

namespace DataFrame

namespace Column.Stats

/-- Extract numeric values from a column as Floats, skipping nulls and non-numeric. -/
def numericValues (col : Column) : Array Float := Id.run do
  let mut result := #[]
  for v in col.values do
    match v with
    | .int n => result := result.push (Float.ofInt n)
    | .float f => result := result.push f
    | _ => pure ()
  result

/-- Count of all values (including null). -/
def count (col : Column) : Nat := col.values.size

/-- Count of non-null values. -/
def countNonNull (col : Column) : Nat := Id.run do
  let mut n := 0
  for v in col.values do
    match v with
    | .null => pure ()
    | _ => n := n + 1
  n

/-- Count of null values. -/
def countNull (col : Column) : Nat := Id.run do
  let mut n := 0
  for v in col.values do
    match v with
    | .null => n := n + 1
    | _ => pure ()
  n

/-- Sum of numeric values in the column.
    $$\text{sum} = \sum_{v \in \text{numeric}(col)} v$$ -/
def sum (col : Column) : Option Float :=
  let nums := numericValues col
  if nums.isEmpty then none
  else some (nums.foldl (· + ·) 0.0)

/-- Arithmetic mean of numeric values.
    $$\text{mean} = \frac{1}{n} \sum_{v} v$$ -/
def mean (col : Column) : Option Float :=
  let nums := numericValues col
  if nums.isEmpty then none
  else some (nums.foldl (· + ·) 0.0 / nums.size.toFloat)

/-- Population variance.
    $$\text{var} = \frac{1}{n} \sum_{v} (v - \bar{v})^2$$ -/
def variance (col : Column) : Option Float := do
  let nums := numericValues col
  if nums.isEmpty then none
  else
    let μ := nums.foldl (· + ·) 0.0 / nums.size.toFloat
    let sumSq := nums.foldl (fun acc v => acc + (v - μ) * (v - μ)) 0.0
    some (sumSq / nums.size.toFloat)

/-- Population standard deviation.
    $$\text{std} = \sqrt{\text{var}}$$ -/
def std (col : Column) : Option Float := do
  let v ← variance col
  some (Float.sqrt v)

/-- Minimum numeric value. -/
def min (col : Column) : Option Float :=
  let nums := numericValues col
  if nums.isEmpty then none
  else some (nums.foldl Min.min nums[0]!)

/-- Maximum numeric value. -/
def max (col : Column) : Option Float :=
  let nums := numericValues col
  if nums.isEmpty then none
  else some (nums.foldl Max.max nums[0]!)

/-- Median of numeric values (sorts then picks middle).
    $$\text{median} = \begin{cases} x_{n/2} & \text{if } n \text{ odd} \\
    \frac{x_{n/2-1} + x_{n/2}}{2} & \text{if } n \text{ even} \end{cases}$$ -/
def median (col : Column) : Option Float :=
  let nums := numericValues col
  if nums.isEmpty then none
  else
    let sorted := nums.toList.mergeSort (· ≤ ·) |>.toArray
    let n := sorted.size
    if n % 2 == 1 then
      some sorted[n / 2]!
    else
      some ((sorted[n / 2 - 1]! + sorted[n / 2]!) / 2.0)

/-- Minimum Value (works for any comparable type). -/
def minValue (col : Column) : Option Value :=
  if col.values.isEmpty then none
  else Id.run do
    let mut best := col.values[0]!
    for v in col.values do
      match v with
      | .null => pure ()
      | _ =>
        if best == .null then best := v
        else
          match (v, best) with
          | (.int a, .int b) => if a < b then best := v
          | (.float a, .float b) => if a < b then best := v
          | (.str a, .str b) => if a < b then best := v
          | _ => pure ()
    some best

/-- Maximum Value (works for any comparable type). -/
def maxValue (col : Column) : Option Value :=
  if col.values.isEmpty then none
  else Id.run do
    let mut best := col.values[0]!
    for v in col.values do
      match v with
      | .null => pure ()
      | _ =>
        if best == .null then best := v
        else
          match (v, best) with
          | (.int a, .int b) => if a > b then best := v
          | (.float a, .float b) => if a > b then best := v
          | (.str a, .str b) => if a > b then best := v
          | _ => pure ()
    some best

end Column.Stats

end DataFrame
