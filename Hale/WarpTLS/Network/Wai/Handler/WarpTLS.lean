/-
  Hale.WarpTLS.Network.Wai.Handler.WarpTLS — HTTPS support for Warp

  Provides TLS (HTTPS) support for the Warp HTTP server using OpenSSL via FFI.
  Uses the EventDispatcher and Green monad for non-blocking I/O.

  ## Guarantees

  - Minimum TLS 1.2 (enforced by OpenSSL configuration)
  - ALPN negotiation for HTTP/2 (when enabled)
  - TLS sessions are cleaned up on connection close
  - Certificate and key are validated at startup
-/
import Hale.WAI
import Hale.HttpTypes
import Hale.Network
import Hale.TLS
import Hale.Warp
import Hale.Base.Control.Concurrent
import Hale.Base.Control.Concurrent.Green

namespace Network.Wai.Handler.WarpTLS

open Network.Wai
open Network.HTTP.Types
open Network.Socket
open Network.TLS
open Network.Wai.Handler.Warp
open Control.Concurrent.Green (Green)

/-- How to handle non-TLS (plain HTTP) connections. -/
inductive OnInsecure where
  | denyInsecure (message : String)
  | allowInsecure
deriving BEq, Repr

/-- Certificate source. -/
inductive CertSettings where
  | certFile (certPath keyPath : String)
deriving Repr

/-- TLS-specific settings for warp-tls. -/
structure TLSSettings where
  certSettings : CertSettings
  onInsecure : OnInsecure := .denyInsecure "This server requires HTTPS"
  alpn : Bool := true

/-- Handle a single TLS connection using the EventDispatcher. -/
private partial def tlsConnection (ctx : TLSContext) (clientSock : Socket .connected)
    (remoteAddr : SockAddr) (settings : Settings) (app : Application)
    (disp : EventDispatcher) : Green Unit := do
  try
    let session ← (Network.TLS.acceptSocket ctx clientSock.raw : IO _)
    try
      let buf ← (FFI.recvBufCreate clientSock.raw : IO _)
      let mut keepGoing := true
      while keepGoing do
        disp.waitReadable clientSock
        let reqOpt ← (parseRequest buf remoteAddr : IO _)
        match reqOpt with
        | none => keepGoing := false
        | some req =>
          let secureReq := { req with isSecure := true }
          let action := connAction secureReq
          let _received ← (app secureReq fun resp => do
            let resp' := if action == .close then
              resp.mapResponseHeaders ((hConnection, "close") :: ·)
            else resp
            sendResponseEL clientSock settings secureReq resp' disp).run
          if action != .keepAlive then keepGoing := false
    finally
      (Network.TLS.close session : IO _)
  catch e =>
    (settings.settingsOnException (some remoteAddr) : IO _)
    (IO.eprintln s!"WarpTLS: connection error from {remoteAddr}: {e}" : IO _)
  finally
    let _ ← (Network.Socket.close clientSock : IO _)

/-- Accept loop for TLS connections using the EventDispatcher. -/
private partial def tlsAcceptLoop (ctx : TLSContext) (serverSock : Socket .listening)
    (settings : Settings) (app : Application) (disp : EventDispatcher) : Green Unit := do
  while true do
    disp.waitReadable serverSock
    match ← (Network.Socket.accept serverSock : IO _) with
    | .accepted clientSock remoteAddr =>
      let _ ← (Control.Concurrent.forkGreen
        (tlsConnection ctx clientSock remoteAddr settings app disp) : IO _)
    | .wouldBlock => pure ()
    | .error _ => pure ()

/-- Run a WAI application with TLS on the given port. -/
partial def runTLS (tlsSettings : TLSSettings) (settings : Settings)
    (app : Application) : IO Unit := do
  let (certPath, keyPath) := match tlsSettings.certSettings with
    | .certFile c k => (c, k)
  let ctx ← Network.TLS.createContext certPath keyPath
  if tlsSettings.alpn then
    Network.TLS.setAlpn ctx
  let serverSock ← Network.Socket.listenTCP
    settings.settingsHost settings.settingsPort settings.settingsBacklog
  Network.Socket.setNonBlocking serverSock
  let disp ← EventDispatcher.create
  let token ← Std.CancellationToken.new
  try
    settings.settingsBeforeMainLoop
    Green.block (tlsAcceptLoop ctx serverSock settings app disp) token
  finally
    disp.shutdown
    let _ ← Network.Socket.close serverSock

end Network.Wai.Handler.WarpTLS
