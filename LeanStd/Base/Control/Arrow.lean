/-
  LeanStd.Base.Arrow — Arrow typeclass

  Arrows generalize functions with additional structure, extending `Category`.
  Provides `Arrow` and `ArrowChoice` typeclasses with `Fun` instances.

  ## Hierarchy

  $$\text{Category} \to \text{Arrow} \to \text{ArrowChoice}$$
-/

import LeanStd.Base.Control.Category
import LeanStd.Base.Data.Either

namespace Control
open Data

/-- An `Arrow` is a `Category` with the ability to lift pure functions
    and apply them in parallel.

    **Operations:**
    - `arr`: Lift a pure function $f : \alpha \to \beta$ into the arrow.
      $$\text{arr}(f) : \text{Cat}(\alpha, \beta)$$
    - `first`: Apply an arrow to the first component of a pair, passing the second through.
      $$\text{first}(f) : \text{Cat}(\alpha \times \gamma, \beta \times \gamma)$$
    - `second`: Apply an arrow to the second component.
      $$\text{second}(f) : \text{Cat}(\gamma \times \alpha, \gamma \times \beta)$$
    - `split`: Apply two arrows in parallel (product/fanout):
      $$f \mathbin{\&\&\&} g : \text{Cat}(\alpha \times \gamma, \beta \times \delta)$$
-/
class Arrow (Cat : Type u → Type u → Type v) extends Category Cat where
  /-- Lift a pure function into the arrow. -/
  arr : (α → β) → Cat α β
  /-- Apply an arrow to the first component of a pair.
      $$\text{first}(f)(a, c) = (f(a), c)$$
  -/
  first : Cat α β → Cat (α × γ) (β × γ)
  /-- Apply an arrow to the second component of a pair.
      $$\text{second}(f)(c, a) = (c, f(a))$$
  -/
  second : Cat α β → Cat (γ × α) (γ × β) :=
    fun f => Category.comp (arr Prod.swap) (Category.comp (first f) (arr Prod.swap))
  /-- Apply two arrows in parallel.
      $$\text{split}(f, g)(a, c) = (f(a), g(c))$$
  -/
  split : Cat α β → Cat γ δ → Cat (α × γ) (β × δ) :=
    fun f g => Category.comp (first f) (second g)

/-- `ArrowChoice` extends `Arrow` with the ability to choose between branches,
    working with sum types (`Either`).

    **Operations:**
    - `left`: Apply an arrow to the `Left` case, passing `Right` through.
      $$\text{left}(f)(\text{Left}(a)) = \text{Left}(f(a))$$
      $$\text{left}(f)(\text{Right}(c)) = \text{Right}(c)$$
    - `right`: Apply an arrow to the `Right` case.
    - `fanin`: Merge two arrows:
      $$f \mathbin{|||} g : \text{Cat}(\text{Either}(\alpha, \gamma), \beta)$$
-/
class ArrowChoice (Cat : Type u → Type u → Type v) extends Arrow Cat where
  /-- Apply an arrow to the `Left` branch of an `Either`, passing `Right` through.
      $$\text{left}(f)(\text{Left}(a)) = \text{Left}(f(a)), \quad
        \text{left}(f)(\text{Right}(c)) = \text{Right}(c)$$
  -/
  left : Cat α β → Cat (Either α γ) (Either β γ)
  /-- Apply an arrow to the `Right` branch of an `Either`, passing `Left` through.
      $$\text{right}(f)(\text{Right}(a)) = \text{Right}(f(a)), \quad
        \text{right}(f)(\text{Left}(c)) = \text{Left}(c)$$
  -/
  right : Cat α β → Cat (Either γ α) (Either γ β) :=
    fun f =>
      let swap := arr (fun (e : Either γ α) => match e with
        | .left c => Either.right c
        | .right a => Either.left a)
      let swapBack := arr (fun (e : Either β γ) => match e with
        | .left b => Either.right b
        | .right c => Either.left c)
      Category.comp swap (Category.comp (left f) swapBack)
  /-- Merge two arrows from different branches into a single output.
      $$\text{fanin}(f, g)(\text{Left}(a)) = f(a), \quad
        \text{fanin}(f, g)(\text{Right}(c)) = g(c)$$
  -/
  fanin : Cat α γ → Cat β γ → Cat (Either α β) γ :=
    fun f g =>
      let merge := arr (fun (e : Either γ γ) => match e with
        | .left c => c
        | .right c => c)
      Category.comp (Category.comp (left f) (right g)) merge

-- ── Fun instances ──────────────────────────────

instance : Arrow Fun where
  arr f := ⟨f⟩
  first f := ⟨fun (a, c) => (f.apply a, c)⟩
  second f := ⟨fun (c, a) => (c, f.apply a)⟩
  split f g := ⟨fun (a, c) => (f.apply a, g.apply c)⟩

instance : ArrowChoice Fun where
  left f := ⟨fun e => match e with
    | .left a => .left (f.apply a)
    | .right c => .right c⟩
  right f := ⟨fun e => match e with
    | .left c => .left c
    | .right a => .right (f.apply a)⟩
  fanin f g := ⟨fun e => match e with
    | .left a => f.apply a
    | .right b => g.apply b⟩

end Control
