/-
  LeanStd.Base.Newtype — Semigroup/Monoid newtype wrappers

  Provides `Dual`, `Endo`, `First`, `Last`, `Sum`, `Product`, `All`, `Any`.
  Each with `Append`/`BEq`/`Ord` instances + associativity/identity proofs.
-/

namespace LeanStd

-- ══════════════════════════════════════════════
-- Dual: reverses the semigroup operation
-- ══════════════════════════════════════════════

/-- `Dual α` reverses the `Append` (semigroup) operation:

$$\text{Dual}(a) \mathbin{++} \text{Dual}(b) = \text{Dual}(b \mathbin{++} a)$$

If $(S, \diamond)$ is a semigroup, then $(\text{Dual}\;S,\, \diamond^{\text{op}})$
is the **opposite semigroup** where $a \diamond^{\text{op}} b = b \diamond a$. -/
structure Dual (α : Type u) where
  getDual : α
deriving BEq, Ord, Repr, Hashable

/-- `ToString` instance for `Dual α`, displaying as `Dual(...)`. -/
instance [ToString α] : ToString (Dual α) where
  toString d := s!"Dual({d.getDual})"

/-- `Append` instance for `Dual α` — reverses the underlying operation:
$\text{Dual}(a) \mathbin{++} \text{Dual}(b) = \text{Dual}(b \mathbin{++} a)$. -/
instance [Append α] : Append (Dual α) where
  append a b := ⟨b.getDual ++ a.getDual⟩

/-- Associativity of the dual semigroup. Given associativity of $(++)$ on $\alpha$:

$$(\text{Dual}\;a \mathbin{++} \text{Dual}\;b) \mathbin{++} \text{Dual}\;c
  = \text{Dual}\;a \mathbin{++} (\text{Dual}\;b \mathbin{++} \text{Dual}\;c)$$ -/
theorem Dual.append_assoc [Append α] [h : Std.Associative (α := α) (· ++ ·)]
    (a b c : Dual α) : a ++ b ++ c = a ++ (b ++ c) := by
  simp [HAppend.hAppend, Append.append]
  exact (h.assoc c.getDual b.getDual a.getDual).symm

-- ══════════════════════════════════════════════
-- Endo: endomorphism monoid under composition
-- ══════════════════════════════════════════════

/-- `Endo α` wraps endomorphisms $\alpha \to \alpha$. Forms a monoid under function composition:

- **Operation:** $\text{Endo}(f) \mathbin{++} \text{Endo}(g) = \text{Endo}(f \circ g)$
- **Identity:** $\text{Endo}(\text{id})$

$$(\text{Endo}\;f \mathbin{++} \text{Endo}\;g)(x) = f(g(x))$$ -/
structure Endo (α : Type u) where
  appEndo : α → α

/-- `Append` instance for `Endo α` via function composition:
$\text{Endo}(f) \mathbin{++} \text{Endo}(g) = \text{Endo}(f \circ g)$. -/
instance : Append (Endo α) where
  append f g := ⟨f.appEndo ∘ g.appEndo⟩

/-- Associativity of endomorphism composition. Since $(f \circ g) \circ h = f \circ (g \circ h)$
holds definitionally, this is `rfl`. -/
theorem Endo.append_assoc (a b c : Endo α) :
    a ++ b ++ c = a ++ (b ++ c) := rfl

-- ══════════════════════════════════════════════
-- First / Last: keep first or last Some value
-- ══════════════════════════════════════════════

/-- `First α` keeps the **leftmost** `some` value under `Append`:

$$\text{First}(x) \mathbin{++} \text{First}(y) = \text{First}(x \mathbin{<|>} y)$$

- $\text{First}(\text{some}\;a) \mathbin{++} \_ = \text{First}(\text{some}\;a)$
- $\text{First}(\text{none}) \mathbin{++} y = y$

Identity element: $\text{First}(\text{none})$. -/
structure First (α : Type u) where
  getFirst : Option α
deriving BEq, Repr

/-- `ToString` instance for `First α`, displaying as `First(...)`. -/
instance [ToString α] : ToString (First α) where
  toString f := s!"First({f.getFirst})"

