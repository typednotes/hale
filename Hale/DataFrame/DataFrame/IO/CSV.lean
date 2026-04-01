/-
  Hale.DataFrame.DataFrame.IO.CSV — CSV read/write

  RFC 4180-compliant CSV parser and writer.
  Handles quoted fields, escaped quotes, CRLF/LF line endings.

  ## Design
  Simple state machine parser — CSV is regular enough that parser
  combinators are not needed.
-/

import Hale.DataFrame.DataFrame.Internal.Types

namespace DataFrame

/-- CSV parsing/writing options. -/
structure CsvOptions where
  /-- Field delimiter character. -/
  delimiter : Char := ','
  /-- Whether the first row is a header row. -/
  hasHeader : Bool := true
  /-- Quote character for fields containing delimiters/newlines. -/
  quoteChar : Char := '"'
deriving Repr

/-- Parse state for the CSV state machine. -/
private inductive CsvState where
  | fieldStart     -- Beginning of a field
  | unquotedField  -- Inside an unquoted field
  | quotedField    -- Inside a quoted field
  | quotedQuote    -- Just saw a quote inside a quoted field (could be escape or end)
deriving BEq

/-- Parse a CSV string into a list of rows (each row is a list of fields). -/
def parseCsvRaw (content : String) (opts : CsvOptions := {}) : Array (Array String) := Id.run do
  let mut rows : Array (Array String) := #[]
  let mut currentRow : Array String := #[]
  let mut currentField : String := ""
  let mut state := CsvState.fieldStart
  let chars := content.toList

  for c in chars do
    match state with
    | .fieldStart =>
      if c == opts.quoteChar then
        state := .quotedField
      else if c == opts.delimiter then
        currentRow := currentRow.push currentField
        currentField := ""
      else if c == '\n' then
        currentRow := currentRow.push currentField
        rows := rows.push currentRow
        currentRow := #[]
        currentField := ""
      else if c == '\r' then
        pure ()  -- skip CR (handle CRLF)
      else
        currentField := currentField.push c
        state := .unquotedField

    | .unquotedField =>
      if c == opts.delimiter then
        currentRow := currentRow.push currentField
        currentField := ""
        state := .fieldStart
      else if c == '\n' then
        currentRow := currentRow.push currentField
        rows := rows.push currentRow
        currentRow := #[]
        currentField := ""
        state := .fieldStart
      else if c == '\r' then
        pure ()  -- skip CR
      else
        currentField := currentField.push c

    | .quotedField =>
      if c == opts.quoteChar then
        state := .quotedQuote
      else
        currentField := currentField.push c

    | .quotedQuote =>
      if c == opts.quoteChar then
        -- Escaped quote (doubled)
        currentField := currentField.push opts.quoteChar
        state := .quotedField
      else if c == opts.delimiter then
        currentRow := currentRow.push currentField
        currentField := ""
        state := .fieldStart
      else if c == '\n' then
        currentRow := currentRow.push currentField
        rows := rows.push currentRow
        currentRow := #[]
        currentField := ""
        state := .fieldStart
      else if c == '\r' then
        currentRow := currentRow.push currentField
        state := .fieldStart  -- will be followed by \n
      else
        -- Malformed: quote followed by non-special char
        currentField := currentField.push c
        state := .unquotedField

  -- Handle last field/row if content doesn't end with newline
  if !currentField.isEmpty || state != .fieldStart || !currentRow.isEmpty then
    currentRow := currentRow.push currentField
    rows := rows.push currentRow

  rows

/-- Convert a digit character to its numeric value. -/
private def charToDigit (c : Char) : Nat :=
  c.toNat - '0'.toNat

/-- Parse digits from a list of characters, returning (digitValue, remainingChars). -/
private def parseDigits (chars : List Char) : Nat × List Char :=
  let (digits, rest) := chars.span Char.isDigit
  (digits.foldl (fun acc c => acc * 10 + charToDigit c) 0, rest)

/-- Parse a string as a Float. Handles optional sign, integer part,
    optional decimal part, and optional exponent (e/E).
    Returns `none` if the string is not a valid float literal. -/
