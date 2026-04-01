/-
  Hale.DataFrame.DataFrame.Display — Display formatting for DataFrames

  Provides human-readable and machine-readable rendering of DataFrames,
  including aligned plain-text tables and Markdown tables.

  ## Design

  Display functions take a `maxRows` parameter (default 20) to truncate
  large DataFrames.  When truncation occurs, an ellipsis row is inserted
  and a summary footer is appended showing the total row count.

  Column widths are computed from the header name and all displayed values,
  with a configurable maximum width (default 30 characters) to prevent
  excessively wide columns from dominating the output.

  ## Guarantees

  - Pure functions: no IO, no side effects
  - All row accesses go through `DataFrame.getRowSafe` or equivalent,
    which is bounds-safe by the `columns_aligned` proof
-/

import Hale.DataFrame.DataFrame.Internal.Types
import Hale.DataFrame.DataFrame.Internal.Column

namespace DataFrame

-- ============================================================
-- Helpers
-- ============================================================

/-- Right-pad a string to the given width with spaces.  If the string is
    already wider, it is truncated and suffixed with "..". -/
private def padRight (s : String) (width : Nat) : String :=
  let maxDisplay := width
  if s.length > maxDisplay then
    (s.take (maxDisplay - 2)).toString ++ ".."
  else
    s ++ String.ofList (List.replicate (maxDisplay - s.length) ' ')

/-- Left-pad a string to the given width with spaces. -/
private def padLeft (s : String) (width : Nat) : String :=
  if s.length >= width then s
  else String.ofList (List.replicate (width - s.length) ' ') ++ s

/-- Render a `Value` as a display string. -/
private def valueToDisplayString : Value → String
  | .int n   => toString n
  | .float f => toString f
  | .str s   => s
  | .bool b  => if b then "true" else "false"
  | .null    => "<null>"

/-- Maximum column display width. -/
private def maxColWidth : Nat := 30

/-- Compute the display width for a column given header and cell strings. -/
private def computeColumnWidth (header : String) (cells : Array String) : Nat :=
  let headerWidth := header.length
  let maxCellWidth := cells.foldl (fun acc s => max acc s.length) 0
  min maxColWidth (max headerWidth maxCellWidth)

-- ============================================================
-- Plain text display
-- ============================================================

namespace DataFrame

/-- Render the DataFrame as a plain-text aligned table.

    $$\text{toString}(\text{df}, \text{maxRows}) = \text{header} + \text{separator} + \text{rows}$$

    When the DataFrame has more than `maxRows` rows, the first `maxRows/2`
    and last `maxRows/2` rows are shown with an ellipsis row in between.

    @param df The DataFrame to display
    @param maxRows Maximum number of data rows to show (default 20) -/
