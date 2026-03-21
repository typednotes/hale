/-
  LeanStd.Base.Tuple — Tuple (product type) utilities

  Provides combinators for `Prod` with involution and isomorphism proofs.
-/

namespace Data.Tuple

/-- Swap the components of a pair.
    $$\text{swap}(a, b) = (b, a)$$
-/
@[inline] def swap (p : α × β) : β × α := (p.2, p.1)

/-- Map over the first component of a pair.
    $$\text{mapFst}(f, (a, b)) = (f(a), b)$$
-/
@[inline] def mapFst (f : α → γ) (p : α × β) : γ × β := (f p.1, p.2)

/-- Map over the second component of a pair.
    $$\text{mapSnd}(f, (a, b)) = (a, f(b))$$
-/
@[inline] def mapSnd (f : β → γ) (p : α × β) : α × γ := (p.1, f p.2)

/-- Map over both components of a pair simultaneously.
    $$\text{bimap}(f, g, (a, b)) = (f(a), g(b))$$
-/
@[inline] def bimap (f : α → γ) (g : β → δ) (p : α × β) : γ × δ := (f p.1, g p.2)

/-- Curry a function on pairs into a two-argument function.
    $$\text{curry}(f)(a)(b) = f(a, b)$$
-/
@[inline] def curry (f : α × β → γ) (a : α) (b : β) : γ := f (a, b)

/-- Uncurry a two-argument function into a function on pairs.
    $$\text{uncurry}(f)(a, b) = f(a)(b)$$
-/
@[inline] def uncurry (f : α → β → γ) (p : α × β) : γ := f p.1 p.2

-- ── Proofs ─────────────────────────────────────

/-- Swapping twice is identity (involution).
    $$\text{swap}(\text{swap}(p)) = p$$
-/
theorem swap_swap (p : α × β) : swap (swap p) = p := rfl

/-- `curry` and `uncurry` form an isomorphism.
    $$\text{curry}(\text{uncurry}(f)) = f$$
-/
theorem curry_uncurry (f : α → β → γ) : curry (uncurry f) = f := rfl

/-- `uncurry` and `curry` form an isomorphism.
    $$\text{uncurry}(\text{curry}(f)) = f$$
-/
theorem uncurry_curry (f : α × β → γ) : uncurry (curry f) = f := by
  funext ⟨a, b⟩; rfl

/-- `bimap` with identities is identity.
    $$\text{bimap}(\text{id}, \text{id}, p) = p$$
-/
theorem bimap_id (p : α × β) : bimap id id p = p := rfl

/-- `bimap` distributes over composition.
    $$\text{bimap}(f_1 \circ f_2, g_1 \circ g_2, p) = \text{bimap}(f_1, g_1, \text{bimap}(f_2, g_2, p))$$
-/
theorem bimap_comp (f₁ : γ → δ) (f₂ : α → γ) (g₁ : ε → ζ) (g₂ : β → ε) (p : α × β) :
    bimap (f₁ ∘ f₂) (g₁ ∘ g₂) p = bimap f₁ g₁ (bimap f₂ g₂ p) := rfl

/-- `mapFst` is `bimap` with identity on the second component.
    $$\text{mapFst}(f) = \text{bimap}(f, \text{id})$$
-/
theorem mapFst_eq_bimap (f : α → γ) (p : α × β) :
    mapFst f p = bimap f id p := rfl

/-- `mapSnd` is `bimap` with identity on the first component.
    $$\text{mapSnd}(g) = \text{bimap}(\text{id}, g)$$
-/
theorem mapSnd_eq_bimap (g : β → γ) (p : α × β) :
    mapSnd g p = bimap id g p := rfl

end Data.Tuple
