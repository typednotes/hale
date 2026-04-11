/-
  Hale.ConfiguratorPg.Data.Configurator.Types — Configuration value types

  Core types for the configurator-pg port. Provides a typed representation
  of configuration values and a configuration map.

  Mirrors Haskell's `Data.Configurator.Types` from `configurator-pg`:
  https://hackage.haskell.org/package/configurator-pg

  ## Key Types
  - `Value` — a configuration value (string, number, bool, or list)
  - `Config` — a map from dotted keys to values

  $$\text{Value} ::= \text{string}\ s \mid \text{number}\ n \mid \text{bool}\ b \mid \text{list}\ vs$$
  $$\text{Config} := \text{HashMap String Value}$$
-/
import Std.Data.HashMap

namespace Data.Configurator

/-- A typed configuration value.
    $$\text{Value} ::= \text{string}\ s \mid \text{number}\ n \mid \text{bool}\ b \mid \text{list}\ vs$$ -/
inductive Value where
  /-- A string configuration value. -/
  | string (s : String)
  /-- A numeric configuration value. -/
  | number (n : Float)
  /-- A boolean configuration value. -/
  | bool (b : Bool)
  /-- A list of configuration values. -/
  | list (vs : List Value)
  deriving BEq, Repr

/-- Render a `Value` as a human-readable string. -/
partial def Value.toString : Value → String
  | .string s => s!"\"{s}\""
  | .number n => ToString.toString n
  | .bool b => ToString.toString b
  | .list vs => s!"[{", ".intercalate (vs.map Value.toString)}]"

instance : ToString Value where
  toString := Value.toString

/-- A configuration is a map from dotted keys to values.
    $$\text{Config} := \text{HashMap String Value}$$ -/
abbrev Config := Std.HashMap String Value

instance : ToString Config where
  toString (c : Config) := Id.run do
    let mut parts : List String := []
    for (k, v) in c.toList do
      parts := parts ++ [s!"{k} = {v}"]
    return "\n".intercalate parts

end Data.Configurator
