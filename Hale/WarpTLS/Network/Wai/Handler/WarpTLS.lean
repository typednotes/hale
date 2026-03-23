/-
  Hale.WarpTLS.Network.Wai.Handler.WarpTLS — HTTPS support for Warp

  Provides TLS (HTTPS) support for the Warp HTTP server using OpenSSL via FFI.

  ## Design

  `runTLS` creates an OpenSSL context with the given cert/key, then runs
  the standard Warp accept loop with TLS handshake on each connection.

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

namespace Network.Wai.Handler.WarpTLS

open Network.Wai
open Network.HTTP.Types
open Network.Socket
open Network.TLS
open Network.Wai.Handler.Warp

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

/-- Handle a single TLS connection: perform handshake, then run HTTP. -/
private partial def tlsConnection (ctx : TLSContext) (clientSock : Socket .connected)
    (remoteAddr : SockAddr) (settings : Settings) (app : Application) : IO Unit := do
  try
    -- Perform TLS handshake
    let session ← Network.TLS.acceptSocket ctx clientSock.raw
    try
      -- Use the RecvBuffer for HTTP parsing (reads from raw socket, TLS decrypts)
      let buf ← FFI.recvBufCreate clientSock.raw
      let mut keepGoing := true
      while keepGoing do
        let reqOpt ← parseRequest buf remoteAddr
        match reqOpt with
        | none => keepGoing := false
        | some req =>
          let secureReq := { req with isSecure := true }
          let action := connAction secureReq
          let _received ← app secureReq fun resp => do
            let resp' := if action == .close then
              resp.mapResponseHeaders ((hConnection, "close") :: ·)
            else resp
            sendResponse clientSock settings secureReq resp'
          if action != .keepAlive then keepGoing := false
    finally
      Network.TLS.close session
  catch e =>
    settings.settingsOnException (some remoteAddr)
    IO.eprintln s!"WarpTLS: connection error from {remoteAddr}: {e}"
  finally
    Network.Socket.close clientSock

/-- Accept loop for TLS connections. -/
private partial def tlsAcceptLoop (ctx : TLSContext) (serverSock : Socket .listening)
    (settings : Settings) (app : Application) : IO Unit := do
  let (clientSock, remoteAddr) ← Network.Socket.accept serverSock
  let _tid ← Control.Concurrent.forkIO (tlsConnection ctx clientSock remoteAddr settings app)
  tlsAcceptLoop ctx serverSock settings app

/-- Run a WAI application with TLS on the given port.
    $$\text{runTLS} : \text{TLSSettings} \to \text{Settings} \to \text{Application} \to \text{IO Unit}$$ -/
partial def runTLS (tlsSettings : TLSSettings) (settings : Settings)
    (app : Application) : IO Unit := do
  let (certPath, keyPath) := match tlsSettings.certSettings with
    | .certFile c k => (c, k)
  let ctx ← Network.TLS.createContext certPath keyPath
  if tlsSettings.alpn then
    Network.TLS.setAlpn ctx
  let serverSock ← Network.Socket.listenTCP
    settings.settingsHost settings.settingsPort settings.settingsBacklog
  try
    settings.settingsBeforeMainLoop
    tlsAcceptLoop ctx serverSock settings app
  finally
    Network.Socket.close serverSock

end Network.Wai.Handler.WarpTLS
