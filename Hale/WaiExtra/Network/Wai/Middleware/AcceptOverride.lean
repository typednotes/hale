/-
  Network.Wai.Middleware.AcceptOverride — Override Accept header from query string

  Allows overriding the Accept header via the `_accept` query parameter.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Override the Accept header if `_accept` query parameter is present.
    $$\text{acceptOverride} : \text{Middleware}$$ -/
def acceptOverride : Middleware :=
  fun app req respond =>
    let req' := match req.queryString.find? (fun (k, _) => k == "_accept") with
      | some (_, some v) =>
        { req with requestHeaders := (hAccept, v) :: req.requestHeaders.filter (·.1 != hAccept) }
      | _ => req
    app req' respond

end Network.Wai.Middleware
