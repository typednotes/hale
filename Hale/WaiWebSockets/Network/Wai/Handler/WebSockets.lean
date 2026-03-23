/-
  Network.Wai.Handler.WebSockets — WAI/WebSocket bridge

  Upgrade WAI requests to WebSocket connections.
  Mirrors Haskell's `Network.Wai.Handler.WebSockets`.
-/
import Hale.WAI
import Hale.HttpTypes
import Hale.WebSockets

namespace Network.Wai.Handler.WebSockets

open Network.Wai
open Network.HTTP.Types
open Network.WebSockets

/-- Check if a WAI request is a WebSocket upgrade request. -/
def isWebSocketsReq (req : Request) : Bool :=
  let upgrade := req.requestHeaders.find? (fun (n, _) => n == Data.CI.mk' "Upgrade")
    |>.map (·.2)
  upgrade.any (·.toLower == "websocket")

/-- Try to upgrade a WAI request to a WebSocket connection.
    Returns `some response` (a raw response that performs the handshake)
    if the request is a WebSocket upgrade, `none` otherwise. -/
def websocketsApp (_opts : ConnectionOptions) (wsApp : ServerApp)
    (req : Request) : Option Response :=
  if !isWebSocketsReq req then none
  else
    let clientKey := req.requestHeaders.find?
      (fun (n, _) => n == Data.CI.mk' "Sec-WebSocket-Key") |>.map (·.2)
    match clientKey with
    | none => none
    | some key =>
      some (.responseRaw (fun recv send => do
        -- Send handshake response
        let handshakeResp := buildHandshakeResponse key
        send handshakeResp.toUTF8
        -- Create WebSocket connection
        let conn ← mkConnection send recv
        let reqHead : RequestHead := {
          path := req.rawPathInfo
          headers := req.requestHeaders.map fun (n, v) => (toString n, v)
        }
        let pending : PendingConnection := {
          request := reqHead
          acceptIO := pure conn
        }
        wsApp pending)
      -- Fallback response (never used when raw is supported)
      (.responseBuilder status500 [] "WebSocket upgrade failed".toUTF8))

/-- Combine a WebSocket app with a regular WAI app.
    WebSocket requests go to the WS app, everything else to the backup.
    $$\text{websocketsOr} : \text{ConnectionOptions} \to \text{ServerApp} \to \text{Application} \to \text{Application}$$ -/
def websocketsOr (opts : ConnectionOptions) (wsApp : ServerApp)
    (backup : Application) : Application :=
  fun req respond =>
    match websocketsApp opts wsApp req with
    | some resp => respond resp
    | none => backup req respond

end Network.Wai.Handler.WebSockets
