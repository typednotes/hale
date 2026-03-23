/-
  Network.Wai.Middleware.Jsonp — JSONP (JSON with Padding) middleware

  Wraps JSON responses in a callback function for cross-origin requests.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- JSONP middleware: if `callback` query parameter is present and the response
    Content-Type is `application/json`, wraps the response body in the callback.
    $$\text{jsonp} : \text{Middleware}$$ -/
def jsonp : Middleware :=
  fun app req respond =>
    let callbackOpt := req.queryString.find? (fun (k, _) => k == "callback")
      |>.bind (·.2)
    match callbackOpt with
    | none => app req respond
    | some cb =>
      app req fun resp =>
        let ct := resp.headers.find? (fun (n, _) => n == hContentType)
          |>.map (·.2)
        if ct == some "application/json" then
          match resp with
          | .responseBuilder status headers body =>
            let wrapped := cb.toUTF8 ++ "(".toUTF8 ++ body ++ ")".toUTF8
            let headers' := headers.map fun (n, v) =>
              if n == hContentType then (n, "application/javascript")
              else (n, v)
            respond (.responseBuilder status headers' wrapped)
          | other => respond other
        else
          respond resp

end Network.Wai.Middleware
