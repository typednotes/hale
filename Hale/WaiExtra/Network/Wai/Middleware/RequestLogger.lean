/-
  Network.Wai.Middleware.RequestLogger — HTTP request logging

  Logs HTTP requests to a configurable destination (stdout, file, etc.)
  in Apache Combined Log Format or a developer-friendly format.
-/
import Hale.WAI
import Hale.HttpTypes
import Hale.FastLogger
import Hale.AnsiTerminal

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Log output format. -/
inductive OutputFormat where
  | apache    -- Apache Combined Log Format
  | dev       -- Colorized developer-friendly format
deriving BEq

/-- Request logger settings. -/
structure RequestLoggerSettings where
  outputFormat : OutputFormat := .dev
  destination : System.Log.FastLogger.LogType := .stdout

/-- Format a request in Apache Combined Log Format.
    "host - - [date] \"method path version\" status size" -/
private def formatApache (req : Request) (status : Status) : String :=
  let method := toString req.requestMethod
  let path := req.rawPathInfo ++ req.rawQueryString
  let version := s!"HTTP/{req.httpVersion.major}.{req.httpVersion.minor}"
  let host := req.remoteHost.host
  let code := status.statusCode
  s!"{host} - - \"{method} {path} {version}\" {code}\n"

/-- Format a request in developer-friendly format with colors. -/
private def formatDev (req : Request) (status : Status) : String :=
  let method := toString req.requestMethod
  let path := req.rawPathInfo ++ req.rawQueryString
  let code := status.statusCode
  let color := if code < 300 then System.Console.ANSI.Color.green
    else if code < 400 then System.Console.ANSI.Color.cyan
    else if code < 500 then System.Console.ANSI.Color.yellow
    else System.Console.ANSI.Color.red
  let statusStr := System.Console.ANSI.colored color (toString code)
  s!"{method} {path} {statusStr}\n"

/-- Request logging middleware.
    Logs each request after the response is sent.
    $$\text{logRequests} : \text{RequestLoggerSettings} \to \text{IO Middleware}$$ -/
def logRequests (settings : RequestLoggerSettings := {}) : IO Middleware := do
  let logger ← System.Log.FastLogger.newLoggerSet settings.destination
  return fun app req respond =>
    app req fun resp => do
      let fmt := match settings.outputFormat with
        | .apache => formatApache req resp.status
        | .dev => formatDev req resp.status
      System.Log.FastLogger.pushLogStr logger fmt
      respond resp

/-- Convenience: simple stdout logger with dev format. -/
def logStdoutDev : IO Middleware :=
  logRequests { outputFormat := .dev, destination := .stdout }

end Network.Wai.Middleware
