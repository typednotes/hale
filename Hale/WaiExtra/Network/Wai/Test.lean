/-
  Network.Wai.Test — WAI testing utilities

  Provides a simulated WAI environment for testing Applications
  without a real network connection.
-/
import Hale.WAI
import Hale.HttpTypes
import Hale.Base.Control.Concurrent.Green

namespace Network.Wai.Test

open Network.Wai
open Network.HTTP.Types
open Control.Concurrent.Green (Green)

/-- A simulated request for testing. -/
structure SRequest where
  method : Method := .standard .GET
  path : String := "/"
  headers : RequestHeaders := []
  body : ByteArray := ByteArray.empty
  isSecure : Bool := false

/-- A captured response from testing. -/
structure SResponse where
  simpleStatus : Status
  simpleHeaders : ResponseHeaders
  simpleBody : ByteArray

/-- Build a WAI Request from an SRequest. -/
def toWaiRequest (sreq : SRequest) : Request :=
  let (rawPath, rawQuery) := match sreq.path.splitOn "?" with
    | [p, q] => (p, "?" ++ q)
    | _ => (sreq.path, "")
  let segments := rawPath.splitOn "/" |>.filter (!·.isEmpty)
  let bodyRef : IO ByteArray := pure sreq.body
  { requestMethod := sreq.method
  , httpVersion := http11
  , rawPathInfo := rawPath
  , rawQueryString := rawQuery
  , requestHeaders := sreq.headers
  , isSecure := sreq.isSecure
  , remoteHost := ⟨"127.0.0.1", 0⟩
  , pathInfo := segments
  , queryString := []  -- TODO: parse query string
  , requestBody := bodyRef
  , vault := Data.Vault.empty
  , requestBodyLength := .knownLength sreq.body.size
  , requestHeaderHost := some "localhost"
  , requestHeaderRange := none
  , requestHeaderReferer := none
  , requestHeaderUserAgent := some "Hale-Test/1.0"
  }

/-- Run a WAI Application with a simulated request and capture the response.
    Runs the Green computation via `Green.block`.
    $$\text{runSession} : \text{Application} \to \text{SRequest} \to \text{IO SResponse}$$ -/
def runSession (app : Application) (sreq : SRequest) : IO SResponse := do
  let waiReq := toWaiRequest sreq
  let resultRef ← IO.mkRef (none : Option SResponse)
  let token ← Std.CancellationToken.new
  let _received ← Green.block (app waiReq fun resp => do
    let body := match resp with
      | .responseBuilder _ _ b => b
      | _ => ByteArray.empty  -- File/stream responses return empty in test
    (resultRef.set (some ⟨resp.status, resp.headers, body⟩) : IO _)
    return ResponseReceived.done).run token
  match ← resultRef.get with
  | some r => return r
  | none => throw (IO.Error.userError "Application did not call respond")

/-- Convenience: GET request. -/
def get (app : Application) (path : String) : IO SResponse :=
  runSession app { path }

/-- Convenience: POST request with body. -/
def post (app : Application) (path : String) (body : ByteArray)
    (contentType : String := "application/octet-stream") : IO SResponse :=
  let hdrs : RequestHeaders := [(hContentType, contentType)]
  runSession app { method := .standard .POST, path := path, body := body, headers := hdrs }

end Network.Wai.Test
