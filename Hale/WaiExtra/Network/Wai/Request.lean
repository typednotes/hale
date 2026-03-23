/-
  Network.Wai.Request — Request utility functions
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai

open Network.HTTP.Types

/-- Check if a request appears to be secure, considering both the
    direct TLS connection and common reverse proxy headers
    (X-Forwarded-Proto, X-Forwarded-SSL).
    $$\text{appearsSecure} : \text{Request} \to \text{Bool}$$ -/
def appearsSecure (req : Request) : Bool :=
  req.isSecure ||
  ((req.requestHeaders.find? (fun (n, _) => n == Data.CI.mk' "X-Forwarded-Proto")).map (·.2) == some "https") ||
  ((req.requestHeaders.find? (fun (n, _) => n == Data.CI.mk' "X-Forwarded-SSL")).map (·.2) == some "on")

end Network.Wai
