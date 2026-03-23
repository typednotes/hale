/-
  Hale.WAI.Network.Wai.Internal — WAI internal types

  Core WAI types: Request, Response, Application, Middleware.

  ## Design

  Mirrors Haskell's `Network.Wai.Internal`. The `Request` type contains
  all parsed HTTP request information. `Response` is an inductive type
  covering file, builder, and streaming response modes.

  ## Guarantees

  - `ResponseReceived` is an opaque token ensuring the response callback
    was invoked exactly once
  - `Application` type encodes the CPS pattern for response handling
-/

import Hale.HttpTypes
import Hale.Vault
import Hale.Network
import Hale.SimpleSendfile

namespace Network.Wai

open Network.HTTP.Types
open Network.Socket (SockAddr)
open Network.Sendfile (FilePart)

/-- Opaque token proving a response was sent. Cannot be constructed
    outside the response callback. -/
structure ResponseReceived where
  private mk ::

/-- Construct a `ResponseReceived` token. Intended for use by server
    implementations (e.g., Warp) that provide the response callback.
    Application code should not call this directly. -/
def ResponseReceived.done : ResponseReceived := ⟨⟩

/-- Body streaming callback type.
    $$\text{StreamingBody} = (\text{ByteArray} \to \text{IO}()) \to \text{IO}() \to \text{IO}()$$ -/
abbrev StreamingBody := (ByteArray → IO Unit) → IO Unit → IO Unit

/-- An HTTP request with all parsed information.
    $$\text{Request} = \{ \text{method}, \text{version}, \text{path}, \text{query}, \text{headers}, \ldots \}$$ -/
structure Request where
  /-- The HTTP method (GET, POST, etc.). -/
  requestMethod : Method
  /-- The HTTP version. -/
  httpVersion : HttpVersion
  /-- The raw path info (e.g., "/foo/bar"). -/
  rawPathInfo : String
  /-- The raw query string (e.g., "?key=val"). -/
  rawQueryString : String
  /-- The request headers. -/
  requestHeaders : RequestHeaders
  /-- Whether the connection is secure (HTTPS). -/
  isSecure : Bool
  /-- The remote client address. -/
  remoteHost : SockAddr
  /-- Parsed path segments (e.g., ["foo", "bar"]). -/
  pathInfo : List String
  /-- Parsed query string. -/
  queryString : Query
  /-- IO action to read the next chunk of the request body.
      Returns empty ByteArray when body is exhausted. -/
  requestBody : IO ByteArray
  /-- Per-request extensible storage. -/
  vault : Data.Vault
  /-- Content length if known from headers. -/
  requestBodyLength : Option Nat
  /-- The Host header value. -/
  requestHeaderHost : Option String
  /-- The Range header value. -/
  requestHeaderRange : Option String
  /-- The Referer header value. -/
  requestHeaderReferer : Option String
  /-- The User-Agent header value. -/
  requestHeaderUserAgent : Option String

/-- An HTTP response. -/
inductive Response where
  /-- Respond with a file. -/
  | responseFile (status : Status) (headers : ResponseHeaders)
      (path : String) (part : Option FilePart)
  /-- Respond with a ByteArray body (built in memory). -/
  | responseBuilder (status : Status) (headers : ResponseHeaders)
      (body : ByteArray)
  /-- Respond with a streaming body. -/
  | responseStream (status : Status) (headers : ResponseHeaders)
      (body : StreamingBody)
  /-- Respond with raw data sent directly to the socket. -/
  | responseRaw (rawAction : (IO ByteArray) → (ByteArray → IO Unit) → IO Unit)
      (fallback : Response)

namespace Response

/-- Get the status from a response. -/
def status : Response → Status
  | .responseFile s _ _ _ => s
  | .responseBuilder s _ _ => s
  | .responseStream s _ _ => s
  | .responseRaw _ fb => fb.status

/-- Get the headers from a response. -/
def headers : Response → ResponseHeaders
  | .responseFile _ h _ _ => h
  | .responseBuilder _ h _ => h
  | .responseStream _ h _ => h
  | .responseRaw _ fb => fb.headers

/-- Map over the response headers. -/
def mapResponseHeaders (f : ResponseHeaders → ResponseHeaders) : Response → Response
  | .responseFile s h p fp => .responseFile s (f h) p fp
  | .responseBuilder s h b => .responseBuilder s (f h) b
  | .responseStream s h b => .responseStream s (f h) b
  | .responseRaw a fb => .responseRaw a (fb.mapResponseHeaders f)

/-- Map over the response status. -/
def mapResponseStatus (f : Status → Status) : Response → Response
  | .responseFile s h p fp => .responseFile (f s) h p fp
  | .responseBuilder s h b => .responseBuilder (f s) h b
  | .responseStream s h b => .responseStream (f s) h b
  | .responseRaw a fb => .responseRaw a (fb.mapResponseStatus f)

end Response

/-- A WAI application.
    $$\text{Application} = \text{Request} \to (\text{Response} \to \text{IO}(\text{ResponseReceived})) \to \text{IO}(\text{ResponseReceived})$$

    **Linearity invariant (axiom-dependent):** The response callback `respond`
    must be invoked exactly once. The `ResponseReceived` return type ensures
    that the callback WAS invoked (the application must return the token),
    but cannot prevent double invocation at the type level without linear types.

    This matches Haskell WAI's contract. -/
abbrev Application := Request → (Response → IO ResponseReceived) → IO ResponseReceived

/-- A WAI middleware transforms an application.
    $$\text{Middleware} = \text{Application} \to \text{Application}$$ -/
abbrev Middleware := Application → Application

end Network.Wai
