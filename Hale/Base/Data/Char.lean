/-
  Hale.Base.Data.Char — Character classification and conversion

  Supplements Lean's built-in `Char` with Haskell's `Data.Char` predicates
  and conversion functions. Lean already provides `isAlpha`, `isDigit`,
  `isLower`, `isUpper`, `isWhitespace`, `toLower`, `toUpper`, `toNat`,
  `Char.ofNat`.

  We add missing predicates (`isAlphaNum`, `isAscii`, `isControl`, etc.)
  and Haskell-named aliases (`ord`, `chr`, `digitToInt`, `intToDigit`).
-/

namespace Data

namespace Char'

-- ── Predicates ──────────────────────────────────

/-- Alias for `Char.isWhitespace`.
    $$\text{isSpace}(c) = \text{isWhitespace}(c)$$ -/
@[inline] def isSpace (c : Char) : Bool := c.isWhitespace

/-- Test if a character is alphanumeric (letter or digit).
    $$\text{isAlphaNum}(c) = \text{isAlpha}(c) \lor \text{isDigit}(c)$$ -/
@[inline] def isAlphaNum (c : Char) : Bool := c.isAlpha || c.isDigit

/-- Test if a character is in the ASCII range $[0, 128)$.
    $$\text{isAscii}(c) \iff \text{ord}(c) < 128$$ -/
@[inline] def isAscii (c : Char) : Bool := c.toNat < 128

/-- Test if a character is in the Latin-1 range $[0, 256)$.
    $$\text{isLatin1}(c) \iff \text{ord}(c) < 256$$ -/
@[inline] def isLatin1 (c : Char) : Bool := c.toNat < 256

/-- Test if a character is a control character (codes 0--31 or 127).
    $$\text{isControl}(c) \iff \text{ord}(c) < 32 \lor \text{ord}(c) = 127$$ -/
@[inline] def isControl (c : Char) : Bool := c.toNat < 32 || c.toNat == 127

/-- Test if a character is printable (ASCII, non-control).
    $$\text{isPrint}(c) \iff \lnot\,\text{isControl}(c) \land \text{ord}(c) < 128$$
    Note: this is a simplified ASCII-only version. -/
@[inline] def isPrint (c : Char) : Bool := !isControl c && c.toNat < 128

/-- Test if a character is a hexadecimal digit: `0`--`9`, `a`--`f`, `A`--`F`.
    $$\text{isHexDigit}(c) \iff c \in [0\text{-}9] \cup [a\text{-}f] \cup [A\text{-}F]$$ -/
@[inline] def isHexDigit (c : Char) : Bool :=
  c.isDigit || (c.toNat >= 65 && c.toNat <= 70) || (c.toNat >= 97 && c.toNat <= 102)

/-- Test if a character is an octal digit: `0`--`7`.
    $$\text{isOctDigit}(c) \iff \text{ord}(c) \in [48, 55]$$ -/
@[inline] def isOctDigit (c : Char) : Bool := c.toNat >= 48 && c.toNat <= 55

/-- Test if a character is an ASCII uppercase letter: `A`--`Z`.
    $$\text{isAsciiUpper}(c) \iff \text{ord}(c) \in [65, 90]$$ -/
@[inline] def isAsciiUpper (c : Char) : Bool := c.toNat >= 65 && c.toNat <= 90

/-- Test if a character is an ASCII lowercase letter: `a`--`z`.
    $$\text{isAsciiLower}(c) \iff \text{ord}(c) \in [97, 122]$$ -/
@[inline] def isAsciiLower (c : Char) : Bool := c.toNat >= 97 && c.toNat <= 122

