/-
  Network.Wai.Middleware.ForceDomain — Redirect to canonical domain
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Redirect to a canonical domain if the Host header doesn't match.
    $$\text{forceDomain} : (\text{String} \to \text{Option String}) \to \text{Middleware}$$ -/
def forceDomain (checkDomain : String → Option String) : Middleware :=
  fun app req respond =>
    match req.requestHeaderHost >>= checkDomain with
    | some newHost =>
      let scheme := if req.isSecure then "https://" else "http://"
      let url := scheme ++ newHost ++ req.rawPathInfo ++ req.rawQueryString
      AppM.respond respond (.responseBuilder status301 [(hLocation, url)] ByteArray.empty)
    | none => app req respond

end Network.Wai.Middleware
