/-
  Tests.Warp.TestWarp — Tests for the Warp HTTP server

  ## Coverage

  ### Tested here (runtime tests)
  - `parseRequestLine`: valid GET, POST with query, malformed input
  - `parseHttpVersion`: HTTP/1.1, HTTP/1.0, invalid
  - `parseHeaders`: single header, multiple headers, empty list
  - `parseHeaderLine`: valid, missing colon, colon in value
  - `renderStatusLine`: HTTP/1.1 200 OK
  - `renderHeaders`: single and multiple headers
  - `defaultSettings`: port, host, server name defaults
  - Loopback integration test: start server, connect, verify HTTP response

  ### Not yet covered
  - `parseRequest` (requires live socket, covered by integration test)
  - `sendResponse` file and streaming modes
  - Chunked transfer encoding
  - Timeout handling
  - Graceful shutdown
-/

import Tests.Harness
import Hale.Warp
import Hale.WAI
import Hale.HttpTypes
import Hale.Network

open Tests
open Network.HTTP.Types
open Network.Wai.Handler.Warp
open Network.Wai
open Network.Socket

namespace TestWarp

/-- Check if `haystack` contains `needle` as a substring. -/
private def strContains (haystack needle : String) : Bool :=
  let h := haystack.toList
  let n := needle.toList
  let nLen := n.length
  if nLen == 0 then true
  else
    let rec go (rem : List Char) : Bool :=
      if rem.length < nLen then false
      else if rem.take nLen == n then true
      else match rem with
        | [] => false
        | _ :: rest => go rest
    go h

-- ── Request parsing tests ──

def testParseRequestLine_GET : TestResult :=
  match parseRequestLine "GET /index.html HTTP/1.1" with
  | some (m, path, query, ver) =>
    check "parseRequestLine GET /index.html"
      (toString m == "GET" && path == "/index.html" && query == "" &&
       ver == http11)
  | none => check "parseRequestLine GET /index.html" false "returned none"

def testParseRequestLine_POST_query : TestResult :=
  match parseRequestLine "POST /api/data?key=val HTTP/1.0" with
  | some (m, path, query, ver) =>
    check "parseRequestLine POST with query"
      (toString m == "POST" && path == "/api/data" && query == "?key=val" &&
       ver == http10)
  | none => check "parseRequestLine POST with query" false "returned none"

def testParseRequestLine_malformed : TestResult :=
  match parseRequestLine "GARBAGE" with
  | none => check "parseRequestLine malformed → none" true
  | some _ => check "parseRequestLine malformed → none" false "should be none"

def testParseRequestLine_empty : TestResult :=
  match parseRequestLine "" with
  | none => check "parseRequestLine empty → none" true
  | some _ => check "parseRequestLine empty → none" false "should be none"

-- ── HTTP version parsing ──

def testParseHttpVersion_11 : TestResult :=
  match parseHttpVersion "HTTP/1.1" with
  | some v => check "parseHttpVersion HTTP/1.1" (v == http11)
  | none => check "parseHttpVersion HTTP/1.1" false "returned none"

def testParseHttpVersion_10 : TestResult :=
  match parseHttpVersion "HTTP/1.0" with
  | some v => check "parseHttpVersion HTTP/1.0" (v == http10)
  | none => check "parseHttpVersion HTTP/1.0" false "returned none"

def testParseHttpVersion_invalid : TestResult :=
  match parseHttpVersion "INVALID" with
  | none => check "parseHttpVersion invalid → none" true
  | some _ => check "parseHttpVersion invalid → none" false "should be none"

-- ── Header parsing tests ──

def testParseHeaders_single : TestResult :=
  let headers := parseHeaders ["Content-Type: text/html"]
  let ok := headers.length == 1 &&
    (match headers.head? with
     | some (n, v) => toString n == "Content-Type" && v == "text/html"
     | none => false)
  check "parseHeaders single" ok

def testParseHeaders_multiple : TestResult :=
  let headers := parseHeaders ["Host: localhost", "Accept: */*"]
  check "parseHeaders multiple" (headers.length == 2)

def testParseHeaders_empty : TestResult :=
  let headers := parseHeaders []
  check "parseHeaders empty" (headers.isEmpty)

def testParseHeaders_colonInValue : TestResult :=
  let headers := parseHeaders ["Location: http://example.com:8080/path"]
  match headers.head? with
  | some (_, v) => check "parseHeaders colon in value" (v == "http://example.com:8080/path")
  | none => check "parseHeaders colon in value" false "no header parsed"

-- ── Response rendering tests ──

def testRenderStatusLine : TestResult :=
  let line := renderStatusLine http11 status200
  checkEq "renderStatusLine 200" "HTTP/1.1 200 OK\r\n" line

def testRenderStatusLine_404 : TestResult :=
  let line := renderStatusLine http11 status404
  checkEq "renderStatusLine 404" "HTTP/1.1 404 Not Found\r\n" line

