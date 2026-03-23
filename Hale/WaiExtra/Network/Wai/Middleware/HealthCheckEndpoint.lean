/-
  Network.Wai.Middleware.HealthCheckEndpoint — Empty health check endpoint

  Adds a health check endpoint at the specified path that returns 200 OK.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Add a health check endpoint at the given path.
    Returns 200 OK with empty body without calling the inner app.
    $$\text{healthCheck} : \text{String} \to \text{Middleware}$$ -/
def healthCheck (path : String := "/_health") : Middleware :=
  fun app req respond =>
    if req.rawPathInfo == path then
      respond (.responseBuilder status200 [] ByteArray.empty)
    else
      app req respond

/-- Non-health-check requests pass through unchanged.
    $$\text{req.rawPathInfo} \ne \text{path} \implies \text{healthCheck}(\text{path})(\text{app}, \text{req}) = \text{app}(\text{req})$$ -/
theorem healthCheck_passthrough (path : String) (app : Application) (req : Request)
    (respond : Response → IO ResponseReceived)
    (h : (req.rawPathInfo == path) = false) :
    healthCheck path app req respond = app req respond := by
  simp [healthCheck, h]

end Network.Wai.Middleware
