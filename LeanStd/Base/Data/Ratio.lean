/-
  LeanStd.Base.Ratio — Exact rational arithmetic

  A rational number $\frac{p}{q}$ in canonical form: $q > 0$ and $\gcd(|p|, q) = 1$.

  ## Design

  - `den : Nat` (not `Int`) with `den_pos : den > 0` — sign lives solely in `num`
  - `coprime` ensures canonical form, making structural `BEq` correct
  - Smart constructor normalizes and proves invariants

  ## Guarantees

  - All arithmetic operations preserve canonical form
  - No division by zero: denominator is always positive
-/

namespace LeanStd

/-- A rational number $\frac{\text{num}}{\text{den}}$ in canonical form.

    **Invariants:**
    - $\text{den} > 0$ (denominator is a positive natural number)
    - $\gcd(|\text{num}|, \text{den}) = 1$ (fully reduced)

    The sign is carried solely by `num`; `den` is always positive.
    These invariants make structural equality correct:
    two `Ratio` values are equal iff they represent the same rational number.
-/
structure Ratio where
  /-- The numerator (carries the sign). -/
  num : Int
  /-- The denominator (always positive). -/
  den : Nat
  /-- Proof that the denominator is positive: $\text{den} > 0$. -/
  den_pos : den > 0
  /-- Proof of coprimality: $\gcd(|\text{num}|, \text{den}) = 1$. -/
  coprime : Nat.Coprime num.natAbs den
deriving Repr

namespace Ratio

-- Helper: 1 is coprime to itself
private theorem coprime_one : Nat.Coprime 0 1 := by decide

/-- The rational number $0 = \frac{0}{1}$. -/
def zero : Ratio := ⟨0, 1, Nat.one_pos, coprime_one⟩

/-- The rational number $1 = \frac{1}{1}$. -/
def one : Ratio := ⟨1, 1, Nat.one_pos, by decide⟩

instance : OfNat Ratio 0 where ofNat := zero
instance : OfNat Ratio 1 where ofNat := one

instance : Inhabited Ratio where default := zero

