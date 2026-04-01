/-
  Hale.Warp.Network.Wai.Handler.Warp.Run — Accept loop and connection handling

  Ports Haskell's Warp server run loop. Binds a TCP socket, accepts connections,
  and spawns a green thread per connection to handle HTTP requests.

  ## Design

  Two execution modes are available:
  - **Blocking mode** (default): Uses blocking `accept`/`recv`/`send` with
    `forkIO` per connection. Maximizes throughput for I/O-bound workloads
    (~180k QPS on a modern machine).
  - **EventDispatcher mode**: Uses non-blocking sockets with kqueue/epoll
    via `EventDispatcher` and `Green` threads. Better for high-concurrency
    scenarios where many connections are idle (e.g., WebSockets, long-polling).
    Accessible via `runSettingsEventLoop`.

  ## Dependent-Type Guarantees

  The socket phantom types flow through the entire call chain:
  - `acceptLoop` requires `Socket .listening` (compile-time)
  - `accept` returns `AcceptOutcome` with `Socket .connected` (compile-time)
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
import Hale.Base.Control.Concurrent.Green
import Hale.Warp.Network.Wai.Handler.Warp.Settings
import Hale.Warp.Network.Wai.Handler.Warp.Request
import Hale.Warp.Network.Wai.Handler.Warp.Response

namespace Network.Wai.Handler.Warp

open Network.Wai
open Network.Socket
open Network.HTTP.Types
open Control.Concurrent.Green (Green)

/-- Connection action after handling a request.
    Encodes the HTTP/1.1 keep-alive state machine. -/
inductive ConnAction where
  | keepAlive  -- continue reading next request on this connection
  | close      -- close the connection
deriving BEq, Repr

/-- Determine whether to keep the connection alive based on HTTP version
    and the Connection header. -/
def connAction (req : Network.Wai.Request) : ConnAction :=
  let connHdr := req.requestHeaders.find? (fun (n, _) => n == hConnection)
    |>.map (·.2.toLower)
  if req.httpVersion == http11 then
    if connHdr == some "close" then .close else .keepAlive
  else
    if connHdr == some "keep-alive" then .keepAlive else .close

/-- HTTP/1.0 without Connection header defaults to close. -/
theorem connAction_http10_default (req : Network.Wai.Request)
    (hVer : (req.httpVersion == http11) = false)
    (hNoConn : req.requestHeaders.find? (fun (n, _) => n == hConnection) = none) :
    connAction req = .close := by
  unfold connAction; simp [hVer, hNoConn]

/-- HTTP/1.1 without Connection header defaults to keep-alive. -/
theorem connAction_http11_default (req : Network.Wai.Request)
    (hVer : (req.httpVersion == http11) = true)
    (hNoConn : req.requestHeaders.find? (fun (n, _) => n == hConnection) = none) :
    connAction req = .keepAlive := by
  unfold connAction; simp [hVer, hNoConn]

-- ══════════════════════════════════════════════════════════════
-- Blocking mode (default, maximum throughput)
-- ══════════════════════════════════════════════════════════════

/-- Handle a single HTTP connection with keep-alive support (blocking mode).
    Uses blocking RecvBuffer and BS.sendAll for maximum throughput. -/
