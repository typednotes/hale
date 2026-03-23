/-
  Echo server example — returns the request body as the response.

  Run:   lake exe echo-server
  Test:  curl -X POST -d 'hello' http://localhost:3000/
         curl http://localhost:3000/
-/
import Hale

open Network.Wai Network.HTTP.Types

def echoApp : Application := fun req respond => do
  let body ← req.requestBody
  respond (responseLBS status200 [(hContentType, "text/plain")]
    (String.fromUTF8! body))

def main : IO Unit := do
  IO.println "Echo server listening on http://0.0.0.0:3000"
  Network.Wai.Handler.Warp.run 3000 echoApp
