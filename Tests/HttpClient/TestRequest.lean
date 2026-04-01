/-
  Tests.HttpClient.TestRequest — Tests for HTTP request serialization

  ## Coverage
  - Proofs in source: (none yet)
  - Tested here: serializeRequest, Host header auto-add, Content-Length auto-add,
    method rendering, path rendering
  - Not yet covered: serializeRequest_has_host proof, serializeRequest_content_length proof
-/

import Tests.Harness
import Hale.HttpClient

namespace TestRequest

open Tests
open Network.HTTP.Client
open Network.HTTP.Types

/-- Helper to check if a string contains a substring. -/
private def contains (haystack : String) (needle : String) : Bool :=
  let hChars := haystack.toList
  let nChars := needle.toList
  let nLen := nChars.length
  let rec go (i : Nat) (rest : List Char) : Bool :=
    match rest with
    | [] => nLen == 0
    | _ :: xs =>
      if rest.take nLen == nChars then true
      else go (i + 1) xs
  go 0 hChars

def tests : List TestResult :=
  let getReq : Request :=
    { method := .standard .GET
    , host := "example.com"
    , port := 80
    , path := "/api/v1/users"
    , queryString := "?page=1" }
  let getBytes := serializeRequest getReq
  let getStr := String.fromUTF8! getBytes

  let postReq : Request :=
    { method := .standard .POST
    , host := "api.example.com"
    , port := 443
    , path := "/submit"
    , body := some "hello=world".toUTF8
    , isSecure := true
    , headers := [(hContentType, "application/x-www-form-urlencoded")] }
  let postBytes := serializeRequest postReq
  let postStr := String.fromUTF8! postBytes

  [ -- GET request line
    check "GET request line" (contains getStr "GET /api/v1/users?page=1 HTTP/1.1\r\n")
  , -- Host header auto-added
    check "GET has Host header" (contains getStr "Host: example.com\r\n")
  , -- No Content-Length for bodyless request
    check "GET no Content-Length" (!contains getStr "Content-Length:")
  , -- Connection: close
    check "GET has Connection: close" (contains getStr "Connection: close\r\n")
  , -- Blank line (headers end)
    check "GET has blank line" (contains getStr "\r\n\r\n")

  -- POST tests
  , check "POST request line" (contains postStr "POST /submit HTTP/1.1\r\n")
  , check "POST has Host header" (contains postStr "Host: api.example.com\r\n")
  , check "POST has Content-Length" (contains postStr "Content-Length: 11\r\n")
  , check "POST has Content-Type" (contains postStr "Content-Type: application/x-www-form-urlencoded\r\n")
  , check "POST body present" (contains postStr "hello=world")

  -- Non-standard port in Host header
  , let req8080 : Request :=
      { method := .standard .GET, host := "localhost", port := 8080, path := "/" }
    let str := String.fromUTF8! (serializeRequest req8080)
    check "Non-standard port in Host" (contains str "Host: localhost:8080\r\n")

  -- Standard HTTPS port (443) omitted from Host
  , let req443 : Request :=
      { method := .standard .GET, host := "secure.example.com", port := 443, path := "/", isSecure := true }
    let str := String.fromUTF8! (serializeRequest req443)
    check "Standard HTTPS port omitted" (contains str "Host: secure.example.com\r\n")
  ]

end TestRequest
