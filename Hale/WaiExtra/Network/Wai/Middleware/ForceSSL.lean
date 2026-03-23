/-
  Network.Wai.Middleware.ForceSSL — Redirect HTTP to HTTPS

  Redirects all non-secure requests to their HTTPS equivalent.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Redirect non-secure requests to HTTPS.
    $$\text{forceSSL} : \text{Middleware}$$ -/
def forceSSL : Middleware :=
  fun app req respond =>
    if req.isSecure then
      app req respond
    else
      let host := req.requestHeaderHost.getD "localhost"
      let url := "https://" ++ host ++ req.rawPathInfo ++ req.rawQueryString
      respond (.responseBuilder status301 [(hLocation, url)] ByteArray.empty)

end Network.Wai.Middleware