/-- `Append` instance for `First α` — keeps the leftmost `some`. -/
instance : Append (First α) where
  append a b := ⟨a.getFirst <|> b.getFirst⟩

/-- Associativity of `First`: $((a \mathbin{++} b) \mathbin{++} c) = (a \mathbin{++} (b \mathbin{++} c))$.

Follows from the associativity of `Option`'s `<|>` (left-biased choice). -/
theorem First.append_assoc (a b c : First α) :
    a ++ b ++ c = a ++ (b ++ c) := by
  simp [HAppend.hAppend, Append.append]
  cases a.getFirst <;> simp

/-- `Last α` keeps the **rightmost** `some` value under `Append`:

$$\text{Last}(x) \mathbin{++} \text{Last}(y) = \text{Last}(y \mathbin{<|>} x)$$

- $\_ \mathbin{++} \text{Last}(\text{some}\;b) = \text{Last}(\text{some}\;b)$
- $x \mathbin{++} \text{Last}(\text{none}) = x$

Identity element: $\text{Last}(\text{none})$. -/
structure Last (α : Type u) where
  getLast : Option α
deriving BEq, Repr

/-- `ToString` instance for `Last α`, displaying as `Last(...)`. -/
instance [ToString α] : ToString (Last α) where
  toString l := s!"Last({l.getLast})"

/-- `Append` instance for `Last α` — keeps the rightmost `some`. -/
instance : Append (Last α) where
  append a b := ⟨b.getLast <|> a.getLast⟩

/-- Associativity of `Last`: $((a \mathbin{++} b) \mathbin{++} c) = (a \mathbin{++} (b \mathbin{++} c))$.

Follows from the associativity of right-biased `<|>` on `Option`. -/
theorem Last.append_assoc (a b c : Last α) :
    a ++ b ++ c = a ++ (b ++ c) := by
  simp [HAppend.hAppend, Append.append]
  cases c.getLast <;> simp

-- ══════════════════════════════════════════════
-- Sum / Product: numeric monoids
-- ══════════════════════════════════════════════

/-- `Sum α` is a monoid wrapper under addition:

- **Operation:** $\text{Sum}(a) \mathbin{++} \text{Sum}(b) = \text{Sum}(a + b)$
- **Identity:** $\text{Sum}(0)$

$$\text{Sum}(a) \mathbin{++} \text{Sum}(b) = \text{Sum}(a + b)$$ -/
structure Sum (α : Type u) where
  getSum : α
deriving BEq, Ord, Repr, Hashable

/-- `ToString` instance for `Sum α`, displaying as `Sum(...)`. -/
instance [ToString α] : ToString (Sum α) where
  toString s := s!"Sum({s.getSum})"

/-- `Append` instance for `Sum α` — delegates to `Add`:
$\text{Sum}(a) \mathbin{++} \text{Sum}(b) = \text{Sum}(a + b)$. -/
instance [Add α] : Append (Sum α) where
  append a b := ⟨a.getSum + b.getSum⟩

/-- Associativity of `Sum`, given associativity of $(+)$ on $\alpha$:

$$(a + b) + c = a + (b + c) \;\implies\;
  \text{Sum}(a) \mathbin{++} \text{Sum}(b) \mathbin{++} \text{Sum}(c)
  = \text{Sum}(a) \mathbin{++} (\text{Sum}(b) \mathbin{++} \text{Sum}(c))$$ -/
theorem Sum.append_assoc [Add α] [h : Std.Associative (α := α) (· + ·)]
    (a b c : Sum α) : a ++ b ++ c = a ++ (b ++ c) := by
  simp [HAppend.hAppend, Append.append, Sum.mk.injEq]
  exact h.assoc a.getSum b.getSum c.getSum

/-- `Product α` is a monoid wrapper under multiplication:

- **Operation:** $\text{Product}(a) \mathbin{++} \text{Product}(b) = \text{Product}(a \times b)$
- **Identity:** $\text{Product}(1)$

$$\text{Product}(a) \mathbin{++} \text{Product}(b) = \text{Product}(a \times b)$$ -/
structure Product (α : Type u) where
  getProduct : α