/-- Test if a character is ASCII punctuation.
    $$\text{isPunctuation}(c) \iff c \in [\texttt{!}-\texttt{/}] \cup [\texttt{:}-\texttt{@}] \cup [\texttt{[}-\texttt{`}] \cup [\texttt{\{}-\texttt{~}]$$
    Covers ASCII punctuation ranges: 33--47, 58--64, 91--96, 123--126. -/
@[inline] def isPunctuation (c : Char) : Bool :=
  let n := c.toNat
  (n >= 33 && n <= 47) || (n >= 58 && n <= 64) || (n >= 91 && n <= 96) || (n >= 123 && n <= 126)

-- ── Conversion ──────────────────────────────────

/-- Character to its Unicode code point.
    $$\text{ord}(c) = \text{toNat}(c)$$ -/
@[inline] def ord (c : Char) : Nat := c.toNat

/-- Code point to character.
    $$\text{chr}(n) = \text{Char.ofNat}(n)$$ -/
@[inline] def chr (n : Nat) : Char := Char.ofNat n

/-- Convert a hex digit character to its numeric value, bounded below 16.
    $$\text{digitToInt}(c) = \begin{cases}
      n - 48  & c \in [\texttt{0}\text{-}\texttt{9}] \\
      n - 55  & c \in [\texttt{A}\text{-}\texttt{F}] \\
      n - 87  & c \in [\texttt{a}\text{-}\texttt{f}] \\
      \text{none} & \text{otherwise}
    \end{cases}$$
    Returns `Option {n : Nat // n < 16}` — the proof that the digit is in $[0, 15]$
    is carried in the subtype and erased at runtime. -/
def digitToInt (c : Char) : Option {n : Nat // n < 16} :=
  let n := c.toNat
  if h1 : n >= 48 && n <= 57 then
    have h1a : n ≥ 48 := by simp [Bool.and_eq_true] at h1; exact h1.1
    have h1b : n ≤ 57 := by simp [Bool.and_eq_true] at h1; exact h1.2
    some ⟨n - 48, by omega⟩
  else if h2 : n >= 65 && n <= 70 then
    have h2a : n ≥ 65 := by simp [Bool.and_eq_true] at h2; exact h2.1
    have h2b : n ≤ 70 := by simp [Bool.and_eq_true] at h2; exact h2.2
    some ⟨n - 55, by omega⟩
  else if h3 : n >= 97 && n <= 102 then
    have h3a : n ≥ 97 := by simp [Bool.and_eq_true] at h3; exact h3.1
    have h3b : n ≤ 102 := by simp [Bool.and_eq_true] at h3; exact h3.2
    some ⟨n - 87, by omega⟩
  else none

/-- Convert a number in $[0, 15]$ to a hex digit character. Total — no `Option` needed.
    $$\text{intToDigit}(n) = \begin{cases}
      \texttt{0} + n & n \in [0, 9] \\
      \texttt{a} + (n - 10) & n \in [10, 15]
    \end{cases}$$
    The proof obligation `n < 16` is required at the call site and erased at runtime. -/
def intToDigit (n : Nat) (_h : n < 16 := by omega) : Char :=
  if n <= 9 then Char.ofNat (48 + n)
  else Char.ofNat (87 + n)

-- ── Proofs ──────────────────────────────────────

/-- `isAlphaNum` unfolds to its definition. -/
theorem isAlphaNum_iff (c : Char) : isAlphaNum c = (c.isAlpha || c.isDigit) := rfl

/-- `isSpace` is an alias for `isWhitespace`. -/
theorem isSpace_eq_isWhitespace (c : Char) : isSpace c = c.isWhitespace := rfl

/-- `ord` is an alias for `toNat`. -/
theorem ord_eq_toNat (c : Char) : ord c = c.toNat := rfl

/-- `isAscii c = true` implies `c.toNat < 128`. -/
theorem isAscii_bound (c : Char) (h : isAscii c = true) : c.toNat < 128 := by
  simp [isAscii] at h
  exact h

/-- Roundtrip: `digitToInt (intToDigit n) = some ⟨n, h⟩` for all `n < 16`. -/
theorem digitToInt_intToDigit (n : Nat) (h : n < 16) :
    digitToInt (intToDigit n h) = some ⟨n, h⟩ := by
  have : n = 0 ∨ n = 1 ∨ n = 2 ∨ n = 3 ∨ n = 4 ∨ n = 5 ∨ n = 6 ∨ n = 7 ∨
         n = 8 ∨ n = 9 ∨ n = 10 ∨ n = 11 ∨ n = 12 ∨ n = 13 ∨ n = 14 ∨ n = 15 := by omega
  rcases this with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl |
    rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-- `isAscii` is true iff the code point is below 128. -/
theorem isAscii_iff (c : Char) : isAscii c = true ↔ c.toNat < 128 := by
  simp [isAscii]

/-- Every decimal digit is also a hex digit. -/
theorem isHexDigit_of_digit (c : Char) (h : c.isDigit = true) : isHexDigit c = true := by
  simp [isHexDigit, h]

/-- `intToDigit` always produces an ASCII character. -/
theorem intToDigit_isAscii (n : Nat) (h : n < 16) : isAscii (intToDigit n h) = true := by
  have : n = 0 ∨ n = 1 ∨ n = 2 ∨ n = 3 ∨ n = 4 ∨ n = 5 ∨ n = 6 ∨ n = 7 ∨
         n = 8 ∨ n = 9 ∨ n = 10 ∨ n = 11 ∨ n = 12 ∨ n = 13 ∨ n = 14 ∨ n = 15 := by omega
  rcases this with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl |
    rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

end Char'
end Data
