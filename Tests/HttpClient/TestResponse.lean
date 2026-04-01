/-
  Tests.HttpClient.TestResponse — Tests for HTTP response parsing

  ## Coverage
  - Tested here: parseStatusLine (valid, various versions, error cases)
  - Not yet covered: full response parsing (requires mock Connection)
-/

import Tests.Harness
import Hale.HttpClient

namespace TestResponse

open Tests
open Network.HTTP.Client
open Network.HTTP.Types

def tests : IO (List TestResult) := do
  -- Parse a standard status line
  let (ver, st) ← parseStatusLine "HTTP/1.1 200 OK"
  let t1 := check "parse status 200" (st.statusCode == 200)
  let t2 := checkEq "parse version major" 1 ver.major
  let t3 := checkEq "parse version minor" 1 ver.minor
  let t4 := checkEq "parse reason phrase" "OK" st.statusMessage

  -- Parse status 404
  let (_, st404) ← parseStatusLine "HTTP/1.1 404 Not Found"
  let t5 := check "parse status 404" (st404.statusCode == 404)
  let t6 := checkEq "parse 404 reason" "Not Found" st404.statusMessage

  -- Parse HTTP/1.0
  let (ver10, _) ← parseStatusLine "HTTP/1.0 301 Moved Permanently"
  let t7 := checkEq "HTTP/1.0 minor" 0 ver10.minor

  -- Malformed status line should throw
  let t8 ← do
    try
      let _ ← parseStatusLine "GARBAGE"
      pure (check "malformed throws" false "should have thrown")
    catch _ =>
      pure (check "malformed throws" true)

  -- Status code out of range
  let t9 ← do
    try
      let _ ← parseStatusLine "HTTP/1.1 99 Too Low"
      pure (check "status < 100 throws" false "should have thrown")
    catch _ =>
      pure (check "status < 100 throws" true)

  return [t1, t2, t3, t4, t5, t6, t7, t8, t9]

end TestResponse