def testRenderHeaders_single : TestResult :=
  let rendered := renderHeaders [(Data.CI.mk' "Content-Type", "text/plain")]
  checkEq "renderHeaders single" "Content-Type: text/plain\r\n" rendered

def testRenderHeaders_multiple : TestResult :=
  let rendered := renderHeaders
    [(Data.CI.mk' "Content-Type", "text/html"),
     (Data.CI.mk' "Content-Length", "42")]
  checkEq "renderHeaders multiple"
    "Content-Type: text/html\r\nContent-Length: 42\r\n" rendered

-- ── Settings tests ──

def testDefaultSettings_port : TestResult :=
  checkEq "defaultSettings port" 3000 defaultSettings.settingsPort

def testDefaultSettings_host : TestResult :=
  checkEq "defaultSettings host" "0.0.0.0" defaultSettings.settingsHost

def testDefaultSettings_serverName : TestResult :=
  checkEq "defaultSettings serverName" "Hale/Warp" defaultSettings.settingsServerName

def testDefaultSettings_timeout : TestResult :=
  checkEq "defaultSettings timeout" 30 defaultSettings.settingsTimeout

def testDefaultSettings_addDate : TestResult :=
  check "defaultSettings addDateHeader" defaultSettings.settingsAddDateHeader

def testDefaultSettings_addServer : TestResult :=
  check "defaultSettings addServerHeader" defaultSettings.settingsAddServerHeader

-- ── Pure tests list ──

def tests : List TestResult :=
  [ testParseRequestLine_GET
  , testParseRequestLine_POST_query
  , testParseRequestLine_malformed
  , testParseRequestLine_empty
  , testParseHttpVersion_11
  , testParseHttpVersion_10
  , testParseHttpVersion_invalid
  , testParseHeaders_single
  , testParseHeaders_multiple
  , testParseHeaders_empty
  , testParseHeaders_colonInValue
  , testRenderStatusLine
  , testRenderStatusLine_404
  , testRenderHeaders_single
  , testRenderHeaders_multiple
  , testDefaultSettings_port
  , testDefaultSettings_host
  , testDefaultSettings_serverName
  , testDefaultSettings_timeout
  , testDefaultSettings_addDate
  , testDefaultSettings_addServer
  ]

-- ── IO integration test: loopback ──

/-- Start a Warp server on a random high port, connect with a raw socket,
    send a minimal HTTP request, and verify the response. -/
def loopbackTest : IO (List TestResult) := do
  let port : UInt16 := 18923  -- Use a high port unlikely to conflict
  let startedRef ← IO.mkRef false
  let app : Application := fun _req respond =>
    AppM.respond respond (responseLBS status200 [(Data.CI.mk' "X-Test", "yes")] "Hello Warp!")

  -- Start server in background task
  let serverTask ← IO.asTask (prio := .dedicated) do
    let settings : Settings := {
      settingsPort := port
      settingsBeforeMainLoop := startedRef.set true
    }
    try
      runSettings settings app
    catch _ => pure ()

  -- Wait for server to start (poll up to 500ms)
  let mut started := false
  let mut attempts := 0
  while !started && attempts < 50 do
    IO.sleep 10
    started ← startedRef.get
    attempts := attempts + 1

  if !started then
    return [check "loopback: server started" false "server did not start in time"]

  -- Give it a moment to enter accept loop
  IO.sleep 50

  let mut results : List TestResult := []
  try
    -- Connect to the server (fresh → connected state transition)
    let freshSock ← Network.Socket.socket .inet .stream
    let clientSock ← Network.Socket.Blocking.connect freshSock ⟨"127.0.0.1", port⟩
    try
      -- Send a minimal HTTP request
      let reqStr := "GET /hello HTTP/1.1\r\nHost: localhost\r\n\r\n"
      let _ ← Network.Socket.Blocking.send clientSock reqStr.toUTF8
      -- Read the response
      IO.sleep 100  -- Give server time to respond
      let respBytes ← Network.Socket.Blocking.recv clientSock 4096
      let respStr := String.fromUTF8! respBytes

      -- Verify response contains expected parts
      results := results ++ [
        check "loopback: response contains HTTP/1.1" (strContains respStr "HTTP/1.1"),
        check "loopback: response contains 200" (strContains respStr "200"),
        check "loopback: response contains Hello Warp!" (strContains respStr "Hello Warp!"),
        check "loopback: response contains Server header" (strContains respStr "Hale/Warp"),
        check "loopback: response contains X-Test header" (strContains respStr "X-Test: yes")
      ]
    finally
      let _ ← Network.Socket.close clientSock
  catch e =>
    results := [check "loopback: connection" false s!"exception: {e}"]

  -- Cancel the server task (it's blocking in accept)
  IO.cancel serverTask

  return results

/-- IO tests including the loopback integration test. -/
def ioTests : IO (List TestResult) := do
  loopbackTest

end TestWarp
