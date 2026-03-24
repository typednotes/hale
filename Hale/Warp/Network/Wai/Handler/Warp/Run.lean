/-
  Hale.Warp.Network.Wai.Handler.Warp.Run — Accept loop and connection handling

  Ports Haskell's Warp server run loop. Binds a TCP socket, accepts connections,
  and spawns a task per connection to handle HTTP requests.

  ## Design

  - `runSettings` is the main entry point: creates a listening socket,
    runs `settingsBeforeMainLoop`, and enters the accept loop.
  - `acceptLoop` accepts connections and spawns green threads via `forkIO`
    for each (uses the thread pool, not dedicated OS threads).
  - `runConnection` handles a connection with keep-alive support: creates
    a `RecvBuffer` once, then loops over requests until the client
    signals `Connection: close` or the connection drops.

  ## Dependent-Type Guarantees

  This module is the **trust boundary** between the type-safe application
  world and the raw IO world.  The server provides the `respond` callback
  and calls `(app req respond).run` to extract the `IO` action.  The
  `AppM` indexed monad ensures that by the time `.run` is called, the
  application has invoked `respond` exactly once.

  The socket phantom types flow through the entire call chain:
  - `acceptLoop` requires `Socket .listening` (compile-time)
  - `accept` returns `Socket .connected` (compile-time)
  - `runConnection` requires `Socket .connected` (compile-time)
  - `close` requires `state ≠ .closed` proof (compile-time)

  Keep-alive semantics are proven correct:
  - `connAction_http10_default`: HTTP/1.0 defaults to close
  - `connAction_http11_default`: HTTP/1.1 defaults to keep-alive
-/

import Hale.WAI
import Hale.HttpTypes
import Hale.Network
import Hale.Base.Control.Concurrent
import Hale.Warp.Network.Wai.Handler.Warp.Settings
import Hale.Warp.Network.Wai.Handler.Warp.Request
import Hale.Warp.Network.Wai.Handler.Warp.Response

namespace Network.Wai.Handler.Warp

open Network.Wai
open Network.Socket
open Network.HTTP.Types

/-- Connection action after handling a request.
    Encodes the HTTP/1.1 keep-alive state machine. -/
inductive ConnAction where
  | keepAlive  -- continue reading next request on this connection
  | close      -- close the connection
deriving BEq, Repr

/-- Determine whether to keep the connection alive based on HTTP version
    and the Connection header.
    - HTTP/1.1: keep-alive by default, close if "Connection: close"
    - HTTP/1.0: close by default, keep-alive if "Connection: keep-alive" -/
def connAction (req : Network.Wai.Request) : ConnAction :=
  let connHdr := req.requestHeaders.find? (fun (n, _) => n == hConnection)
    |>.map (·.2.toLower)
  if req.httpVersion == http11 then
    if connHdr == some "close" then .close else .keepAlive
  else
    if connHdr == some "keep-alive" then .keepAlive else .close

/-- HTTP/1.0 without Connection header defaults to close.
    $$\forall\, \text{req},\; \text{req.httpVersion} \neq \text{HTTP/1.1} \land \text{Connection} \notin \text{headers} \implies \text{connAction}(\text{req}) = \text{close}$$ -/
theorem connAction_http10_default (req : Network.Wai.Request)
    (hVer : (req.httpVersion == http11) = false)
    (hNoConn : req.requestHeaders.find? (fun (n, _) => n == hConnection) = none) :
    connAction req = .close := by
  unfold connAction
  simp [hVer, hNoConn]

/-- HTTP/1.1 without Connection header defaults to keep-alive.
    $$\forall\, \text{req},\; \text{req.httpVersion} = \text{HTTP/1.1} \land \text{Connection} \notin \text{headers} \implies \text{connAction}(\text{req}) = \text{keepAlive}$$ -/
theorem connAction_http11_default (req : Network.Wai.Request)
    (hVer : (req.httpVersion == http11) = true)
    (hNoConn : req.requestHeaders.find? (fun (n, _) => n == hConnection) = none) :
    connAction req = .keepAlive := by
  unfold connAction
  simp [hVer, hNoConn]

/-- Handle a single HTTP connection with keep-alive support.
    Creates a RecvBuffer once, loops over requests until close.
    Requires a connected socket.
    $$\text{runConnection} : \text{Socket}\ \texttt{.connected} \to \text{SockAddr} \to \text{Settings} \to \text{Application} \to \text{IO}(\text{Unit})$$ -/
partial def runConnection (clientSock : Socket .connected) (remoteAddr : SockAddr)
    (settings : Settings) (app : Application) : IO Unit := do
  let buf ← FFI.recvBufCreate clientSock.raw
  try
    let mut keepGoing := true
    while keepGoing do
      let reqOpt ← parseRequest buf remoteAddr
      match reqOpt with
      | none => keepGoing := false  -- Connection closed or malformed
      | some req =>
        let action := connAction req
        let _received ← (app req fun resp => do
          -- Add Connection header to response when closing
          let resp' := if action == .close then
            resp.mapResponseHeaders ((hConnection, "close") :: ·)
          else resp
          sendResponse clientSock settings req resp').run
        -- Drain any unread body bytes before next request
        if action == .keepAlive then
          -- Only drain body if there are unread bytes
          match req.requestBodyLength with
          | .chunkedBody => pure ()      -- Chunked → no known size to drain
          | .knownLength 0 => pure ()    -- Empty body
          | .knownLength _ =>
            let mut bodyDone := false
            while !bodyDone do
              let chunk ← req.requestBody
              if chunk.isEmpty then bodyDone := true
        else
          keepGoing := false
  catch e =>
    settings.settingsOnException (some remoteAddr)
    IO.eprintln s!"Warp: connection error from {remoteAddr}: {e}"
  finally
    let _ ← Network.Socket.close clientSock

/-- Accept loop: continuously accepts connections and spawns tasks.
    Each accepted connection is handled in a separate task via `IO.asTask`.
    Requires a listening socket.
    $$\text{acceptLoop} : \text{Socket}\ \texttt{.listening} \to \text{Settings} \to \text{Application} \to \text{IO}(\text{Unit})$$ -/
partial def acceptLoop (serverSock : Socket .listening) (settings : Settings)
    (app : Application) : IO Unit := do
  let (clientSock, remoteAddr) ← Network.Socket.accept serverSock
  -- Spawn connection handler as a green thread on the scheduler
  let _tid ← Control.Concurrent.forkIO (runConnection clientSock remoteAddr settings app)
  -- Continue accepting
  acceptLoop serverSock settings app

/-- Run a WAI application with the given settings.
    Creates a TCP server socket, runs the before-main-loop callback,
    and enters the accept loop.
    $$\text{runSettings} : \text{Settings} \to \text{Application} \to \text{IO}(\text{Unit})$$ -/
def runSettings (settings : Settings) (app : Application) : IO Unit := do
  let serverSock ← Network.Socket.listenTCP
    settings.settingsHost settings.settingsPort settings.settingsBacklog
  try
    settings.settingsBeforeMainLoop
    acceptLoop serverSock settings app
  finally
    let _ ← Network.Socket.close serverSock

end Network.Wai.Handler.Warp
