/-
  Network.Wai.UrlMap — URL-based application routing

  Route requests to different WAI applications based on path prefixes.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai

open Network.HTTP.Types

/-- Route requests to different applications based on path prefix.
    The first matching prefix wins. Strips the matched prefix from pathInfo.
    $$\text{urlMap} : \text{List (String × Application)} \to \text{Application}$$ -/
def urlMap (routes : List (String × Application)) : Middleware :=
  fun fallback req respond =>
    let path := req.rawPathInfo
    match routes.find? (fun (pathPrefix, _) => path.startsWith pathPrefix) with
    | some (pathPrefix, app) =>
      let newPath := (path.drop pathPrefix.length).toString
      let newPath := if newPath.isEmpty then "/" else newPath
      let segments := newPath.splitOn "/" |>.filter (!·.isEmpty)
      app { req with rawPathInfo := newPath, pathInfo := segments } respond
    | none => fallback req respond

end Network.Wai
