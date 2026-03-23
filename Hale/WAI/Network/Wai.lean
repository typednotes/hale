/-
  Hale.WAI.Network.Wai — Web Application Interface

  Public API for WAI. Re-exports core types and provides convenience functions.

  ## Design

  Mirrors Haskell's `Network.Wai`. The overriding design principles are
  performance and generality. Uses a streaming interface for request and
  response bodies paired with ByteArray.

  ## Guarantees

  - `ResponseReceived` token ensures the response callback was invoked
  - `Application` CPS type enables safe resource management via bracket
  - `Middleware` composition is associative
  - Request body reading is streaming and non-idempotent (each chunk consumed once)
-/

import Hale.WAI.Network.Wai.Internal

namespace Network.Wai

open Network.HTTP.Types

-- ================================================================
-- Response constructors
-- ================================================================

/-- Create a simple response from a status, headers, and body ByteArray.
    $$\text{responseLBS} : \text{Status} \to \text{ResponseHeaders} \to \text{String} \to \text{Response}$$
    @since 0.3.0 -/
def responseLBS (status : Status)
    (headers : ResponseHeaders) (body : String) : Response :=
  .responseBuilder status headers body.toUTF8

/-- Create a file response.
    @since 2.0.0 -/
def responseFile' (status : Status)
    (headers : ResponseHeaders)
    (path : String) (part : Option Network.Sendfile.FilePart := none) : Response :=
  .responseFile status headers path part

/-- Create a streaming response.
    @since 3.0.0 -/
def responseStream' (status : Status)
    (headers : ResponseHeaders)
    (body : StreamingBody) : Response :=
  .responseStream status headers body

-- ================================================================
-- Request accessors
-- ================================================================

/-- Get the next chunk of the request body. Returns empty ByteArray when
    the body is fully consumed. Preferred over direct `requestBody` access.
    $$\text{getRequestBodyChunk} : \text{Request} \to \text{IO}(\text{ByteArray})$$
    @since 3.2.2 -/
@[inline] def getRequestBodyChunk (req : Request) : IO ByteArray :=
  req.requestBody

/-- Set the request body chunks IO action on a request.
    The supplied IO action should return the next chunk each time it is called
    and empty ByteArray when fully consumed.
    $$\text{setRequestBodyChunks} : \text{IO}(\text{ByteArray}) \to \text{Request} \to \text{Request}$$
    @since 3.2.4 -/
def setRequestBodyChunks (body : IO ByteArray) (req : Request) : Request :=
  { req with requestBody := body }

/-- Get a header value from a request by name. -/
def requestHeader (name : HeaderName)
    (req : Request) : Option String :=
  req.requestHeaders.find? (fun (n, _) => n == name) |>.map (·.2)

/-- Read the entire request body strictly into memory.
    Returns all chunks concatenated as a single ByteArray.

    **Warning:** This consumes the request body. Future calls return empty.
    Consider using `getRequestBodyChunk` for streaming when possible.
    $$\text{strictRequestBody} : \text{Request} \to \text{IO}(\text{ByteArray})$$
    @since 3.0.1 -/
partial def strictRequestBody (req : Request) : IO ByteArray := do
  let mut chunks : Array ByteArray := #[]
  let mut done := false
  while !done do
    let chunk ← getRequestBodyChunk req
    if chunk.isEmpty then
      done := true
    else
      chunks := chunks.push chunk
  -- Concatenate all chunks
  let mut result := ByteArray.empty
  for chunk in chunks do
    result := result ++ chunk
  return result

/-- Synonym for `strictRequestBody`.
    Name signals the non-idempotent (consuming) nature.
    @since 3.2.3 -/
abbrev consumeRequestBodyStrict := @strictRequestBody

/-- A default, blank request.
    @since 2.0.0 -/
def defaultRequest : Request where
  requestMethod := .standard .GET
  httpVersion := http10
  rawPathInfo := ""
  rawQueryString := ""
  requestHeaders := []
  isSecure := false
  remoteHost := ⟨"0.0.0.0", 0⟩
  pathInfo := []
  queryString := []
  requestBody := pure ByteArray.empty
  vault := Data.Vault.empty
  requestBodyLength := .knownLength 0
  requestHeaderHost := none
  requestHeaderRange := none
  requestHeaderReferer := none
  requestHeaderUserAgent := none

-- ================================================================
-- Request modifiers
-- ================================================================

/-- Apply the provided function to the request header list.
    $$\text{mapRequestHeaders} : (H \to H) \to \text{Request} \to \text{Request}$$
    @since 3.2.4 -/
def mapRequestHeaders (f : RequestHeaders → RequestHeaders)
    (req : Request) : Request :=
  { req with requestHeaders := f req.requestHeaders }

-- ================================================================
-- Middleware
-- ================================================================

/-- The identity middleware (does nothing). -/
def idMiddleware : Middleware := id

/-- Compose two middlewares.
    $$\text{composeMiddleware}(f, g) = f \circ g$$ -/
@[inline] def composeMiddleware (f g : Middleware) : Middleware := f ∘ g

/-- Add a header to the response. -/
def addHeader (name : HeaderName) (val : String)
    (resp : Response) : Response :=
  resp.mapResponseHeaders ((name, val) :: ·)

/-- Apply a function that modifies a request as a Middleware.
    $$\text{modifyRequest} : (\text{Request} \to \text{Request}) \to \text{Middleware}$$
    @since 3.2.4 -/
def modifyRequest (f : Request → Request) : Middleware :=
  fun app req respond => app (f req) respond

/-- Apply a function that modifies a response as a Middleware.
    $$\text{modifyResponse} : (\text{Response} \to \text{Response}) \to \text{Middleware}$$
    @since 3.0.3.0 -/
def modifyResponse (f : Response → Response) : Middleware :=
  fun app req respond => app req (respond ∘ f)

/-- Conditionally apply a Middleware based on a request predicate.
    $$\text{ifRequest}(p, m) = \begin{cases} m & \text{if } p(\text{req}) \\ \text{id} & \text{otherwise} \end{cases}$$
    @since 3.0.3.0 -/
def ifRequest (pred : Request → Bool) (middle : Middleware) : Middleware :=
  fun app req respond =>
    if pred req then middle app req respond
    else app req respond

end Network.Wai
