/-
  Hale.HttpClient.Network.HTTP.Client.Response — HTTP/1.1 response parsing

  Parses HTTP/1.1 responses from a `Connection`:
  - Status line: "HTTP/1.1 200 OK\r\n"
  - Headers: "Name: value\r\n" until blank line "\r\n"
  - Body: Content-Length, chunked Transfer-Encoding, or read-until-close
-/

import Hale.HttpClient.Network.HTTP.Client.Types
import Hale.HttpClient.Network.HTTP.Client.Request

namespace Network.HTTP.Client

open Network.HTTP.Types
open Data

-- ── ByteArray-level line reading ──

/-- The CRLF bytes: 0x0D 0x0A. -/
private def crlfBytes : ByteArray :=
  ByteArray.empty.push 0x0D |>.push 0x0A

/-- Find the index of CRLF (\r\n) in a ByteArray starting from `start`. -/
private def findCRLF (buf : ByteArray) (start : Nat := 0) : Option Nat :=
  let rec go (i : Nat) : Option Nat :=
    if i + 1 ≥ buf.size then none
    else if buf.get! i == 0x0D && buf.get! (i + 1) == 0x0A then some i
    else go (i + 1)
  if start + 1 ≥ buf.size then none
  else go start

/-- Read bytes from a connection until we have a full line (ending with \r\n).
    Returns the line bytes (without CRLF) and the leftover bytes after it. -/
private partial def readLine (conn : Connection) (buf : ByteArray := ByteArray.empty)
    : IO (ByteArray × ByteArray) := do
  match findCRLF buf with
  | some idx =>
    let line := buf.extract 0 idx
    let rest := buf.extract (idx + 2) buf.size
    return (line, rest)
  | none =>
    let chunk ← conn.connRead 4096
    if chunk.isEmpty then
      return (buf, ByteArray.empty)
    readLine conn (buf ++ chunk)

/-- Convert a ByteArray line to a String. -/
private def lineToString (line : ByteArray) : String :=
  String.fromUTF8! line

/-- Parse a status line: "HTTP/x.y code reason".
    Returns (HttpVersion, Status) or throws on malformed input. -/
def parseStatusLine (line : String) : IO (HttpVersion × Status) := do
  let parts := line.splitOn " "
  match parts with
  | versionStr :: codeStr :: rest =>
    let version ← if versionStr.startsWith "HTTP/" then
      let verStr := (versionStr.drop 5).toString
      let verParts := verStr.splitOn "."
      match verParts with
      | [maj, min] =>
        match (maj.toNat?, min.toNat?) with
        | (some major, some minor) => pure { major, minor : HttpVersion }
        | _ => throw (IO.Error.userError s!"Invalid HTTP version: {versionStr}")
      | _ => throw (IO.Error.userError s!"Invalid HTTP version: {versionStr}")
    else throw (IO.Error.userError s!"Expected HTTP version, got: {versionStr}")
    let code ← match codeStr.toNat? with
      | some n => pure n
      | none => throw (IO.Error.userError s!"Invalid status code: {codeStr}")
    let reason := " ".intercalate rest
    if h : 100 ≤ code ∧ code ≤ 999 then
      let status : Status := ⟨code, reason, h⟩
      return (version, status)
    else
      throw (IO.Error.userError s!"Status code out of range: {code}")
  | _ => throw (IO.Error.userError s!"Malformed status line: {line}")

/-- Find the first index of a character in a string. -/
private def findCharIdx (s : String) (c : Char) : Option Nat := do
  let chars := s.toList
  let rec go (i : Nat) (rest : List Char) : Option Nat :=
    match rest with
    | [] => none
    | x :: xs => if x == c then some i else go (i + 1) xs
  go 0 chars

