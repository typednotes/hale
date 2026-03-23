/-
  Network.Wai.Middleware.Timeout — Request timeout middleware

  Enforces a timeout on request processing. If the inner application
  takes longer than the specified duration, returns 503 Service Unavailable.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Enforce a timeout on request handling.
    If the inner application does not respond within the given number of
    milliseconds, returns 503 Service Unavailable.
    $$\text{timeout} : \mathbb{N} \to \text{Middleware}$$ -/
def timeout (ms : Nat) : Middleware :=
  fun app req respond => do
    let resultRef ← IO.mkRef (none : Option ResponseReceived)
    -- Run the app in a task
    let task ← IO.asTask do
      app req fun resp => do
        let r ← respond resp
        resultRef.set (some r)
        return r
    -- Wait with timeout
    IO.sleep ms.toUInt32
    let result ← resultRef.get
    match result with
    | some r => return r
    | none =>
      -- Timed out — respond with 503
      respond (.responseBuilder status503 []
        "Service Unavailable: request timed out".toUTF8)

end Network.Wai.Middleware