/-- Smart constructor: normalize $\frac{n}{d}$ to canonical form.

    Given integers $n$ and $d \neq 0$:
    1. Compute $g = \gcd(|n|, |d|)$
    2. Adjust sign so denominator is positive
    3. Divide both by $g$

    $$\text{mk'}(n, d) = \frac{n / g}{d / g} \quad \text{where } g = \gcd(|n|, |d|)$$
-/
def mk' (n : Int) (d : Int) (hd : d ≠ 0) : Ratio :=
  let sign : Int := if d > 0 then 1 else -1
  let n' := sign * n
  let d' := (sign * d).natAbs
  let g := Nat.gcd n'.natAbs d'
  have hd' : d' > 0 := by
    simp only [d']
    cases hsd : decide (d > 0) with
    | true =>
      simp [sign, if_pos (of_decide_eq_true hsd)]
      omega
    | false =>
      simp [sign, if_neg (of_decide_eq_false hsd)]
      omega
  have hg : g > 0 := Nat.pos_of_ne_zero (by
    intro h
    simp only [g, Nat.gcd_eq_zero_iff] at h
    omega)
  let num := n' / (g : Int)
  let den := d' / g
  have hden : den > 0 := Nat.div_pos (Nat.le_of_dvd hd' (Nat.gcd_dvd_right _ _)) hg
  have hcop : Nat.Coprime num.natAbs den := by
    simp only [num, den, g]
    have hdvd : (g : Int) ∣ n' :=
      Int.ofNat_dvd_left.mpr (Nat.gcd_dvd_left n'.natAbs d')
    have habs : Int.natAbs (n' / (g : Int)) = n'.natAbs / g :=
      Int.natAbs_ediv_of_dvd hdvd
    rw [habs]
    exact Nat.coprime_div_gcd_div_gcd hg
  ⟨num, den, hden, hcop⟩

/-- Create a ratio from an integer: $n \mapsto \frac{n}{1}$. -/
@[inline] def fromInt (n : Int) : Ratio :=
  ⟨n, 1, Nat.one_pos, Nat.coprime_one_right _⟩

/-- Create a ratio from a natural number: $n \mapsto \frac{n}{1}$. -/
@[inline] def fromNat (n : Nat) : Ratio := fromInt n

/-- Negation: $-\frac{p}{q} = \frac{-p}{q}$.
    Preserves coprimality since $\gcd(|-p|, q) = \gcd(|p|, q)$. -/
def neg (r : Ratio) : Ratio :=
  ⟨-r.num, r.den, r.den_pos, by simpa [Int.natAbs_neg] using r.coprime⟩

/-- Absolute value: $\left|\frac{p}{q}\right| = \frac{|p|}{q}$. -/
def abs (r : Ratio) : Ratio :=
  ⟨r.num.natAbs, r.den, r.den_pos, r.coprime⟩

/-- Addition of rationals:
    $$\frac{a}{b} + \frac{c}{d} = \frac{ad + bc}{bd}$$
    (normalized to canonical form). -/
def add (r s : Ratio) : Ratio :=
  mk' (r.num * s.den + s.num * r.den) (r.den * s.den) (by
    exact Int.ofNat_ne_zero.mpr (Nat.pos_iff_ne_zero.mp (Nat.mul_pos r.den_pos s.den_pos)))

/-- Subtraction: $\frac{a}{b} - \frac{c}{d} = \frac{a}{b} + \frac{-c}{d}$. -/
def sub (r s : Ratio) : Ratio := add r (neg s)

/-- Multiplication:
    $$\frac{a}{b} \times \frac{c}{d} = \frac{ac}{bd}$$
    (normalized to canonical form). -/
def mul (r s : Ratio) : Ratio :=
  mk' (r.num * s.num) (r.den * s.den) (by
    exact Int.ofNat_ne_zero.mpr (Nat.pos_iff_ne_zero.mp (Nat.mul_pos r.den_pos s.den_pos)))

/-- Reciprocal: $\frac{q}{p}$ for $p \neq 0$.
    Swaps numerator and denominator, adjusting sign. -/
def inv (r : Ratio) (h : r.num ≠ 0) : Ratio :=
  mk' (↑r.den) r.num h

/-- Division: $\frac{a}{b} \div \frac{c}{d} = \frac{a}{b} \times \frac{d}{c}$.
    Requires $c/d \neq 0$. -/
def div (r s : Ratio) (h : s.num ≠ 0) : Ratio :=
  mul r (inv s h)

/-- Comparison: $\frac{a}{b} \leq \frac{c}{d} \iff ad \leq bc$ (since $b, d > 0$). -/
instance : LE Ratio where
  le r s := r.num * s.den ≤ s.num * r.den

instance : LT Ratio where
  lt r s := r.num * s.den < s.num * r.den

instance : BEq Ratio where
  beq r s := r.num == s.num && r.den == s.den

instance : Ord Ratio where
  compare r s := compare (r.num * s.den) (s.num * r.den)

instance : Add Ratio where add := add
instance : Sub Ratio where sub := sub
instance : Mul Ratio where mul := mul
instance : Neg Ratio where neg := neg

instance : ToString Ratio where
  toString r :=
    if r.den == 1 then toString r.num
    else s!"{r.num}/{r.den}"

/-- Floor: the greatest integer $\leq r$.
    $$\lfloor r \rfloor = \lfloor \text{num} / \text{den} \rfloor$$
-/
def floor (r : Ratio) : Int := r.num / r.den

/-- Ceiling: the least integer $\geq r$.
    $$\lceil r \rceil = -\lfloor -r \rfloor$$
-/
def ceil (r : Ratio) : Int :=
  -((- r.num) / r.den)

/-- Round to the nearest integer (half rounds away from zero).
    $$\text{round}(r) = \lfloor r + 1/2 \rfloor$$
-/
def round (r : Ratio) : Int :=
  let doubled := 2 * r.num
  let shifted := doubled + (if r.num ≥ 0 then (r.den : Int) else -(r.den : Int))
  shifted / (2 * r.den)

end Ratio
end LeanStd
