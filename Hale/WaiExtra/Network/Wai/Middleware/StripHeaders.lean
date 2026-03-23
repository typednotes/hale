/-
  Network.Wai.Middleware.StripHeaders — Remove specified headers from responses
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Remove the specified headers from all responses.
    $$\text{stripHeaders} : \text{List HeaderName} \to \text{Middleware}$$ -/
def stripHeaders (names : List HeaderName) : Middleware :=
  fun app req respond =>
    app req fun resp =>
      respond (resp.mapResponseHeaders (·.filter fun (n, _) => !names.contains n))

end Network.Wai.Middleware
