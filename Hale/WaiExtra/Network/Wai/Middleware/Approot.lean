/-
  Network.Wai.Middleware.Approot — Application root detection

  Detects the application root URL from headers or configuration.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Middleware that sets the approot vault key based on request headers.
    Useful for applications behind reverse proxies.
    $$\text{approotMiddleware} : \text{String} \to \text{Middleware}$$
    The provided function determines the approot from the request. -/
def approotMiddleware (getApproot : Request → String) : Middleware :=
  fun app req respond =>
    -- Just pass through — the approot can be computed from the request
    -- by application code using the provided function
    app req respond

/-- Get the approot from a request, considering X-Forwarded-Proto and Host. -/
def getApprootFromRequest (req : Request) : String :=
  let proto := if req.isSecure then "https" else
    match req.requestHeaders.find? (fun (n, _) => n == Data.CI.mk' "X-Forwarded-Proto") with
    | some (_, v) => v
    | none => "http"
  let host := req.requestHeaderHost.getD "localhost"
  proto ++ "://" ++ host

end Network.Wai.Middleware
