/-
  Network.Wai.Middleware.CleanPath — Normalize URL paths

  Removes double slashes and trailing slashes from request paths,
  redirecting to the canonical form.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Remove duplicate slashes and optionally trailing slashes from paths.
    Redirects to the clean path with 301 if needed.
    $$\text{cleanPath} : \text{Middleware}$$ -/
def cleanPath : Middleware :=
  fun app req respond =>
    let path := req.rawPathInfo
    let cleaned := cleanPathStr path
    if cleaned != path && !path.isEmpty then
      let url := cleaned ++ req.rawQueryString
      AppM.respond respond (.responseBuilder status301 [(hLocation, url)] ByteArray.empty)
    else
      app req respond
where
  cleanPathStr (s : String) : String :=
    let parts := s.splitOn "/"
    let nonEmpty := parts.filter (!·.isEmpty)
    "/" ++ "/".intercalate nonEmpty

end Network.Wai.Middleware
