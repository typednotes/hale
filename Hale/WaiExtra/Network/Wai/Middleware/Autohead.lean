/-
  Network.Wai.Middleware.Autohead — Automatically handle HEAD requests

  Converts HEAD requests to GET and strips the response body.
  @since 3.0.4
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Convert HEAD requests to GET, passing the result but stripping the body.
    $$\text{autohead} : \text{Middleware}$$ -/
def autohead : Middleware :=
  fun app req respond =>
    if req.requestMethod == .standard .HEAD then
      app { req with requestMethod := .standard .GET } fun resp =>
        respond (.responseBuilder resp.status resp.headers ByteArray.empty)
    else
      app req respond

end Network.Wai.Middleware
