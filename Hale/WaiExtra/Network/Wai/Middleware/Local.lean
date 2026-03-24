/-
  Network.Wai.Middleware.Local — Restrict access to localhost

  Only allows requests from localhost, returning 403 for others.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Only allow requests from localhost. Returns 403 Forbidden for remote clients.
    $$\text{localOnly} : \text{Middleware}$$ -/
def localOnly : Middleware :=
  fun app req respond =>
    let host := req.remoteHost.host
    if host == "127.0.0.1" || host == "::1" || host == "localhost" then
      app req respond
    else
      AppM.respond respond (.responseBuilder status403 [] "Forbidden: localhost only".toUTF8)

end Network.Wai.Middleware
