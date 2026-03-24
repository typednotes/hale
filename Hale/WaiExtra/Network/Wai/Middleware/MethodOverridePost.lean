/-
  Network.Wai.Middleware.MethodOverridePost — Override method from POST body

  For POST requests, reads the _method parameter from the URL-encoded body.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Override the request method for POST requests if the `_method` parameter
    is found in the URL-encoded request body.
    Note: This consumes the request body to find the parameter.
    $$\text{methodOverridePost} : \text{Middleware}$$ -/
def methodOverridePost : Middleware :=
  fun app req respond =>
    if req.requestMethod == .standard .POST then
      AppM.ioThen (do
        -- Read first chunk to check for _method
        let chunk ← req.requestBody
        let bodyStr := String.fromUTF8! chunk
        let params := parseSimpleQuery bodyStr
        let returned ← IO.mkRef false
        let newBody : IO ByteArray := do
          let done ← returned.get
          if done then req.requestBody
          else
            returned.set true
            return chunk
        match params.find? (fun (k, _) => k == "_method") with
        | some (_, v) =>
          pure { req with requestMethod := parseMethod v, requestBody := newBody }
        | none =>
          pure { req with requestBody := newBody })
        fun req' => app req' respond
    else
      app req respond
where
  parseSimpleQuery (s : String) : List (String × String) :=
    let pairs := s.splitOn "&"
    pairs.filterMap fun pair =>
      match pair.splitOn "=" with
      | [k, v] => some (k, v)
      | _ => none

end Network.Wai.Middleware