def toString (df : DataFrame) (maxRows : Nat := 20) : String :=
  if df.nColumns == 0 then
    "(empty DataFrame: 0 columns, 0 rows)"
  else
    -- Determine which rows to display
    let (displayRows, truncated) :=
      if df.nRows ≤ maxRows then
        (List.range df.nRows, false)
      else
        let half := maxRows / 2
        let firstRows := List.range half
        let lastRows := List.range (df.nRows - half) |>.map (· + half)
        -- We show only the bookend rows; "..." row will be inserted
        (firstRows ++ lastRows, true)

    -- Render cell strings for display rows
    let cellStrings : Array (Array String) := Id.run do
      let mut rows : Array (Array String) := #[]
      for idx in displayRows do
        let mut row : Array String := #[]
        for col in df.columns do
          let val := if idx < col.values.size then col.values[idx]! else Value.null
          row := row.push (valueToDisplayString val)
        rows := rows.push row
      return rows

    -- Compute column widths
    let colWidths : Array Nat := Id.run do
      let mut widths : Array Nat := #[]
      for j in [:df.columns.size] do
        let header := (df.columns[j]!).name
        let cells := cellStrings.map fun row =>
          if j < row.size then row[j]! else ""
        widths := widths.push (computeColumnWidth header cells)
      return widths

    -- Build header line
    let headerParts : Array String := Id.run do
      let mut parts : Array String := #[]
      for j in [:df.columns.size] do
        let w := if j < colWidths.size then colWidths[j]! else 10
        parts := parts.push (padRight (df.columns[j]!).name w)
      return parts
    let headerLine := " " ++ (headerParts.toList |> String.intercalate " | ") ++ " "

    -- Build separator line
    let sepParts : Array String := Id.run do
      let mut parts : Array String := #[]
      for j in [:colWidths.size] do
        parts := parts.push (String.ofList (List.replicate (colWidths[j]!) '-'))
      return parts
    let sepLine := "-" ++ (sepParts.toList |> String.intercalate "-+-") ++ "-"

    -- Build data lines
    let dataLines : Array String := Id.run do
      let mut lines : Array String := #[]
      let half := maxRows / 2
      for i in [:cellStrings.size] do
        -- Insert ellipsis row at the truncation point
        if truncated && i == half then
          let ellipsisParts : Array String := colWidths.map fun w => padRight "..." w
          lines := lines.push (" " ++ (ellipsisParts.toList |> String.intercalate " | ") ++ " ")
        let row := cellStrings[i]!
        let mut parts : Array String := #[]
        for j in [:df.columns.size] do
          let w := if j < colWidths.size then colWidths[j]! else 10
          let cell := if j < row.size then row[j]! else ""
          parts := parts.push (padRight cell w)
        lines := lines.push (" " ++ (parts.toList |> String.intercalate " | ") ++ " ")
      return lines

    -- Assemble
    let allLines := #[headerLine, sepLine] ++ dataLines
    let table := allLines.toList |> String.intercalate "\n"
    if truncated then
      table ++ s!"\n[{df.nRows} rows x {df.nColumns} columns]"
    else
      table ++ s!"\n({df.nRows} rows x {df.nColumns} columns)"

-- ============================================================
-- Markdown display
-- ============================================================

/-- Render the DataFrame as a Markdown table.

    @param df The DataFrame to display
    @param maxRows Maximum number of data rows to show (default 20) -/
def toMarkdown (df : DataFrame) (maxRows : Nat := 20) : String :=
  if df.nColumns == 0 then
    "_empty DataFrame_"
  else
    let displayCount := min maxRows df.nRows

    -- Header
    let headerCells := df.columns.map (·.name)
    let headerLine := "| " ++ (headerCells.toList |> String.intercalate " | ") ++ " |"

    -- Separator
    let sepCells := df.columns.map fun _ => "---"
    let sepLine := "| " ++ (sepCells.toList |> String.intercalate " | ") ++ " |"

    -- Data rows
    let dataLines : Array String := Id.run do
      let mut lines : Array String := #[]
      for i in [:displayCount] do
        let mut cells : Array String := #[]
        for col in df.columns do
          let val := if i < col.values.size then col.values[i]! else Value.null
          cells := cells.push (valueToDisplayString val)
        lines := lines.push ("| " ++ (cells.toList |> String.intercalate " | ") ++ " |")
      return lines

    let allLines := #[headerLine, sepLine] ++ dataLines
    let table := allLines.toList |> String.intercalate "\n"
    if df.nRows > maxRows then
      table ++ s!"\n\n_...and {df.nRows - maxRows} more rows ({df.nRows} total)_"
    else
      table

end DataFrame

-- ============================================================
-- Instances
-- ============================================================

instance : ToString DataFrame where
  toString df := df.toString

instance : Repr DataFrame where
  reprPrec df _ :=
    let header := s!"DataFrame({df.nRows} rows x {df.nColumns} columns)"
    let colInfo := df.columns.toList.map fun c =>
      s!"  {c.name} : {c.colType}"
    let lines := header :: colInfo
    Std.Format.text (lines |> String.intercalate "\n")

end DataFrame
