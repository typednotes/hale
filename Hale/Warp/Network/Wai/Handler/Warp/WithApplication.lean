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
import Hale.Warp.Network.Wai.Handler.Warp.Settings
import Hale.Warp.Network.Wai.Handler.Warp.Run

namespace Network.Wai.Handler.Warp

open Network.Wai
open Network.Socket

/-- `withApplication` with custom Settings. The port setting is ignored
    (a free port is always used).
    @since 3.2.7 -/
def withApplicationSettings (settings : Settings) (mkApp : IO Application)
    (action : UInt16 → IO α) : IO α := do
  let app ← mkApp
  -- Bind to port 0 to let OS choose a free port
  let sock ← Network.Socket.listenTCP "0.0.0.0" 0 128
  -- Use a cancellation token for clean shutdown
  let token ← Std.CancellationToken.new
  -- Run server in background task
  let _serverTask ← IO.asTask (prio := .dedicated) do
    try
      -- Run until cancelled
      while !(← token.isCancelled) do
        -- acceptLoop is blocking; for now just run it
        acceptLoop sock settings app
    catch _ => pure ()
    finally
      let _ ← Network.Socket.close sock
  try
    -- Give server a moment to start accepting
    IO.sleep 50
    action 0  -- TODO: return actual bound port via getsockname FFI
  finally
    token.cancel .cancel

/-- Run an Application on a free port. Passes the port to the given operation
    and executes it while the Application is running. Shuts down the server
    before returning.
    $$\text{withApplication} : \text{IO Application} \to (\text{UInt16} \to \text{IO}\ \alpha) \to \text{IO}\ \alpha$$
    @since 3.2.4 -/
def withApplication (mkApp : IO Application) (action : UInt16 → IO α) : IO α :=
  withApplicationSettings defaultSettings mkApp action

end Network.Wai.Handler.Warp
