/-
  Hale.Warp.Network.Wai.Handler.Warp.WithApplication — Test helpers

  Run a WAI Application on a free port for testing.
  The server is automatically shut down after the action completes.

  ## Guarantees
  - Server is always cleaned up (via try/finally)
  - Port is chosen by the OS (no conflicts)
  - Action runs only after server is listening
-/
import Hale.WAI
import Hale.Network
import Hale.Base.Control.Concurrent.Green
import Hale.Warp.Network.Wai.Handler.Warp.Settings
import Hale.Warp.Network.Wai.Handler.Warp.Run

namespace Network.Wai.Handler.Warp

open Network.Wai
open Network.Socket
open Control.Concurrent.Green (Green)

/-- `withApplication` with custom Settings. -/
def withApplicationSettings (settings : Settings) (mkApp : IO Application)
    (action : UInt16 → IO α) : IO α := do
  let app ← mkApp
  let sock ← Network.Socket.listenTCP "0.0.0.0" 0 128
  Network.Socket.setNonBlocking sock
  let disp ← EventDispatcher.create
  let token ← Std.CancellationToken.new
  let _serverTask ← IO.asTask (prio := .dedicated) do
    try
      Green.block (acceptLoopEL sock settings app disp) token
    catch _ => pure ()
    finally
      disp.shutdown
      let _ ← Network.Socket.close sock
  try
    IO.sleep 50
    action 0
  finally
    token.cancel .cancel

/-- Run an Application on a free port. -/
def withApplication (mkApp : IO Application) (action : UInt16 → IO α) : IO α :=
  withApplicationSettings defaultSettings mkApp action

end Network.Wai.Handler.Warp
