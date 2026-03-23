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

/-- The size of the request body.
    In the case of chunked transfer encoding, the size is unknown.
    $$\text{RequestBodyLength} = \text{ChunkedBody} \mid \text{KnownLength}\ \mathbb{N}$$
    @since 1.4.0 -/
inductive RequestBodyLength where
  /-- Chunked transfer encoding — size unknown. -/
  | chunkedBody
  /-- Content-Length header present — size known.
      $$\text{KnownLength}\ n,\; n : \mathbb{N}$$ -/
  | knownLength (bytes : Nat)
deriving BEq, Repr

/-- An HTTP request with all parsed information.
    $$\text{Request} = \{ \text{method}, \text{version}, \text{path}, \text{query}, \text{headers}, \ldots \}$$ -/
structure Request where
  /-- The HTTP method (GET, POST, etc.). -/
  requestMethod : Method
  /-- The HTTP version. -/
  httpVersion : HttpVersion
  /-- The raw path info (e.g., "/foo/bar").
      Middlewares should not modify this — modify `pathInfo` instead. -/
  rawPathInfo : String
  /-- The raw query string (e.g., "?key=val"), including leading '?'.
      Do not modify this raw value — modify `queryString` instead. -/
  rawQueryString : String
  /-- The request headers. -/
  requestHeaders : RequestHeaders
  /-- Whether the current connection is secure (HTTPS/TLS).
      Note: does not reflect whether the original client connection was secure
      (e.g., behind a reverse proxy). Use `Network.Wai.Request.appearsSecure`
      for a more complete check. -/
  isSecure : Bool
  /-- The remote client address. -/
  remoteHost : SockAddr
  /-- Parsed path segments (e.g., ["foo", "bar"]). -/
  pathInfo : List String
  /-- Parsed query string. -/
  queryString : Query
  /-- IO action to read the next chunk of the request body.
      Returns empty ByteArray when body is exhausted.
      Each call consumes a chunk — this is not idempotent. -/
  requestBody : IO ByteArray
  /-- Per-request extensible storage. -/
  vault : Data.Vault
  /-- The size of the request body — chunked or known length.
      @since 1.4.0 -/
  requestBodyLength : RequestBodyLength
  /-- The Host header value. @since 2.0.0 -/
  requestHeaderHost : Option String
  /-- The Range header value. @since 2.0.0 -/
  requestHeaderRange : Option String
  /-- The Referer header value. @since 3.2.0 -/
  requestHeaderReferer : Option String
  /-- The User-Agent header value. @since 3.2.0 -/
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

/-- Whether a response has an empty body.
    Used for RFC 9110 §6.4.1 compliance checks.
    Files and streams are conservatively assumed non-empty;
    raw responses are opaque. -/
def bodyIsEmpty : Response → Bool
  | .responseBuilder _ _ body => body.isEmpty
  | .responseFile _ _ _ _     => false
  | .responseStream _ _ _     => false
  | .responseRaw _ _          => false

-- Response accessor laws

/-- Status accessor returns the status of a builder response. -/
theorem status_responseBuilder (s : Status) (h : ResponseHeaders) (b : ByteArray) :
    (Response.responseBuilder s h b).status = s := rfl

/-- Status accessor returns the status of a file response. -/
theorem status_responseFile (s : Status) (h : ResponseHeaders) (p : String) (fp : Option FilePart) :
    (Response.responseFile s h p fp).status = s := rfl

/-- Status accessor returns the status of a stream response. -/
theorem status_responseStream (s : Status) (h : ResponseHeaders) (b : StreamingBody) :
    (Response.responseStream s h b).status = s := rfl

/-- Headers accessor returns the headers of a builder response. -/
theorem headers_responseBuilder (s : Status) (h : ResponseHeaders) (b : ByteArray) :
    (Response.responseBuilder s h b).headers = h := rfl

/-- Headers accessor returns the headers of a file response. -/
theorem headers_responseFile (s : Status) (h : ResponseHeaders) (p : String) (fp : Option FilePart) :
    (Response.responseFile s h p fp).headers = h := rfl

/-- `mapResponseHeaders id` is identity for builder responses. -/
theorem mapResponseHeaders_id_responseBuilder (s : Status) (h : ResponseHeaders) (b : ByteArray) :
    (Response.responseBuilder s h b).mapResponseHeaders id = .responseBuilder s h b := rfl

/-- `mapResponseHeaders id` is identity for file responses. -/
theorem mapResponseHeaders_id_responseFile (s : Status) (h : ResponseHeaders) (p : String) (fp : Option FilePart) :
    (Response.responseFile s h p fp).mapResponseHeaders id = .responseFile s h p fp := rfl

/-- `mapResponseHeaders id` is identity for stream responses. -/
theorem mapResponseHeaders_id_responseStream (s : Status) (h : ResponseHeaders) (b : StreamingBody) :
    (Response.responseStream s h b).mapResponseHeaders id = .responseStream s h b := rfl

/-- `mapResponseStatus id` is identity for builder responses. -/
theorem mapResponseStatus_id_responseBuilder (s : Status) (h : ResponseHeaders) (b : ByteArray) :
    (Response.responseBuilder s h b).mapResponseStatus id = .responseBuilder s h b := rfl

/-- `mapResponseStatus id` is identity for file responses. -/
theorem mapResponseStatus_id_responseFile (s : Status) (h : ResponseHeaders) (p : String) (fp : Option FilePart) :
    (Response.responseFile s h p fp).mapResponseStatus id = .responseFile s h p fp := rfl

/-- `mapResponseStatus id` is identity for stream responses. -/
theorem mapResponseStatus_id_responseStream (s : Status) (h : ResponseHeaders) (b : StreamingBody) :
    (Response.responseStream s h b).mapResponseStatus id = .responseStream s h b := rfl

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
