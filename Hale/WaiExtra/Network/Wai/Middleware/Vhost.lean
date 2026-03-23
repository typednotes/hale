/-
  Network.Wai.Middleware.Vhost — Virtual host routing

  Route requests to different applications based on the Host header.
-/
import Hale.WAI

namespace Network.Wai.Middleware

open Network.Wai

/-- Route requests based on the Host header.
    The first matching entry's application is used.
    $$\text{vhost} : \text{List (String × Application)} \to \text{Middleware}$$ -/
def vhost (hosts : List (String × Application)) : Middleware :=
  fun app req respond =>
    let hostOpt := req.requestHeaderHost
    match hostOpt >>= fun h => hosts.find? (fun (pattern, _) => pattern == h) with
    | some (_, hostApp) => hostApp req respond
    | none => app req respond

end Network.Wai.Middleware
