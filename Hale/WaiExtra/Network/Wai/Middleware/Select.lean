/-
  Network.Wai.Middleware.Select — Conditionally apply middleware
-/
import Hale.WAI

namespace Network.Wai.Middleware

open Network.Wai

/-- Conditionally apply a middleware based on a request predicate.
    If the predicate returns `some middleware`, apply it; otherwise pass through.
    $$\text{select} : (\text{Request} \to \text{Option Middleware}) \to \text{Middleware}$$ -/
def select (choose : Request → Option Middleware) : Middleware :=
  fun app req respond =>
    match choose req with
    | some mid => mid app req respond
    | none => app req respond

/-- Select with always-none is the identity middleware.
    $$\text{select}(\lambda\, \_.\; \text{none}) = \text{id}$$ -/
theorem select_none : select (fun _ => (none : Option Middleware)) = (id : Middleware) := rfl

end Network.Wai.Middleware
