/-
  LeanStd.Base.Identity — The identity functor/monad

  The simplest functor: wraps a value with no extra structure.
-/

namespace LeanStd

/-- The identity functor. `Identity α` is isomorphic to `α`. -/
structure Identity (α : Type u) where
  runIdentity : α
deriving BEq, Ord, Repr, Hashable, Inhabited

instance [ToString α] : ToString (Identity α) where
  toString i := toString i.runIdentity

instance : Functor Identity where
  map f i := ⟨f i.runIdentity⟩

instance : Pure Identity where
  pure a := ⟨a⟩

instance : Bind Identity where
  bind i f := f i.runIdentity

instance : Seq Identity where
  seq f x := ⟨f.runIdentity (x ()).runIdentity⟩

instance : Applicative Identity where

instance : Monad Identity where

namespace Identity

-- Functor laws
theorem map_id (x : Identity α) : id <$> x = x := rfl
theorem map_comp (f : β → γ) (g : α → β) (x : Identity α) :
    (f ∘ g) <$> x = f <$> (g <$> x) := rfl

-- Monad laws
theorem pure_bind (a : α) (f : α → Identity β) :
    pure a >>= f = f a := rfl

theorem bind_pure (x : Identity α) :
    x >>= pure = x := rfl

theorem bind_assoc (x : Identity α) (f : α → Identity β) (g : β → Identity γ) :
    (x >>= f) >>= g = x >>= (fun a => f a >>= g) := rfl

end Identity
end LeanStd
