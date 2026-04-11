/-
  Hale.PostgREST.PostgREST.Version — PostgREST version constant

  ## Haskell source
  - `PostgREST.Version` (postgrest package)
-/

namespace PostgREST.Version

/-- The version of this PostgREST port. -/
def version : String := "12.2.0-hale"

/-- The version string for display. -/
def prettyVersion : String := s!"PostgREST {version} (Hale/Lean 4 port)"

end PostgREST.Version
