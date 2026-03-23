/-
  Network.Wai.Middleware.Routed — Path-based middleware routing

  Apply different middleware based on the request path.
-/
import Hale.WAI

namespace Network.Wai.Middleware

open Network.Wai

/-- Apply middleware only to requests matching the given path predicate.
    $$\text{routed} : (\text{Request} \to \text{Bool}) \to \text{Middleware} \to \text{Middleware}$$ -/
def routed (predicate : Request → Bool) (middle : Middleware) : Middleware :=
  fun app req respond =>
    if predicate req then
      middle app req respond
    else
      app req respond

/-- Apply middleware only to requests with the given path prefix.
    $$\text{routedPrefix} : \text{String} \to \text{Middleware} \to \text{Middleware}$$ -/
def routedPrefix (pathPrefix : String) (middle : Middleware) : Middleware :=
  routed (fun req => req.rawPathInfo.startsWith pathPrefix) middle

end Network.Wai.Middleware
