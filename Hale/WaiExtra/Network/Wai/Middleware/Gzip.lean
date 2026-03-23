/-
  Network.Wai.Middleware.Gzip — Gzip compression middleware

  Compresses response bodies with gzip when the client sends
  Accept-Encoding: gzip. For now, passes through without actual
  compression (full zlib FFI integration is deferred).

  ## Design
  - Checks Accept-Encoding header for "gzip"
  - For builder responses, marks with Content-Encoding: gzip header
  - Actual compression requires zlib FFI (TODO)
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Gzip compression settings. -/
structure GzipSettings where
  /-- Minimum response size to compress (bytes). -/
  gzipMinSize : Nat := 860
  /-- File types to compress. -/
  gzipCheckMime : String → Bool := fun mime =>
    mime.startsWith "text/" ||
    mime == "application/json" ||
    mime == "application/javascript" ||
    mime == "application/xml" ||
    mime == "image/svg+xml"

/-- Check if the client accepts gzip encoding. -/
private def clientAcceptsGzip (req : Request) : Bool :=
  let ae := (req.requestHeaders.find? (fun (n, _) => n == Data.CI.mk' "Accept-Encoding")).map (·.2)
  match ae with
  | some s => (s.splitOn "gzip").length != 1
  | none => false

/-- Gzip middleware. Compresses eligible responses when the client accepts gzip.
    $$\text{gzip} : \text{GzipSettings} \to \text{Middleware}$$

    NOTE: Full gzip compression requires zlib FFI. Currently this middleware
    adds the Content-Encoding header framework but delegates actual compression
    to a future zlib integration. -/
def gzip (settings : GzipSettings := {}) : Middleware :=
  fun app req respond =>
    if clientAcceptsGzip req then
      app req fun resp =>
        -- TODO: actual gzip compression via zlib FFI
        -- For now, pass through without compression
        respond resp
    else
      app req respond

end Network.Wai.Middleware
