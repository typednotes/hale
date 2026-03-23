/-
  Network.Wai.Middleware.RealIp — Extract real client IP from proxy headers

  Updates `remoteHost` based on X-Forwarded-For or X-Real-IP headers.
-/
import Hale.WAI
import Hale.HttpTypes
import Hale.Network

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Update the request's `remoteHost` from X-Forwarded-For or X-Real-IP headers.
    X-Forwarded-For takes precedence; uses the leftmost (client) IP.
    $$\text{realIp} : \text{Middleware}$$ -/
def realIp : Middleware :=
  fun app req respond =>
    let xff := req.requestHeaders.find? (fun (n, _) => n == xForwardedFor) |>.map (·.2)
    let xri := req.requestHeaders.find? (fun (n, _) => n == xRealIp) |>.map (·.2)
    let clientIp := xff.bind (fun s => s.splitOn "," |>.head? |>.map String.trim)
      |>.orElse (fun _ => xri)
    match clientIp with
    | some ip => app { req with remoteHost := ⟨ip, req.remoteHost.port⟩ } respond
    | none => app req respond
where
  xForwardedFor := Data.CI.mk' "X-Forwarded-For"
  xRealIp := Data.CI.mk' "X-Real-IP"

end Network.Wai.Middleware
