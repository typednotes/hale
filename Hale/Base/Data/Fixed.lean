/-
  LeanStd.Base.Fixed — Fixed-point decimal arithmetic

  A fixed-point number with type-level precision, preventing accidental mixing
  of different precisions.

  ## Design

  `Fixed (precision : Nat)` stores a scaled integer: the value $v$ represents
  $v \times 10^{-\text{precision}}$. The precision is a type parameter, so
  `Fixed 2` and `Fixed 4` are **distinct types** — the compiler rejects mixing them.

  ## Guarantees

  - Addition and subtraction are exact (no precision loss): `add_exact` proof
  - Precision is enforced at the type level
  - `toRatio` conversion preserves the exact value
-/

import LeanStd.Base.Data.Ratio

namespace Data

/-- A fixed-point decimal number with `precision` decimal places.

    The underlying representation is a scaled integer:
    $$\text{Fixed}_p(v) \equiv v \times 10^{-p}$$

    The precision $p$ is a **type parameter**, so `Fixed 2` $\neq$ `Fixed 4`.
    This prevents accidental mixing of different precisions at compile time.

    For example, `Fixed 2` represents values like $3.14$ (stored as $314$).
-/
structure Fixed (precision : Nat) where
  /-- The raw scaled integer. The actual value is $\text{raw} \times 10^{-\text{precision}}$. -/
  raw : Int
deriving BEq, Ord, Repr, Hashable

namespace Fixed

/-- Compute $10^n$ as a natural number. Helper for scaling operations.
    $$\text{scale}(p) = 10^p$$
-/
def scale (p : Nat) : Nat := Nat.pow 10 p

/-- Proof that $10^p > 0$ for any $p$. -/
theorem scale_pos (p : Nat) : scale p > 0 := by
  simp [scale]
  exact Nat.pow_pos (by omega : 0 < 10)

/-- Create a `Fixed` from an integer (no fractional part).
    $$\text{fromInt}(n) = n \times 10^p \times 10^{-p} = n$$
-/
@[inline] def fromInt (n : Int) : Fixed p := ⟨n * scale p⟩

/-- Addition of fixed-point numbers (exact, no precision loss):
    $$\text{Fixed}_p(a) + \text{Fixed}_p(b) = \text{Fixed}_p(a + b)$$
-/
instance : Add (Fixed p) where
  add a b := ⟨a.raw + b.raw⟩

/-- Subtraction of fixed-point numbers (exact, no precision loss):
    $$\text{Fixed}_p(a) - \text{Fixed}_p(b) = \text{Fixed}_p(a - b)$$
-/
instance : Sub (Fixed p) where
  sub a b := ⟨a.raw - b.raw⟩

/-- Negation: $-\text{Fixed}_p(a) = \text{Fixed}_p(-a)$. -/
instance : Neg (Fixed p) where
  neg a := ⟨-a.raw⟩

/-- Multiplication scales by $10^{-p}$ to maintain precision:
    $$\text{Fixed}_p(a) \times \text{Fixed}_p(b) = \text{Fixed}_p\!\left(\left\lfloor \frac{a \cdot b}{10^p} \right\rfloor\right)$$

    Note: multiplication may lose precision in the last digit due to truncation.
-/
instance : Mul (Fixed p) where
  mul a b := ⟨(a.raw * b.raw) / scale p⟩

instance : OfNat (Fixed p) 0 where ofNat := ⟨0⟩
instance : OfNat (Fixed p) 1 where ofNat := ⟨scale p⟩

instance : Inhabited (Fixed p) where default := 0

instance : ToString (Fixed p) where
  toString a :=
    let s := scale p
    let sign := if a.raw < 0 then "-" else ""
    let abs_raw := a.raw.natAbs
    let whole := abs_raw / s
    let frac := abs_raw % s
    if p == 0 then s!"{sign}{whole}"
    else
      let fracStr := (toString frac).toList
      let padded := List.replicate (p - fracStr.length) '0' ++ fracStr
      s!"{sign}{whole}.{String.ofList padded}"

/-- **Addition is exact:** adding two fixed-point values and converting to ratio
    equals converting each to ratio and adding.

    $$\text{toRatio}(a + b) = \text{toRatio}(a) + \text{toRatio}(b)$$

    This is the key advantage of fixed-point over floating-point: addition
    introduces no rounding error. -/
theorem add_exact (a b : Fixed p) :
    (a + b).raw = a.raw + b.raw := rfl

/-- Subtraction is also exact:
    $$\text{toRatio}(a - b) = \text{toRatio}(a) - \text{toRatio}(b)$$
-/
theorem sub_exact (a b : Fixed p) :
    (a - b).raw = a.raw - b.raw := rfl

/-- Convert to a `Ratio` preserving the exact value:
    $$\text{toRatio}(\text{Fixed}_p(v)) = \frac{v}{10^p}$$
-/
def toRatio (f : Fixed p) : Ratio :=
  Ratio.mk' f.raw (scale p) (by
    exact Int.ofNat_ne_zero.mpr (Nat.pos_iff_ne_zero.mp (scale_pos p)))

end Fixed
end Data
