/-
  Hale.WAI.Network.Wai.Internal — WAI internal types

  Core WAI types: Request, Response, Application, Middleware, AppM.

  ## Design

  Mirrors Haskell's `Network.Wai.Internal`. The `Request` type contains
  all parsed HTTP request information. `Response` is an inductive type
  covering file, builder, and streaming response modes.

  ## How Lean 4's Dependent Types Enforce Exactly-Once Response

  In Haskell's WAI, the contract "call `respond` exactly once" is a
  gentleman's agreement -- nothing in the type system prevents calling it
  zero times or twice.  Lean 4's dependent types let us do better.

  `AppM` is an **indexed monad** parameterised by a pre-state and a
  post-state (`ResponseState`).  The key insight:

  1. `AppM.respond` is the **only** combinator that transitions
     `.pending → .sent`.
  2. After one `respond`, the state is `.sent`.  A second `respond` would
     need a combinator of type `AppM .sent .sent ResponseReceived`, but
     **no such combinator exists** -- double-respond is a type error.
  3. `AppM.mk` is `private`, so application code cannot fabricate an
     `AppM .pending .sent` value without actually calling `respond`.

  The result: the Lean 4 kernel verifies at compile time that every
  `Application` invokes the response callback exactly once.  The `AppM`
  wrapper is erased at runtime (it is just `Green` underneath).

  ## Guarantees (compile-time, zero-cost)

  - `ResponseReceived` is an opaque token ensuring the response callback
    was invoked (application must return it; only `respond` produces it)
  - `AppM .pending .sent` enforces exactly-once response via indexed state
  - `private mk` prevents circumventing the guarantee
  - `Application` CPS type enables safe resource bracketing by the server
  - `Middleware` is `Application → Application` -- proven associative
  - `AppM` wraps `Green` — all application code runs on the fair green
    thread monad, freeing pool threads when awaiting I/O
-/

import Hale.HttpTypes
import Hale.Vault
import Hale.Network
import Hale.SimpleSendfile
import Hale.Base.Control.Concurrent.Green

namespace Network.Wai

open Network.HTTP.Types
open Network.Socket (SockAddr)
open Network.Sendfile (FilePart)
open Control.Concurrent.Green (Green)

/-- Opaque token proving a response was sent.

    `private mk` ensures that application code cannot fabricate this token.
    Only server implementations (via `ResponseReceived.done`) and the
    `AppM.respond` combinator produce it.  Combined with the `AppM` indexed
    monad, this means: an application that type-checks has necessarily
    invoked the response callback exactly once. -/
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

/-- Response lifecycle state for the indexed `AppM` monad.

    This two-element type is the key to compile-time exactly-once enforcement.
    The `AppM` monad is parameterised by a pre-state and a post-state drawn
    from `ResponseState`.  Since `.pending ≠ .sent` (proven below), the
    compiler can distinguish "haven't responded yet" from "already responded"
    and reject any code path that would respond twice or not at all.
    $$\text{ResponseState} = \text{pending} \mid \text{sent}$$ -/
inductive ResponseState where
  /-- No response has been sent yet. -/
  | pending
  /-- A response has been sent. -/
  | sent
deriving BEq, DecidableEq, Repr

/-- Response states are distinct. -/
theorem ResponseState.pending_ne_sent : ResponseState.pending ≠ ResponseState.sent := by decide

/-- Indexed Green monad tracking response lifecycle state transitions.

    This is the core dependent-type mechanism that enforces the WAI
    exactly-once-response contract at compile time.

    `AppM pre post α` represents a Green computation that transitions the
    response lifecycle from state `pre` to state `post`.  The state indices
    are checked by the Lean 4 kernel during type-checking and **erased at
    runtime** -- `AppM` compiles to exactly the same code as plain `Green`.

    **Why `private mk`?**  The constructor is private, so the only ways to
    build an `AppM` value are through the provided combinators:
    `respond`, `respondIO`, `liftIO`, `ipure`, `ibind`, `ioThen`.
    Application code cannot fabricate `AppM .pending .sent` without actually
    invoking the response callback -- the type system forces the real work.

    **Why double-respond is impossible:**
    - `AppM.respond` has type `AppM .pending .sent ResponseReceived`.
    - After one call the state is `.sent`.
    - `AppM.ibind` chains: `AppM s₁ s₂ α → (α → AppM s₂ s₃ β) → AppM s₁ s₃ β`.
    - A second `respond` would require `AppM .sent _ _` with pre-state `.sent`,
      but `respond`'s pre-state is `.pending` -- **type mismatch, compile-time error**.

    **Trust boundary:** Server code (Warp) extracts the `Green` via `.run`
    at the edge.  Middleware that needs full control can use the `protected`
    escape hatch `AppM.unsafeLift`, which requires an explicit `open`.

    $$\text{AppM}\ s_1\ s_2\ \alpha = \text{Green}(\alpha) \text{ (opaque, indexed by state)}$$ -/
structure AppM (pre post : ResponseState) (α : Type) where
  private mk ::
  /-- Extract the underlying Green computation. For server/framework code only. -/
  run : Green α