deriving BEq, Ord, Repr, Hashable

/-- `ToString` instance for `Product α`, displaying as `Product(...)`. -/
instance [ToString α] : ToString (Product α) where
  toString p := s!"Product({p.getProduct})"

/-- `Append` instance for `Product α` — delegates to `Mul`:
$\text{Product}(a) \mathbin{++} \text{Product}(b) = \text{Product}(a \times b)$. -/
instance [Mul α] : Append (Product α) where
  append a b := ⟨a.getProduct * b.getProduct⟩

/-- Associativity of `Product`, given associativity of $(\times)$ on $\alpha$:

$$(a \times b) \times c = a \times (b \times c) \;\implies\;
  \text{Product}(a) \mathbin{++} \text{Product}(b) \mathbin{++} \text{Product}(c)
  = \text{Product}(a) \mathbin{++} (\text{Product}(b) \mathbin{++} \text{Product}(c))$$ -/
theorem Product.append_assoc [Mul α] [h : Std.Associative (α := α) (· * ·)]
    (a b c : Product α) : a ++ b ++ c = a ++ (b ++ c) := by
  simp [HAppend.hAppend, Append.append, Product.mk.injEq]
  exact h.assoc a.getProduct b.getProduct c.getProduct

-- ══════════════════════════════════════════════
-- All / Any: boolean monoids
-- ══════════════════════════════════════════════

/-- `All` is the boolean monoid under conjunction $(\wedge)$:

- **Operation:** $\text{All}(a) \mathbin{++} \text{All}(b) = \text{All}(a \wedge b)$
- **Identity:** $\text{All}(\text{true})$

$$\text{All}(a) \mathbin{++} \text{All}(b) = \text{All}(a \mathbin{\&\&} b)$$ -/
structure All where
  getAll : Bool
deriving BEq, Ord, Repr, Hashable

/-- `ToString` instance for `All`, displaying as `All(...)`. -/
instance : ToString All where
  toString a := s!"All({a.getAll})"

/-- `Append` instance for `All` — boolean conjunction:
$\text{All}(a) \mathbin{++} \text{All}(b) = \text{All}(a \mathbin{\&\&} b)$. -/
instance : Append All where
  append a b := ⟨a.getAll && b.getAll⟩

/-- Associativity of `All`:

$$(a \mathbin{\&\&} b) \mathbin{\&\&} c = a \mathbin{\&\&} (b \mathbin{\&\&} c)$$

Proved by case analysis on $a$. -/
theorem All.append_assoc (a b c : All) :
    a ++ b ++ c = a ++ (b ++ c) := by
  simp [HAppend.hAppend, Append.append, All.mk.injEq]
  cases a.getAll <;> simp

/-- `Any` is the boolean monoid under disjunction $(\vee)$:

- **Operation:** $\text{Any}(a) \mathbin{++} \text{Any}(b) = \text{Any}(a \vee b)$
- **Identity:** $\text{Any}(\text{false})$

$$\text{Any}(a) \mathbin{++} \text{Any}(b) = \text{Any}(a \mathbin{||} b)$$ -/
structure Any where
  getAny : Bool
deriving BEq, Ord, Repr, Hashable

/-- `ToString` instance for `Any`, displaying as `Any(...)`. -/
instance : ToString Any where
  toString a := s!"Any({a.getAny})"

/-- `Append` instance for `Any` — boolean disjunction:
$\text{Any}(a) \mathbin{++} \text{Any}(b) = \text{Any}(a \mathbin{||} b)$. -/
instance : Append Any where
  append a b := ⟨a.getAny || b.getAny⟩

/-- Associativity of `Any`:

$$(a \mathbin{||} b) \mathbin{||} c = a \mathbin{||} (b \mathbin{||} c)$$

Proved by case analysis on $a$. -/
theorem Any.append_assoc (a b c : Any) :
    a ++ b ++ c = a ++ (b ++ c) := by
  simp [HAppend.hAppend, Append.append, Any.mk.injEq]
  cases a.getAny <;> simp

end LeanStd
