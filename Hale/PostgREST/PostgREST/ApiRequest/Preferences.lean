/-
  Hale.PostgREST.PostgREST.ApiRequest.Preferences — HTTP `Prefer` header preferences

  Parses and represents the preferences that clients can send via the
  `Prefer` HTTP header to control PostgREST behavior: counting strategy,
  response representation, conflict resolution, transaction handling, etc.

  ## Haskell source
  - `PostgREST.ApiRequest.Preferences` (postgrest package)

  ## Design
  - Each preference dimension is a separate inductive with a `none_` variant
    for "not specified"
  - `Preferences` bundles all dimensions with `none_` defaults
  - `parsePreferences` processes a list of `Prefer` header values
    (one entry per header line, values may be comma-separated within a line)
-/

namespace PostgREST.ApiRequest.Preferences

-- ────────────────────────────────────────────────────────────────────
-- Preference enumerations
-- ────────────────────────────────────────────────────────────────────

/-- Counting strategy preference.
    $$\text{PreferCount} \in \{\text{exact}, \text{planned}, \text{estimated},
      \text{none}\}$$ -/
inductive PreferCount where
  | exact
  | planned
  | estimated
  | none_
  deriving BEq, Repr, Inhabited

instance : ToString PreferCount where
  toString
    | .exact => "count=exact"
    | .planned => "count=planned"
    | .estimated => "count=estimated"
    | .none_ => ""

/-- Response return preference.
    $$\text{PreferReturn} \in \{\text{representation}, \text{minimal},
      \text{headersOnly}, \text{none}\}$$ -/
inductive PreferReturn where
  | representation
  | minimal
  | headersOnly
  | none_
  deriving BEq, Repr

instance : ToString PreferReturn where
  toString
    | .representation => "return=representation"
    | .minimal => "return=minimal"
    | .headersOnly => "return=headers-only"
    | .none_ => ""

/-- Conflict resolution preference for upsert.
    $$\text{PreferResolution} \in \{\text{mergeDuplicates},
      \text{ignoreDuplicates}, \text{none}\}$$ -/
inductive PreferResolution where
  | mergeDuplicates
  | ignoreDuplicates
  | none_
  deriving BEq, Repr

instance : ToString PreferResolution where
  toString
    | .mergeDuplicates => "resolution=merge-duplicates"
    | .ignoreDuplicates => "resolution=ignore-duplicates"
    | .none_ => ""

/-- Transaction handling preference.
    $$\text{PreferTransaction} \in \{\text{commit}, \text{rollback},
      \text{none}\}$$ -/
inductive PreferTransaction where
  | commit
  | rollback
  | none_
  deriving BEq, Repr

instance : ToString PreferTransaction where
  toString
    | .commit => "tx=commit"
    | .rollback => "tx=rollback"
    | .none_ => ""

/-- Missing column handling preference.
    $$\text{PreferMissing} \in \{\text{default}, \text{none}\}$$ -/
inductive PreferMissing where
  | default_
  | none_
  deriving BEq, Repr

instance : ToString PreferMissing where
  toString
    | .default_ => "missing=default"
    | .none_ => ""

/-- Error handling strictness preference.
    $$\text{PreferHandling} \in \{\text{strict}, \text{lenient}, \text{none}\}$$ -/
inductive PreferHandling where
  | strict
  | lenient
  | none_
  deriving BEq, Repr

instance : ToString PreferHandling where
  toString
    | .strict => "handling=strict"
    | .lenient => "handling=lenient"
    | .none_ => ""

-- ────────────────────────────────────────────────────────────────────
-- Bundled preferences
-- ────────────────────────────────────────────────────────────────────

/-- All preferences from the `Prefer` header, bundled together.
    $$\text{Preferences} = \langle \text{count}, \text{return}, \text{resolution},
      \text{transaction}, \text{missing}, \text{handling},
      \text{maxAffected}? \rangle$$ -/
structure Preferences where
  preferCount : PreferCount := .none_
  preferReturn : PreferReturn := .none_
  preferResolution : PreferResolution := .none_
  preferTransaction : PreferTransaction := .none_
  preferMissing : PreferMissing := .none_
  preferHandling : PreferHandling := .none_
  preferMaxAffected : Option Nat := none
  deriving Repr

instance : Inhabited Preferences where
  default := {
    preferCount := .none_
    preferReturn := .none_
    preferResolution := .none_
    preferTransaction := .none_
    preferMissing := .none_
    preferHandling := .none_
    preferMaxAffected := none
  }

instance : BEq Preferences where
  beq a b :=
    a.preferCount == b.preferCount &&
    a.preferReturn == b.preferReturn &&
    a.preferResolution == b.preferResolution &&
    a.preferTransaction == b.preferTransaction &&
    a.preferMissing == b.preferMissing &&
    a.preferHandling == b.preferHandling &&
    a.preferMaxAffected == b.preferMaxAffected

-- ────────────────────────────────────────────────────────────────────
-- Parsing
-- ────────────────────────────────────────────────────────────────────

/-- Parse a single preference token (trimmed, lowercased key=value pair)
    and apply it to the accumulator.
    $$\text{applyToken} : \text{Preferences} \to \text{String} \to \text{Preferences}$$ -/
private def applyToken (prefs : Preferences) (token : String) : Preferences :=
  let t := token.trimAscii
  if t == "count=exact" then { prefs with preferCount := .exact }
  else if t == "count=planned" then { prefs with preferCount := .planned }
  else if t == "count=estimated" then { prefs with preferCount := .estimated }
  else if t == "return=representation" then { prefs with preferReturn := .representation }
  else if t == "return=minimal" then { prefs with preferReturn := .minimal }
  else if t == "return=headers-only" then { prefs with preferReturn := .headersOnly }
  else if t == "resolution=merge-duplicates" then { prefs with preferResolution := .mergeDuplicates }
  else if t == "resolution=ignore-duplicates" then { prefs with preferResolution := .ignoreDuplicates }
  else if t == "tx=commit" then { prefs with preferTransaction := .commit }
  else if t == "tx=rollback" then { prefs with preferTransaction := .rollback }
  else if t == "missing=default" then { prefs with preferMissing := .default_ }
  else if t == "handling=strict" then { prefs with preferHandling := .strict }
  else if t == "handling=lenient" then { prefs with preferHandling := .lenient }
  else if t.startsWith "max-affected=" then
    let numStr := t.drop "max-affected=".length
    match numStr.trimAscii.toNat? with
    | some n => { prefs with preferMaxAffected := some n }
    | none => prefs
  else prefs

/-- Split a single `Prefer` header value into individual tokens.
    Tokens are comma-separated or semicolon-separated.
    $$\text{tokenize} : \text{String} \to \text{List}\ \text{String}$$ -/
private def tokenize (headerValue : String) : List String :=
  let commaTokens := headerValue.splitOn ","
  commaTokens.flatMap (fun s => s.splitOn ";")

/-- Parse a list of `Prefer` header values into a `Preferences` structure.
    Each string in the input list represents one header line.
    Values within a line may be comma-separated or semicolon-separated.
    $$\text{parsePreferences} : \text{List}\ \text{String} \to \text{Preferences}$$ -/
def parsePreferences (headers : List String) : Preferences :=
  let allTokens := headers.flatMap tokenize
  allTokens.foldl applyToken default

end PostgREST.ApiRequest.Preferences
