/-
  LeanStd.Base.Void — Wraps `Empty` with a usable API

  Provides vacuous instances and `absurd` for the uninhabited type.
-/

namespace Data

/-- The void type $\bot$ — uninhabited. Wraps Lean's `Empty`.

There exist no values of type $\text{Void}$, so any function
$\text{Void} \to \alpha$ is vacuously total. -/
abbrev Void := Empty

namespace Void

/-- Eliminate from $\bot$ to any type: given $v : \bot$, produce any $\alpha$.

$$\text{absurd} : \bot \to \alpha$$

This is the *ex falso quodlibet* principle. -/
def absurd {α : Sort u} (v : Void) : α := Empty.elim v

/-- `BEq` instance for $\bot$. Vacuously satisfied since no two values exist to compare. -/
instance : BEq Void where
  beq v _ := Void.absurd v

/-- `Ord` instance for $\bot$. Vacuously satisfied since no values exist to order. -/
instance : Ord Void where
  compare v _ := Void.absurd v

/-- `ToString` instance for $\bot$. Vacuously satisfied — no value can be stringified. -/
instance : ToString Void where
  toString v := Void.absurd v

/-- `Repr` instance for $\bot$. Vacuously satisfied. -/
instance : Repr Void where
  reprPrec v _ := Void.absurd v

/-- `Hashable` instance for $\bot$. Vacuously satisfied. -/
instance : Hashable Void where
  hash v := Void.absurd v

/-- The function space $\bot \to \alpha$ is inhabited, witnessed by `absurd`.

Since $|\bot| = 0$, there is exactly one function $\bot \to \alpha$ for any $\alpha$. -/
instance : Inhabited (Void → α) where
  default := Void.absurd

/-- Any function from $\bot$ is vacuously equal to `absurd`:

$$\forall\, f : \bot \to \alpha,\; f = \text{absurd}$$

This follows because the function space $\bot \to \alpha$ is a singleton. -/
theorem eq_absurd (f : Void → α) : f = Void.absurd := by
  funext v; exact Empty.elim v

end Void
end Data