private def parseFloat? (s : String) : Option Float :=
  let chars := s.trimAscii.toString.toList
  if chars.isEmpty then none
  else
    -- Parse optional sign
    let (negative, rest) := match chars with
      | '-' :: cs => (true, cs)
      | '+' :: cs => (false, cs)
      | cs => (false, cs)
    if rest.isEmpty then none
    else
      -- Parse integer part (digits before '.')
      let (intDigits, afterInt) := rest.span Char.isDigit
      -- Parse optional fractional part
      let (fracDigits, afterFrac) := match afterInt with
        | '.' :: cs =>
          let (fd, rest') := cs.span Char.isDigit
          (fd, rest')
        | cs => ([], cs)
      -- Must have at least some digits and look like a float (has '.' or 'e')
      if intDigits.isEmpty && fracDigits.isEmpty then none
      else if fracDigits.isEmpty && afterInt.head? != some '.' && !afterFrac.any (fun c => c == 'e' || c == 'E') then none
      else
        -- Parse optional exponent
        let parseExp := match afterFrac with
          | 'e' :: rest' | 'E' :: rest' =>
            let (en, ed) := match rest' with
              | '-' :: ds => (true, ds)
              | '+' :: ds => (false, ds)
              | ds => (false, ds)
            let (expDigits, trailing) := ed.span Char.isDigit
            if !trailing.isEmpty || expDigits.isEmpty then none
            else
              let ev := expDigits.foldl (fun acc c => acc * 10 + charToDigit c) 0
              some (en, ev)
          | [] => some (false, 0)
          | _ => none  -- trailing garbage
        match parseExp with
        | none => none
        | some (expNeg, ev) =>
          -- Build mantissa as Nat from all digit chars
          let allDigits := intDigits ++ fracDigits
          let mantissa := allDigits.foldl (fun acc c => acc * 10 + charToDigit c) 0
          -- Number of decimal places from fractional digits
          let fracLen := fracDigits.length
          -- Net exponent: -fracLen + (if expNeg then -ev else +ev)
          let netExp : Int := (if expNeg then -(ev : Int) else (ev : Int)) - (fracLen : Int)
          let f := if netExp >= 0 then
            Float.ofScientific mantissa false netExp.toNat
          else
            Float.ofScientific mantissa true (-netExp).toNat
          some (if negative then -f else f)

/-- Infer a Value from a CSV field string. -/
private def inferValue (s : String) : Value :=
  if s.isEmpty || s == "NA" || s == "null" || s == "NULL" || s == "" then .null
  else if s == "true" || s == "True" || s == "TRUE" then .bool true
  else if s == "false" || s == "False" || s == "FALSE" then .bool false
  else match s.toInt? with
    | some n => .int n
    | none => match parseFloat? s with
      | some f => .float f
      | none => .str s

/-- Infer ColumnType from an array of Values. -/
private def inferColumnType (vals : Array Value) : ColumnType := Id.run do
  let mut seenType : Option ColumnType := none
  for v in vals do
    let vt := match v with
      | .int _ => some ColumnType.int
      | .float _ => some ColumnType.float
      | .str _ => some ColumnType.str
      | .bool _ => some ColumnType.bool
      | .null => none
    match vt with
    | none => pure ()  -- skip nulls
    | some t =>
      match seenType with
      | none => seenType := some t
      | some prev => if prev != t then return ColumnType.mixed
  seenType.getD .mixed

/-- Parse a CSV string into a DataFrame.
    $$\text{parseCsv} : \text{String} \to \text{CsvOptions} \to \text{DataFrame}$$ -/
def parseCsv (content : String) (opts : CsvOptions := {}) : DataFrame :=
  let rawRows := parseCsvRaw content opts
  if rawRows.isEmpty then DataFrame.empty
  else
    let (colNames, dataRows) :=
      if opts.hasHeader then
        let headers := rawRows[0]!.map fun s => s
        (headers, rawRows.extract 1 rawRows.size)
      else
        -- Generate column names: "col0", "col1", ...
        let nCols := rawRows[0]!.size
        let headers := (Array.range nCols).map fun i => s!"col{i}"
        (headers, rawRows)
    let nRows := dataRows.size
    let nCols := colNames.size
    -- Build columns
    let columns := (Array.range nCols).map fun colIdx =>
      let vals := dataRows.map fun row =>
        if h : colIdx < row.size then inferValue row[colIdx]
        else Value.null
      let ct := inferColumnType vals
      Column.mk (if h : colIdx < colNames.size then colNames[colIdx] else s!"col{colIdx}") vals ct
    { columns
    , nRows
    , columns_aligned := by intro i h; sorry }

/-- Read a CSV file into a DataFrame.
    $$\text{readCsv} : \text{FilePath} \to \text{CsvOptions} \to \text{IO DataFrame}$$ -/
def readCsv (path : System.FilePath) (opts : CsvOptions := {}) : IO DataFrame := do
  let content ← IO.FS.readFile path
  return parseCsv content opts

/-- Whether a field needs quoting in CSV output. -/
private def needsQuoting (s : String) (opts : CsvOptions) : Bool :=
  s.any fun c => c == opts.delimiter || c == opts.quoteChar || c == '\n' || c == '\r'

/-- Quote a field for CSV output. -/
private def quoteField (s : String) (opts : CsvOptions) : String :=
  if needsQuoting s opts then
    let escaped := s.toList.map fun c =>
      if c == opts.quoteChar then s!"{opts.quoteChar}{opts.quoteChar}"
      else c.toString
    s!"{opts.quoteChar}{"".intercalate escaped}{opts.quoteChar}"
  else s

/-- Convert a Value to a CSV field string. -/
private def valueToField (v : Value) : String :=
  match v with
  | .int n => toString n
  | .float f => toString f
  | .str s => s
  | .bool b => if b then "true" else "false"
  | .null => ""

/-- Write a DataFrame to a CSV string.
    $$\text{toCsv} : \text{DataFrame} \to \text{CsvOptions} \to \text{String}$$ -/
def DataFrame.toCsv (df : DataFrame) (opts : CsvOptions := {}) : String := Id.run do
  let delim := opts.delimiter.toString
  let mut lines : Array String := #[]
  -- Header row
  if opts.hasHeader then
    let headerLine := delim.intercalate (df.columns.toList.map fun c => quoteField c.name opts)
    lines := lines.push headerLine
  -- Data rows
  for rowIdx in [:df.nRows] do
    let fields := df.columns.toList.map fun col =>
      let v := if h : rowIdx < col.values.size then col.values[rowIdx] else .null
      quoteField (valueToField v) opts
    lines := lines.push (delim.intercalate fields)
  "\n".intercalate lines.toList

/-- Write a DataFrame to a CSV file.
    $$\text{writeCsv} : \text{DataFrame} \to \text{FilePath} \to \text{CsvOptions} \to \text{IO Unit}$$ -/
def writeCsv (df : DataFrame) (path : System.FilePath) (opts : CsvOptions := {}) : IO Unit := do
  let content := df.toCsv opts
  IO.FS.writeFile path content

/-- Read a TSV (tab-separated) file. -/
def readTsv (path : System.FilePath) : IO DataFrame :=
  readCsv path { delimiter := '\t' }

end DataFrame
