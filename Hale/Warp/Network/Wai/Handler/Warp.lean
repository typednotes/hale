/-
  Hale.Warp.Network.Wai.Handler.Warp — Public API for the Warp HTTP server

  Ports Haskell's `Network.Wai.Handler.Warp` from the `warp` package.

  ## Design

  Re-exports all Warp sub-modules and provides the convenience `run` function
  that mirrors Haskell's `Warp.run :: Port -> Application -> IO ()`.

  ## Usage

  ```lean
  import Hale.Warp

  def myApp : Network.Wai.Application := fun req respond =>
    respond (Network.Wai.responseLBS Network.HTTP.Types.status200 [] "Hello!")

  def main : IO Unit :=
    Network.Wai.Handler.Warp.run 3000 myApp
  ```
-/

import Hale.Warp.Network.Wai.Handler.Warp.Types
import Hale.Warp.Network.Wai.Handler.Warp.Internal
import Hale.Warp.Network.Wai.Handler.Warp.Settings
import Hale.Warp.Network.Wai.Handler.Warp.Request
import Hale.Warp.Network.Wai.Handler.Warp.Response
import Hale.Warp.Network.Wai.Handler.Warp.Run
import Hale.Warp.Network.Wai.Handler.Warp.WithApplication

namespace Network.Wai.Handler.Warp

/-- Run a WAI application on the given port with default settings.
    $$\text{run} : \text{UInt16} \to \text{Application} \to \text{IO}(\text{Unit})$$ -/
def run (port : UInt16) (app : Network.Wai.Application) : IO Unit :=
  runSettings { settingsPort := port } app

end Network.Wai.Handler.Warp
