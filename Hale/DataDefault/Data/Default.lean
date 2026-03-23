/-
  Hale.DataDefault.Data.Default — Default typeclass

  Provides sensible defaults for types, distinct from `Inhabited` which
  merely guarantees existence. `Default` values should be the most
  commonly useful starting point.

  Mirrors Haskell's `Data.Default`.
-/
namespace Data

/-- A class for types with a sensible default value.
    Unlike `Inhabited`, `Default` carries the semantic meaning of
    "the most commonly useful starting point".
    $$\text{Default}(\alpha) \Rightarrow \alpha$$ -/
class Default (α : Type) where
  /-- The default value. -/
  default : α

instance : Default Bool where default := false
instance : Default Nat where default := 0
instance : Default Int where default := 0
instance : Default String where default := ""
instance : Default (List α) where default := []
instance : Default (Array α) where default := #[]
instance : Default (Option α) where default := none
instance [Default α] [Default β] : Default (α × β) where default := (Default.default, Default.default)
instance : Default Unit where default := ()

end Data