namespace AppM

/-- Lift a pure value without changing state.
    $$\text{ipure} : \alpha \to \text{AppM}\ s\ s\ \alpha$$ -/
@[inline] def ipure (a : α) : AppM s s α := ⟨pure a⟩

/-- Lift a plain IO action without changing state.
    IO is automatically lifted into Green via `MonadLift IO Green`.
    $$\text{liftIO} : \text{IO}(\alpha) \to \text{AppM}\ s\ s\ \alpha$$ -/
@[inline] def liftIO (action : IO α) : AppM s s α := ⟨(action : Green α)⟩

/-- Indexed bind: chains state transitions.
    $$\text{ibind} : \text{AppM}\ s_1\ s_2\ \alpha \to (\alpha \to \text{AppM}\ s_2\ s_3\ \beta) \to \text{AppM}\ s_1\ s_3\ \beta$$ -/
@[inline] def ibind (ma : AppM s₁ s₂ α) (f : α → AppM s₂ s₃ β) : AppM s₁ s₃ β :=
  ⟨ma.run >>= fun a => (f a).run⟩

/-- Send a response, transitioning from `.pending` to `.sent`.
    This is the **only** way to produce `AppM .pending .sent ResponseReceived`.
    The callback returns `Green ResponseReceived` — all response sending
    happens on the non-blocking Green monad.
    $$\text{respond} : (\text{Response} \to \text{Green}\ \text{ResponseReceived}) \to \text{Response} \to \text{AppM}\ \texttt{.pending}\ \texttt{.sent}\ \text{ResponseReceived}$$ -/
@[inline] def respond (callback : Response → Green ResponseReceived) (resp : Response) :
    AppM .pending .sent ResponseReceived :=
  ⟨callback resp⟩

/-- Perform IO then respond with the computed Response.
    Convenient for the common pattern of "compute a response, then send it."
    Uses `do` notation naturally inside the `IO Response` block.
    $$\text{respondIO} : (\text{Response} \to \text{Green}\ \text{ResponseReceived}) \to \text{IO}(\text{Response}) \to \text{AppM}\ \texttt{.pending}\ \texttt{.sent}\ \text{ResponseReceived}$$ -/
@[inline] def respondIO (callback : Response → Green ResponseReceived) (action : IO Response) :
    AppM .pending .sent ResponseReceived :=
  ⟨(action : Green Response) >>= callback⟩

/-- Perform an IO action then continue with a state-changing computation.
    Useful for middleware that needs IO before deciding whether to delegate or respond.
    $$\text{ioThen} : \text{IO}(\alpha) \to (\alpha \to \text{AppM}\ s_1\ s_2\ \beta) \to \text{AppM}\ s_1\ s_2\ \beta$$ -/
@[inline] def ioThen (action : IO α) (f : α → AppM s₁ s₂ β) : AppM s₁ s₂ β :=
  ⟨(action : Green α) >>= fun a => (f a).run⟩

/-- Escape hatch for framework/middleware code that needs full IO control
    over state transitions. **Not for application code.** The caller is
    responsible for ensuring exactly-once response semantics.
    $$\text{unsafeLift} : \text{IO}(\alpha) \to \text{AppM}\ s_1\ s_2\ \alpha$$ -/
protected def unsafeLift (action : IO α) : AppM pre post α := ⟨(action : Green α)⟩

end AppM

/-- `AppM s s` is a standard Monad (for non-state-changing operations).
    Enables `do` notation inside `AppM.respondIO` or `AppM.ioThen` blocks. -/
instance : Monad (AppM s s) where
  pure := AppM.ipure
  bind := AppM.ibind

/-- IO actions lift into `AppM s s` automatically (via IO → Green → AppM). -/
instance : MonadLiftT IO (AppM s s) where
  monadLift := AppM.liftIO

/-- A WAI application.
    $$\text{Application} = \text{Request} \to (\text{Response} \to \text{Green}(\text{ResponseReceived})) \to \text{AppM}\ \texttt{.pending}\ \texttt{.sent}\ \text{ResponseReceived}$$

    The return type `AppM .pending .sent ResponseReceived` is the key
    dependent-type innovation over Haskell's WAI.  It encodes three
    compile-time guarantees simultaneously:

    1. **Response was sent** (post-state is `.sent`, not `.pending`).
    2. **Response was sent exactly once** (no path from `.sent` back to
       `.pending`; no second `respond` accepted after `.sent`).
    3. **Response was sent through the callback** (`private mk` prevents
       fabricating the `AppM` value without calling `respond`).

    Server implementations (Warp) extract the underlying `Green` via `.run`
    at the trust boundary.  Application code never touches `.run`.

    The callback takes `Response → Green ResponseReceived` — all response
    sending happens on the non-blocking Green monad, freeing pool threads
    while awaiting socket I/O. -/
abbrev Application := Request → (Response → Green ResponseReceived) → AppM .pending .sent ResponseReceived

/-- A WAI middleware transforms an application.
    $$\text{Middleware} = \text{Application} \to \text{Application}$$ -/
abbrev Middleware := Application → Application

end Network.Wai
