/-
  Network.Wai.Middleware.Rewrite — URL rewriting middleware

  Rewrite request paths based on custom rules.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- A rewrite rule takes path segments and headers, returns new path segments
    and possibly modified headers. -/
abbrev RewriteRule := List String → RequestHeaders → (List String × RequestHeaders)

/-- Rewrite request paths based on custom rules.
    The rule function receives path segments and headers, and returns
    the rewritten path segments and headers.
    $$\text{rewrite} : \text{RewriteRule} \to \text{Middleware}$$ -/
def rewrite (rule : RewriteRule) : Middleware :=
  fun app req respond =>
    let (newPath, newHeaders) := rule req.pathInfo req.requestHeaders
    let rawPath := "/" ++ "/".intercalate newPath
    let req' := { req with
      pathInfo := newPath
      rawPathInfo := rawPath
      requestHeaders := newHeaders
    }
    app req' respond

/-- Simple path prefix rewrite: strip a prefix and optionally add a new one.
    $$\text{rewritePrefix} : \text{String} \to \text{String} \to \text{Middleware}$$ -/
def rewritePrefix (from_ to_ : String) : Middleware :=
  fun app req respond =>
    let path := req.rawPathInfo
    if path.startsWith from_ then
      let newPath := to_ ++ path.drop from_.length
      let segments := newPath.splitOn "/" |>.filter (!·.isEmpty)
      app { req with rawPathInfo := newPath, pathInfo := segments } respond
    else
      app req respond

end Network.Wai.Middleware
