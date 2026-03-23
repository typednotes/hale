/-
  Network.Wai.Middleware.RequestLogger.JSON — JSON request logging
-/
import Hale.WAI
import Hale.HttpTypes
import Hale.FastLogger

namespace Network.Wai.Middleware.RequestLogger

open Network.Wai
open Network.HTTP.Types

/-- Format a request as a JSON log line.
    Uses Lean's native Json type for structured output. -/
def formatJSON (req : Request) (status : Status) : String :=
  let method := toString req.requestMethod
  let path := req.rawPathInfo ++ req.rawQueryString
  let host := req.remoteHost.host
  let code := status.statusCode
  let ua := req.requestHeaderUserAgent.getD ""
  -- Manual JSON construction (avoiding Lean.Json import overhead)
  s!"\{\"method\":\"{method}\",\"path\":\"{path}\",\"status\":{code},\"host\":\"{host}\",\"userAgent\":\"{ua}\"}"

/-- JSON logging middleware.
    $$\text{logJSON} : \text{IO Middleware}$$ -/
def logJSON : IO Middleware := do
  let logger ← System.Log.FastLogger.newLoggerSet .stdout
  return fun app req respond => do
    app req fun resp => do
      let line := formatJSON req resp.status
      System.Log.FastLogger.pushLogStr logger (line ++ "\n")
      respond resp

end Network.Wai.Middleware.RequestLogger
