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
open Network.Wai.AppM (unsafeLift)

/-- Enforce a timeout on request handling.
    If the inner application does not respond within the given number of
    milliseconds, returns 503 Service Unavailable.

    Uses `AppM.unsafeLift` because the timeout/app race requires runtime
    arbitration (an atomic flag ensures exactly-once response despite two
    potential responders). The indexed monad guarantee is upheld dynamically.
    $$\text{timeout} : \mathbb{N} \to \text{Middleware}$$ -/
def timeout (ms : Nat) : Middleware :=
  fun app req respond =>
    unsafeLift do
      -- Atomic flag: ensures exactly one call to `respond`
      let respondedRef ← IO.mkRef false
      let respondOnce : Response → IO ResponseReceived := fun resp => do
        let alreadyResponded ← respondedRef.swap true
        if alreadyResponded then
          -- Second responder loses — return a dummy token
          pure ResponseReceived.done
        else
          respond resp
      -- Run the app in a background task with the guarded callback
      let resultRef ← IO.mkRef (none : Option ResponseReceived)
      let _task ← IO.asTask do
        let r ← (app req respondOnce).run
        resultRef.set (some r)
      -- Wait with timeout
      IO.sleep ms.toUInt32
      let result ← resultRef.get
      match result with
      | some r => return r
      | none =>
        -- Timed out — respond with 503 (respondOnce ensures at most one send)
        respondOnce (.responseBuilder status503 []
          "Service Unavailable: request timed out".toUTF8)

end Network.Wai.Middleware
