/-
  bench/BenchServer.lean — Non-blocking HTTP server for benchmarking

  Starts a Warp server using the EventDispatcher (non-blocking) mode
  on port 8765 that responds with "OK" to every request.
  Used with wrk or ab for throughput measurement.
-/

import Hale.WAI
import Hale.Warp

open Network.Wai
open Network.Wai.Handler.Warp
open Network.HTTP.Types

def benchApp : Application := fun _req respond =>
  AppM.respond respond (responseLBS status200 [] "OK")

def main : IO Unit := do
  IO.println "Bench server (EventDispatcher/non-blocking) starting on port 8765..."
  let settings : Settings := { settingsPort := 8765 }
  runSettingsEventLoop settings benchApp
