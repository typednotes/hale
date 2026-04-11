/-
  Hale.OptParse.Options.Applicative.Types — Core types for option parsing

  Mirrors Haskell's `Options.Applicative.Types` from the `optparse-applicative`
  package. Provides the foundational types for building composable command-line
  parsers: readers, modifiers, option specifications, and parser combinators.

  ## Design Note
  Haskell's `optparse-applicative` uses a free applicative functor GADT.
  Lean 4's strict positivity checker rejects `ap : Parser (β → α) → Parser β`
  as an inductive constructor. We use a **functional** representation instead:
  a `Parser α` is a function from argument list to result, composed via
  combinators. Option metadata is tracked in a separate `OptDescr` list
  for help text generation.

  ## Key Types
  - `ReadM α` — a reader that parses a `String` into a typed result
  - `Mod` — option modifiers (long name, short name, help text, etc.)
  - `Parser α` — a composable command-line parser (functional)
  - `ParserInfo α` — parser with metadata for help generation

  $$\text{ReadM}\ \alpha := \text{String} \to \text{Except String}\ \alpha$$
  $$\text{Parser}\ \alpha := \text{List String} \to \text{Except String}\ (\alpha \times \text{List String})$$

  Mirrors Haskell's `optparse-applicative`:
  https://hackage.haskell.org/package/optparse-applicative
-/
namespace Options.Applicative

/-- A reader that can parse a string value into a typed result.
    $$\text{ReadM}\ \alpha := \text{String} \to \text{Except String}\ \alpha$$ -/
def ReadM (α : Type) := String → Except String α

instance : Inhabited (ReadM α) where
  default := fun _ => .error "no reader"

/-- Option visibility and characteristics.
    Combines long/short names, help text, metavar, and visibility. -/
structure Mod where
  /-- Long option name (e.g., "output" for --output). -/
  long : Option String := none
  /-- Short option character (e.g., 'o' for -o). -/
  short : Option Char := none
  /-- Help text displayed in usage. -/
  help : Option String := none
  /-- Metavar displayed in usage (e.g., FILE in --output FILE). -/
  metavar : Option String := none
  /-- Whether this option is hidden from help. -/
  hidden : Bool := false
  /-- Whether to show the default value in help text. -/
  showDefault : Bool := false
  deriving Inhabited, Repr

/-- Combine two `Mod` values, with the right-hand side taking precedence
    for fields that are set. -/
instance : Append Mod where
  append a b := {
    long := b.long <|> a.long
    short := b.short <|> a.short
    help := b.help <|> a.help
    metavar := b.metavar <|> a.metavar
    hidden := a.hidden || b.hidden
    showDefault := a.showDefault || b.showDefault
  }

/-- Modifier configuration for `ParserInfo`.
    $$\text{InfoMod} := \text{ParserInfo-level modifiers}$$ -/
structure InfoMod where
  /-- Program description. -/
  description : Option String := none
  /-- Header text shown before usage. -/
  header : Option String := none
  /-- Footer text shown after options. -/
  footer : Option String := none
  /-- Whether to show full description in help. -/
  fullDesc : Bool := true
  /-- Exit code on parse failure. -/
  failureCode : Nat := 1
  deriving Inhabited, Repr

-- ============================================================
-- Option descriptions (for help text generation)
-- ============================================================

/-- Description of a single option, used for generating help text.
    Separated from the parsing logic so that the parser can be a
    plain function type. -/
inductive OptDescr where
  /-- A named option (--long / -s). -/
  | optionDescr (mods : Mod)
  /-- A flag (--long / -s, no value). -/
  | flagDescr (mods : Mod)
  /-- A positional argument. -/
  | argDescr (mods : Mod)
  /-- A subcommand group. -/
  | cmdDescr (commands : List (String × Option String))
  deriving Inhabited, Repr

-- ============================================================
-- Parser (functional representation)
-- ============================================================

/-- A composable command-line parser. Internally a function from an argument
    list to either an error or a pair of (parsed value, remaining args).
    Option descriptions are tracked separately for help generation.

    $$\text{Parser}\ \alpha := \{ \text{run} : \text{List String} \to \text{Except String}\ (\alpha \times \text{List String}), \text{descrs} : \text{List OptDescr} \}$$ -/
structure Parser (α : Type) where
  /-- Run the parser on an argument list, returning the result and remaining args. -/
  run : List String → Except String (α × List String)
  /-- Option descriptions for help text generation. -/
  descrs : List OptDescr := []

/-- Parser with metadata for help text generation.
    $$\text{ParserInfo}\ \alpha := (\text{Parser}\ \alpha, \text{description}, \text{header}, \text{footer}, \ldots)$$ -/
structure ParserInfo (α : Type) where
  /-- The underlying parser. -/
  parser : Parser α
  /-- Program description. -/
  description : Option String := none
  /-- Header text shown before usage. -/
  header : Option String := none
  /-- Footer text shown after options. -/
  footer : Option String := none
  /-- Whether to show full description. -/
  fullDesc : Bool := true
  /-- Exit code on parse failure. -/
  failureCode : Nat := 1

end Options.Applicative