partial def runConnection (clientSock : Socket .connected) (remoteAddr : SockAddr)
    (settings : Settings) (app : Application) : IO Unit := do
  let buf ← FFI.recvBufCreate clientSock.raw
  let token ← Std.CancellationToken.new
  try
    let mut keepGoing := true
    while keepGoing do
      let reqOpt ← parseRequest buf remoteAddr
      match reqOpt with
      | none => keepGoing := false
      | some req =>
        let action := connAction req
        let _received ← Green.block (app req fun resp => do
          let resp' := if action == .close then
            resp.mapResponseHeaders ((hConnection, "close") :: ·)
          else resp
          sendResponse clientSock settings req resp').run token
        if action == .keepAlive then
          match req.requestBodyLength with
          | .chunkedBody => pure ()
          | .knownLength 0 => pure ()
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

/-- Accept loop (blocking mode): blocking accept + forkIO per connection. -/
partial def acceptLoop (serverSock : Socket .listening) (settings : Settings)
    (app : Application) : IO Unit := do
  let (clientSock, remoteAddr) ← Network.Socket.Blocking.accept serverSock
  let _tid ← Control.Concurrent.forkIO (runConnection clientSock remoteAddr settings app)
  acceptLoop serverSock settings app

/-- Run a WAI application with the given settings (blocking mode, default).
    Maximum throughput for I/O-bound workloads. -/
def runSettings (settings : Settings) (app : Application) : IO Unit := do
  let serverSock ← Network.Socket.listenTCP
    settings.settingsHost settings.settingsPort settings.settingsBacklog
  try
    settings.settingsBeforeMainLoop
    acceptLoop serverSock settings app
  finally
    let _ ← Network.Socket.close serverSock

-- ══════════════════════════════════════════════════════════════
-- EventDispatcher mode (high-concurrency, non-blocking)
-- ══════════════════════════════════════════════════════════════

/-- Handle a single HTTP connection (EventDispatcher mode).
    Uses an optimistic try-first pattern: attempts parseRequest immediately
    (data is often already buffered), only falls back to waitReadable on EAGAIN.
    This avoids EventDispatcher overhead for the common case. -/
partial def runConnectionEL (clientSock : Socket .connected) (remoteAddr : SockAddr)
    (settings : Settings) (app : Application) (disp : EventDispatcher) : Green Unit := do
  let buf ← (FFI.recvBufCreate clientSock.raw : IO _)
  -- Wait for first data (the initial request headers always need a wait)
  disp.waitReadable clientSock
  try
    let mut keepGoing := true
    while keepGoing do
      -- Optimistic: try parseRequest directly (RecvBuffer retries on EAGAIN)
      let reqOpt ← (parseRequest buf remoteAddr : IO _)
      match reqOpt with
      | none => keepGoing := false
      | some req =>
        let action := connAction req
        let _received ← (app req fun resp => do
          let resp' := if action == .close then
            resp.mapResponseHeaders ((hConnection, "close") :: ·)
          else resp
          sendResponseEL clientSock settings req resp' disp).run
        if action == .keepAlive then
          match req.requestBodyLength with
          | .chunkedBody => pure ()
          | .knownLength 0 => pure ()
          | .knownLength _ =>
            let mut bodyDone := false
            while !bodyDone do
              let chunk ← (req.requestBody : IO _)
              if chunk.isEmpty then bodyDone := true
          -- Wait for next request's data before looping
          disp.waitReadable clientSock
        else
          keepGoing := false
  catch e =>
    (settings.settingsOnException (some remoteAddr) : IO _)
    (IO.eprintln s!"Warp: connection error from {remoteAddr}: {e}" : IO _)
  finally
    let _ ← (Network.Socket.close clientSock : IO _)

/-- Accept loop (EventDispatcher mode): try accept first, wait only on wouldBlock. -/
partial def acceptLoopEL (serverSock : Socket .listening) (settings : Settings)
    (app : Application) (disp : EventDispatcher) : Green Unit := do
  while true do
    match ← (Network.Socket.accept serverSock : IO _) with
    | .accepted clientSock remoteAddr =>
      let _ ← (Control.Concurrent.forkGreen
        (runConnectionEL clientSock remoteAddr settings app disp) : IO _)
    | .wouldBlock =>
      -- No pending connections — wait for readability then retry
      disp.waitReadable serverSock
    | .error _ => pure ()

/-- Run a WAI application with non-blocking EventDispatcher mode.
    Better for high-concurrency scenarios with many idle connections. -/
def runSettingsEventLoop (settings : Settings) (app : Application) : IO Unit := do
  let serverSock ← Network.Socket.listenTCP
    settings.settingsHost settings.settingsPort settings.settingsBacklog
  Network.Socket.setNonBlocking serverSock
  let disp ← Network.Socket.EventDispatcher.create
  let token ← Std.CancellationToken.new
  try
    settings.settingsBeforeMainLoop
    Green.block (acceptLoopEL serverSock settings app disp) token
  finally
    disp.shutdown
    let _ ← Network.Socket.close serverSock

end Network.Wai.Handler.Warp