/-- Parse headers from the connection until a blank line. -/
private partial def parseHeaders (conn : Connection) (buf : ByteArray)
    (acc : ResponseHeaders := []) : IO (ResponseHeaders × ByteArray) := do
  let (lineBytes, rest) ← readLine conn buf
  if lineBytes.isEmpty then
    return (acc.reverse, rest)
  else
    let line := lineToString lineBytes
    -- Parse "Name: value" or "Name:value"
    match findCharIdx line ':' with
    | some colonIdx =>
      let name := (String.take line colonIdx).toString
      let rawValue := (String.drop line (colonIdx + 1)).toString
      -- Trim leading whitespace from value
      let value := (String.trimAsciiStart rawValue).toString
      let header : Header := (CI.mk' name, value)
      parseHeaders conn rest (header :: acc)
    | none =>
      -- Skip malformed header
      parseHeaders conn rest acc

/-- Read exactly `n` bytes from a connection. -/
private partial def readExactly (conn : Connection) (n : Nat) (buf : ByteArray := ByteArray.empty)
    : IO ByteArray := do
  if buf.size ≥ n then
    return buf.extract 0 n
  let chunk ← conn.connRead (n - buf.size)
  if chunk.isEmpty then return buf
  readExactly conn n (buf ++ chunk)

/-- Read all remaining bytes until EOF. -/
private partial def readUntilClose (conn : Connection) (buf : ByteArray := ByteArray.empty)
    : IO ByteArray := do
  let chunk ← conn.connRead 8192
  if chunk.isEmpty then return buf
  readUntilClose conn (buf ++ chunk)

/-- Parse a hexadecimal string to Nat. -/
private def hexToNat (s : String) : Option Nat := Id.run do
  let mut result := 0
  for c in s.toLower.toList do
    if '0' ≤ c && c ≤ '9' then
      result := result * 16 + (c.toNat - '0'.toNat)
    else if 'a' ≤ c && c ≤ 'f' then
      result := result * 16 + (c.toNat - 'a'.toNat + 10)
    else
      return none
  return some result

/-- Parse chunked transfer encoding body. -/
private partial def readChunkedBody (conn : Connection) (buf : ByteArray)
    (acc : ByteArray := ByteArray.empty) : IO ByteArray := do
  let (sizeLineBytes, rest) ← readLine conn buf
  let sizeLine := lineToString sizeLineBytes
  let sizeStr := (sizeLine.splitOn ";").head!
  let sizeStr := String.trimAscii sizeStr |>.toString
  let size ← match hexToNat sizeStr with
    | some n => pure n
    | none => throw (IO.Error.userError s!"Invalid chunk size: {sizeStr}")
  if size == 0 then
    let (_, _) ← readLine conn rest
    return acc
  let needed := size + 2
  let data ← readExactly conn needed rest
  let chunkData := data.extract 0 size
  let remaining := data.extract (size + 2) data.size
  readChunkedBody conn remaining (acc ++ chunkData)

/-- Look up a header value (case-insensitive). -/
private def findHeader' (headers : ResponseHeaders) (name : HeaderName) : Option String :=
  headers.find? (fun (n, _) => n == name) |>.map Prod.snd

/-- Receive and parse a complete HTTP/1.1 response from a connection.

    Handles three body-reading strategies:
    1. **Content-Length**: read exactly that many bytes
    2. **Transfer-Encoding: chunked**: decode chunked encoding
    3. **Neither**: read until connection close

    $$\text{receiveResponse} : \text{Connection} \to \text{IO Response}$$ -/
def receiveResponse (conn : Connection) : IO Response := do
  let (statusLineBytes, buf) ← readLine conn
  let statusLineStr := lineToString statusLineBytes
  let (version, status) ← parseStatusLine statusLineStr
  let (headers, bodyBuf) ← parseHeaders conn buf
  let body ← match findHeader' headers hContentLength with
    | some lenStr =>
      match lenStr.toNat? with
      | some len => readExactly conn len bodyBuf
      | none => throw (IO.Error.userError s!"Invalid Content-Length: {lenStr}")
    | none =>
      let te := findHeader' headers hTransferEncoding
      if te == some "chunked" then
        readChunkedBody conn bodyBuf
      else
        readUntilClose conn bodyBuf
  return { statusCode := status, headers, body, httpVersion := version }

/-- Perform an HTTP request on a connection: send request, receive response.
    $$\text{performRequest} : \text{Connection} \to \text{Request} \to \text{IO Response}$$ -/
def performRequest (conn : Connection) (req : Request) : IO Response := do
  sendRequest conn req
  receiveResponse conn

end Network.HTTP.Client
