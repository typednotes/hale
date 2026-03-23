/-
  Network.Wai.Middleware.AddHeaders — Add headers to every response
  @since 3.0.3
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Add the given headers to all responses.
    $$\text{addHeaders} : \text{ResponseHeaders} \to \text{Middleware}$$ -/
def addHeaders (hdrs : ResponseHeaders) : Middleware :=
  fun app req respond =>
    app req fun resp =>
      respond (resp.mapResponseHeaders (· ++ hdrs))

end Network.Wai.Middleware
