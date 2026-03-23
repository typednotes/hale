/-
  Network.Wai.Middleware.MethodOverride — Override HTTP method from query string

  Allows overriding the request method via the `_method` query parameter.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Override the request method if `_method` query parameter is present.
    $$\text{methodOverride} : \text{Middleware}$$ -/
def methodOverride : Middleware :=
  fun app req respond =>
    let req' := match req.queryString.find? (fun (k, _) => k == "_method") with
      | some (_, some v) => { req with requestMethod := parseMethod v }
      | _ => req
    app req' respond

end Network.Wai.Middleware
