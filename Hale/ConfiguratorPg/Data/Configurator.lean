/-
  Hale.ConfiguratorPg.Data.Configurator — Configuration loading and querying

  Provides functions to load, parse, and query configuration files in a
  simple key = value format with support for dotted keys, comments, quoted
  strings, numbers, and booleans.

  Mirrors Haskell's `Data.Configurator` from `configurator-pg`:
  https://hackage.haskell.org/package/configurator-pg

  ## Config File Format
  ```
  # Comment
  db-uri = "postgres://..."
  server-port = 3000
  jwt-secret = "secret"
  debug = true
  ```

  ## Key Functions
  - `empty` — empty configuration
  - `lookup` — look up a key
  - `require` — look up a key or error
  - `load` — load a config file from disk
  - `parseConfig` — pure parser for config file content

  $$\text{load} : \text{String} \to \text{IO Config}$$
  $$\text{parseConfig} : \text{String} \to \text{Except String Config}$$
-/
import Hale.ConfiguratorPg.Data.Configurator.Types

namespace Data.Configurator

/-- The empty configuration.
    $$\text{empty} : \text{Config}$$ -/
def empty : Config :=
  ∅

/-- Look up a key in the configuration.
    $$\text{lookup} : \text{String} \to \text{Config} \to \text{Option Value}$$ -/
def lookup (key : String) (config : Config) : Option Value :=
  config.get? key

/-- Look up a key with a default fallback.
    $$\text{lookupDefault} : \text{Value} \to \text{String} \to \text{Config} \to \text{Value}$$ -/
def lookupDefault (default_ : Value) (key : String) (config : Config) : Value :=
  (lookup key config).getD default_

/-- Look up a key, returning an error if not found.
    $$\text{require} : \text{String} \to \text{Config} \to \text{Except String Value}$$ -/
def require (key : String) (config : Config) : Except String Value :=
  match lookup key config with
  | some v => .ok v
  | none => .error s!"Required configuration key not found: {key}"

-- ============================================================
-- Parsing
-- ============================================================

/-- Trim leading and trailing ASCII whitespace. -/
private def trim (s : String) : String :=
  s.trimAscii.toString

/-- Check if a character is whitespace. -/
private def isSpace (c : Char) : Bool :=
  c == ' ' || c == '\t' || c == '\r'

/-- Parse a quoted string value, handling the content between quotes.
    Returns the parsed string and the remaining input after the closing quote. -/
private def parseQuotedString (input : String) (pos : Nat) : Except String (String × Nat) := Id.run do
  let chars := input.toList.toArray
  let mut result : List Char := []
  let mut i := pos
  while h : i < chars.size do
    let c := chars[i]
    if c == '"' then
      return .ok (String.ofList result.reverse, i + 1)
    else if c == '\\' && i + 1 < chars.size then
      let next := chars[i + 1]!
      let escaped := match next with
        | 'n' => '\n'
        | 't' => '\t'
        | 'r' => '\r'
        | '\\' => '\\'
        | '"' => '"'
        | other => other
      result := escaped :: result
      i := i + 2
    else
      result := c :: result
      i := i + 1
  return .error "Unterminated string literal"

/-- Parse a value from a string representation.
    Handles: quoted strings, numbers (Int and Float), booleans (true/false).
    $$\text{parseValue} : \text{String} \to \text{Except String Value}$$ -/
private def parseValue (s : String) : Except String Value := Id.run do
  let s' := trim s
  if s'.isEmpty then
    return .error "Empty value"
  -- Quoted string
  if s'.front == '"' then
    match parseQuotedString s' 1 with
    | .ok (str, _) => return .ok (.string str)
    | .error e => return .error e
  -- Boolean
  else if s'.toLower == "true" then return .ok (.bool true)
  else if s'.toLower == "false" then return .ok (.bool false)
  -- Number: try integer first, then float
  else
    -- Try integer
    match s'.toInt? with
    | some i => return .ok (.number (Float.ofInt i))
    | none =>
      -- Try float with decimal point
      match s'.splitOn "." with
      | [intPart, fracPart] =>
        match intPart.toInt?, fracPart.toNat? with
        | some i, some f =>
          let fracLen := fracPart.length
          let fracVal := (Float.ofNat f) / (Float.ofNat (10 ^ fracLen))
          let result := if i < 0 then Float.ofInt i - fracVal
                        else Float.ofInt i + fracVal
          return .ok (.number result)
        | _, _ => return .error s!"Cannot parse value: {s'}"
      | _ => return .error s!"Cannot parse value: {s'}"

/-- Parse a configuration file content into a `Config`.
    $$\text{parseConfig} : \text{String} \to \text{Except String Config}$$

    Parse rules:
    - Lines starting with `#` are comments (after trimming)
    - Empty lines are ignored
    - `key = value` format
    - Values can be: quoted strings, numbers, true/false
    - Dotted keys: `a.b.c = value` creates a flat lookup under key "a.b.c" -/
def parseConfig (content : String) : Except String Config := Id.run do
  let lines := content.splitOn "\n"
  let mut config : Config := empty
  let mut lineNum : Nat := 0
  for line in lines do
    lineNum := lineNum + 1
    let trimmed := trim line
    -- Skip empty lines and comments
    if trimmed.isEmpty || trimmed.startsWith "#" then
      continue
    -- Parse key = value
    match trimmed.splitOn "=" with
    | [] => return .error s!"Line {lineNum}: empty line after split"
    | [_] => return .error s!"Line {lineNum}: missing '=' in '{trimmed}'"
    | key :: valueParts =>
      let keyStr := trim key
      if keyStr.isEmpty then
        return .error s!"Line {lineNum}: empty key"
      else
        let valueStr := trim ("=".intercalate valueParts)
        match parseValue valueStr with
        | .ok v =>
          config := config.insert keyStr v
        | .error e =>
          return .error s!"Line {lineNum}: {e}"
  return .ok config

/-- Load a configuration file from disk.
    $$\text{load} : \text{String} \to \text{IO Config}$$ -/
def load (path : String) : IO Config := do
  let content ← IO.FS.readFile path
  match parseConfig content with
  | .ok config => return config
  | .error e => throw (IO.userError s!"Failed to parse config file '{path}': {e}")

end Data.Configurator
