/-
  LeanStd.Base.Function — Missing combinators

  Provides `on`, `applyTo` (flip apply / Haskell's `&`), and re-exports `flip`.
-/

namespace Data.Function

/-- The `on` combinator lifts a binary function through a unary projection:

$$(\texttt{on}\; f\; g)\; x\; y \;=\; f\,(g\,x)\,(g\,y)$$

Commonly used to compare or combine values by a derived key,
e.g., `on compare String.length` compares strings by length. -/
@[inline] def on (f : β → β → γ) (g : α → β) (x y : α) : γ := f (g x) (g y)

/-- Flip of function application (Haskell's `(&)` operator):

$$\texttt{applyTo}\; x\; f \;=\; f\,x$$

Useful for piping a value through a chain of transformations. -/
@[inline] def applyTo (x : α) (f : α → β) : β := f x

/-- The constant combinator $K$:

$$\texttt{const}\; a\; b \;=\; a$$

Ignores its second argument and always returns the first. In combinatory
logic this is the $K$ combinator. -/
@[inline] def const (a : α) (_ : β) : α := a

-- Note: We don't define a general `fix` as Lean requires termination proofs.

/-- Flip the argument order of a binary function:

$$\texttt{flip}\; f\; b\; a \;=\; f\; a\; b$$

In combinatory logic this is the $C$ combinator. -/
@[inline] def flip (f : α → β → γ) (b : β) (a : α) : γ := f a b

-- Properties

/-- `on` unfolds to its definition:
$(\texttt{on}\; f\; g)\; x\; y = f\,(g\,x)\,(g\,y)$. -/
theorem on_apply (f : β → β → γ) (g : α → β) (x y : α) :
    on f g x y = f (g x) (g y) := rfl

/-- `applyTo` unfolds to function application: $\texttt{applyTo}\; x\; f = f\,x$. -/
theorem applyTo_apply (x : α) (f : α → β) :
    applyTo x f = f x := rfl

/-- `const` ignores its second argument: $\texttt{const}\; a\; b = a$. -/
theorem const_apply (a : α) (b : β) :
    const a b = a := rfl

/-- `flip` is an involution — flipping twice recovers the original function:

$$\texttt{flip}\,(\texttt{flip}\; f) = f$$ -/
theorem flip_flip (f : α → β → γ) :
    flip (flip f) = f := rfl

/-- `flip` swaps the arguments: $\texttt{flip}\; f\; b\; a = f\; a\; b$. -/
theorem flip_apply (f : α → β → γ) (a : α) (b : β) :
    flip f b a = f a b := rfl

end Data.Function
