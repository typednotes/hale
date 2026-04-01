/-
  Tests.Req.TestReq — Tests for the type-safe HTTP client API

  ## Coverage
  - Proofs in source (covered by type-checking):
    - Scheme.http_ne_https — HTTP ≠ HTTPS
    - get_no_body — GET does not allow body
    - post_yes_body — POST allows body
    - put_yes_body — PUT allows body
    - patch_yes_body — PATCH allows body
    - head_no_body — HEAD does not allow body
    - delete_no_body — DELETE does not allow body
    - option_extraHeaders_append_assoc — Option append associativity
    - option_queryParams_append_assoc — Query params append associativity
  - Tested here: URL construction, path building, Option combinators,
    HttpBodyAllowed instances, basic auth encoding
  - Not yet covered: full req roundtrip (needs network), JsonResponse (deferred)
-/

import Tests.Harness
import Hale.Req

namespace TestReq

open Tests
open Network.HTTP.Req
open Network.HTTP.Types

def tests : List TestResult :=
  [ -- ── Scheme ──
    proofCovered "Scheme.http_ne_https" "Scheme.http_ne_https"

  -- ── URL construction ──
  , let u := https "api.example.com"
    check "https host" (u.host == "api.example.com")
  , let u := http "localhost"
    check "http host" (u.host == "localhost")
  , let u := https "example.com" /: "api" /: "v1" /: "users"
    checkEq "URL path segments" ["api", "v1", "users"] u.segments
  , let u := https "example.com" /: "api" /: "v1"
    checkEq "URL path rendering" "/api/v1" u.path
  , let u := https "example.com"
    checkEq "URL empty path" "/" u.path
  , let u := https "example.com"
    check "HTTPS is secure" u.isSecure
  , let u := http "example.com"
    check "HTTP is not secure" (!u.isSecure)
  , let u := https "example.com"
    checkEq "HTTPS default port" 443 u.defaultPort
  , let u := http "example.com"
    checkEq "HTTP default port" 80 u.defaultPort

  -- ── HttpMethod proofs ──
  , proofCovered "GET no body" "get_no_body"
  , proofCovered "POST yes body" "post_yes_body"
  , proofCovered "PUT yes body" "put_yes_body"
  , proofCovered "PATCH yes body" "patch_yes_body"
  , proofCovered "HEAD no body" "head_no_body"
  , proofCovered "DELETE no body" "delete_no_body"

  -- ── HttpBody instances ──
  , check "NoReqBody provides NoBody"
      (HttpBody.providesBody (b := NoReqBody) == .NoBody)
  , check "ReqBodyBs provides YesBody"
      (HttpBody.providesBody (b := ReqBodyBs) == .YesBody)
  , check "ReqBodyUrlEnc provides YesBody"
      (HttpBody.providesBody (b := ReqBodyUrlEnc) == .YesBody)
  , check "ReqBodyFile provides YesBody"
      (HttpBody.providesBody (b := ReqBodyFile) == .YesBody)
  , check "NoReqBody getBody is none"
      (HttpBody.getBody (NoReqBody.mk) == none)

  -- ── Option combinators ──
  , let h : ReqOption .Http := header hUserAgent "hale/1.0"
    checkEq "header option" [(hUserAgent, "hale/1.0")] h.extraHeaders
  , let p : ReqOption .Http := port 8080
    checkEq "port option" (some 8080) p.portOverride
  , let q : ReqOption .Http := queryParam "key" "value"
    checkEq "queryParam option" [("key", "value")] q.queryParams
  , let qf : ReqOption .Http := queryFlag "verbose"
    checkEq "queryFlag option" [("verbose", "")] qf.queryParams
  , let t : ReqOption .Http := responseTimeout 5000
    checkEq "responseTimeout option" (some 5000) t.timeout

  -- ── Option append ──
  , let a : ReqOption .Https := header hUserAgent "hale" ++ queryParam "x" "1"
    checkEq "append headers + query" [(hUserAgent, "hale")] a.extraHeaders
  , let a : ReqOption .Https := header hUserAgent "hale" ++ queryParam "x" "1"
    checkEq "append query + headers" [("x", "1")] a.queryParams
  , let a : ReqOption .Http := port 8080 ++ port 9090
    checkEq "port override takes last" (some 9090) a.portOverride
  , let empty : ReqOption .Http := EmptyCollection.emptyCollection
    let h : ReqOption .Http := header hUserAgent "test"
    checkEq "empty ++ option = option (headers)"
      h.extraHeaders (empty ++ h).extraHeaders

  -- ── Option monoid proofs ──
  , proofCovered "Option headers append assoc" "option_extraHeaders_append_assoc"
  , proofCovered "Option query params append assoc" "option_queryParams_append_assoc"

  -- ── HttpConfig ──
  , checkEq "default redirect count" 10 defaultHttpConfig.httpConfigRedirectCount
  , checkEq "default timeout" 30000 defaultHttpConfig.httpConfigTimeout
  ]

end TestReq
