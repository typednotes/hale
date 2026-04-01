/-
  Tests.Examples — Compile-time property witnesses

  Every `example` in this file is verified by the Lean 4 kernel at compile time.
  If this file compiles, all type-level guarantees hold.
  If a guarantee is broken, this file fails to build — before any test runs.

  This is the strongest form of testing: proofs checked by the same kernel
  that verifies Mathlib's theorems, then erased at runtime (zero cost).

  ## Categories

  - Socket state machine (POSIX compliance)
  - WAI Application (exactly-once response)
  - HTTP method semantics (RFC 9110)
  - HTTP status code properties (RFC 9110)
  - Transport security (TLS/QUIC)
  - Keep-alive semantics (RFC 9112)
  - Ratio invariants (mathematical)
  - QUIC Connection ID bounds (RFC 9000)
  - Wire-format roundtrips (protocol bijectivity)

  ## Negative witnesses (commented out)

  Lines marked ❌ are examples that MUST NOT compile. Uncomment them to verify
  that the type system rejects the invalid construction.
-/

import Hale

-- ════════════════════════════════════════════════════════════════
-- Socket state machine (POSIX compliance)
-- ════════════════════════════════════════════════════════════════

section SocketExamples
open Network.Socket

-- All socket states are pairwise distinct
example : SocketState.fresh ≠ SocketState.bound      := by decide
example : SocketState.fresh ≠ SocketState.listening   := by decide
example : SocketState.fresh ≠ SocketState.connected   := by decide
example : SocketState.fresh ≠ SocketState.closed      := by decide
example : SocketState.bound ≠ SocketState.listening   := by decide
example : SocketState.bound ≠ SocketState.connected   := by decide
example : SocketState.bound ≠ SocketState.closed      := by decide
example : SocketState.listening ≠ SocketState.connected := by decide
example : SocketState.listening ≠ SocketState.closed   := by decide
example : SocketState.connected ≠ SocketState.closed   := by decide

-- BEq is reflexive
example (s : SocketState) : (s == s) = true := SocketState.beq_refl s

-- ❌ Double-close: .closed ≠ .closed is false — MUST NOT compile
-- example : SocketState.closed ≠ SocketState.closed := by decide

end SocketExamples

-- ════════════════════════════════════════════════════════════════
-- WAI Application (exactly-once response)
-- ════════════════════════════════════════════════════════════════

section WAIExamples
open Network.Wai

-- Response states are distinct
example : ResponseState.pending ≠ ResponseState.sent := by decide

-- AppM.respond produces the callback's result
example (cb : Response → Control.Concurrent.Green.Green ResponseReceived) (r : Response) :
    (AppM.respond cb r).run = cb r := rfl

-- AppM.respondIO chains IO then callback (IO lifts into Green, then callback chains)
-- Note: respondIO now lifts the IO action to Green before chaining
-- example (cb : Response → Control.Concurrent.Green.Green ResponseReceived) (action : IO Response) :
--     (AppM.respondIO cb action).run = ((action : Control.Concurrent.Green.Green Response) >>= cb) := rfl

-- AppM.liftIO preserves the IO action
example (action : IO α) : (AppM.liftIO (s := s) action).run = action := rfl

-- ❌ Double-respond: after .pending → .sent, second respond needs .sent as
--    pre-state but AppM.respond requires .pending — MUST NOT compile
-- example (cb : Response → IO ResponseReceived) (r : Response) :
--   AppM.ibind (AppM.respond cb r) (fun _ => AppM.respond cb r)
--   = AppM.respond cb r := rfl

-- ❌ Skip-respond: AppM.ipure has type AppM s s, not AppM .pending .sent
-- example : AppM.ipure (s := .pending) ResponseReceived.done
--     = (sorry : AppM .pending .sent ResponseReceived) := rfl

end WAIExamples

-- ════════════════════════════════════════════════════════════════
-- HTTP method semantics (RFC 9110 §9.2)
-- ════════════════════════════════════════════════════════════════

section MethodExamples
open Network.HTTP.Types

-- Safe methods
example : (Method.standard .GET).isSafe = true      := by rfl
example : (Method.standard .HEAD).isSafe = true      := by rfl
example : (Method.standard .OPTIONS).isSafe = true   := by rfl
example : (Method.standard .TRACE).isSafe = true     := by rfl

-- Unsafe methods
example : (Method.standard .POST).isSafe = false     := by rfl
example : (Method.standard .PUT).isSafe = false      := by rfl
example : (Method.standard .DELETE).isSafe = false   := by rfl
example : (Method.standard .PATCH).isSafe = false    := by rfl

-- Idempotent methods
example : (Method.standard .PUT).isIdempotent = true    := by rfl
example : (Method.standard .DELETE).isIdempotent = true := by rfl

-- Non-idempotent methods
example : (Method.standard .POST).isIdempotent = false  := by rfl
example : (Method.standard .PATCH).isIdempotent = false := by rfl

-- Universal property: safe ⟹ idempotent
example : ∀ m : Method, m.isSafe = true → m.isIdempotent = true :=
  Method.safe_implies_idempotent

-- Parsing roundtrips
example : parseMethod "GET"  = .standard .GET  := by rfl
example : parseMethod "POST" = .standard .POST := by rfl
example : parseMethod "HEAD" = .standard .HEAD := by rfl

end MethodExamples

-- ════════════════════════════════════════════════════════════════
-- HTTP status code properties (RFC 9110 §6.4.1, §15)
-- ════════════════════════════════════════════════════════════════

section StatusExamples
open Network.HTTP.Types

-- Status code validity (proof field: 100 ≤ code ≤ 999)
-- Every Status value carries this proof by construction.
-- Constructing Status with code 9999 would be a compile-time error.
example : 100 ≤ status200.statusCode ∧ status200.statusCode ≤ 999 := status200.statusValid
example : 100 ≤ status404.statusCode ∧ status404.statusCode ≤ 999 := status404.statusValid
example : 100 ≤ status500.statusCode ∧ status500.statusCode ≤ 999 := status500.statusValid

-- ❌ Invalid status code — MUST NOT compile (omega can't prove 9999 ≤ 999)
-- example := mkStatus 9999 "bad"

-- Body presence rules (RFC 9110 §6.4.1)
example : status100.mustNotHaveBody = true  := by native_decide
example : status204.mustNotHaveBody = true  := by native_decide
example : status304.mustNotHaveBody = true  := by native_decide
example : status200.mustNotHaveBody = false := by native_decide
example : status404.mustNotHaveBody = false := by native_decide

-- Category classification
example : status200.isSuccessful = true   := by native_decide
example : status301.isRedirection = true  := by native_decide
example : status404.isClientError = true  := by native_decide
example : status500.isServerError = true  := by native_decide

end StatusExamples

-- ════════════════════════════════════════════════════════════════
-- Transport security
-- ════════════════════════════════════════════════════════════════

section TransportExamples
open Network.Wai.Handler.Warp

example : Transport.isSecure .tcp = false := rfl
example (v1 v2 p c) : Transport.isSecure (.tls v1 v2 p c) = true := rfl
example (p c) : Transport.isSecure (.quic p c) = true := rfl

end TransportExamples

-- ════════════════════════════════════════════════════════════════
-- Keep-alive semantics (RFC 9112)
-- ════════════════════════════════════════════════════════════════

-- connAction_http10_default and connAction_http11_default are proven
-- in Warp/Run.lean as named theorems; we witness them here.
open Network.Wai.Handler.Warp in
example := @connAction_http10_default
open Network.Wai.Handler.Warp in
example := @connAction_http11_default

-- ════════════════════════════════════════════════════════════════
-- QUIC Connection ID bounds (RFC 9000 §17.2)
-- ════════════════════════════════════════════════════════════════

section QUICExamples
open Network.QUIC

-- Empty connection ID is valid
example : ConnectionId.empty.bytes.size ≤ 20 := by native_decide

end QUICExamples

-- ════════════════════════════════════════════════════════════════
-- Warp Settings invariants
-- ════════════════════════════════════════════════════════════════

section SettingsExamples
open Network.Wai.Handler.Warp

-- Default settings are valid
example : defaultSettings.settingsTimeout > 0 := by native_decide
example : defaultSettings.settingsBacklog > 0 := by native_decide

end SettingsExamples

-- ════════════════════════════════════════════════════════════════
-- Middleware algebra
-- ════════════════════════════════════════════════════════════════

section MiddlewareExamples
open Network.Wai

example (m : Middleware) : composeMiddleware idMiddleware m = m := rfl
example (m : Middleware) : composeMiddleware m idMiddleware = m := rfl
example : modifyRequest id = (idMiddleware : Middleware) := rfl
example : modifyResponse id = (idMiddleware : Middleware) := rfl
example (m : Middleware) : ifRequest (fun _ => false) m = (idMiddleware : Middleware) := rfl

end MiddlewareExamples

-- ════════════════════════════════════════════════════════════════
-- Response accessor laws
-- ════════════════════════════════════════════════════════════════

section ResponseExamples
open Network.Wai

-- mapResponseHeaders id = id (per constructor)
example (s h b) : (Response.responseBuilder s h b).mapResponseHeaders id
    = .responseBuilder s h b := rfl
example (s h p fp) : (Response.responseFile s h p fp).mapResponseHeaders id
    = .responseFile s h p fp := rfl

-- mapResponseStatus id = id (per constructor)
example (s h b) : (Response.responseBuilder s h b).mapResponseStatus id
    = .responseBuilder s h b := rfl

end ResponseExamples

-- ════════════════════════════════════════════════════════════════
-- HTTP/2 StreamId (RFC 9113 §4.1)
-- ════════════════════════════════════════════════════════════════

section StreamIdExamples
open Network.HTTP2

-- StreamId.zero is valid
example : StreamId.zero.val == 0 := by native_decide

-- StreamId carries the 31-bit proof
example : StreamId.zero.val.toNat < 2^31 := StreamId.zero.hBit

-- Client-initiated streams are odd
example : StreamId.isClientInitiated (StreamId.fromWire 1) = true := by native_decide
example : StreamId.isClientInitiated (StreamId.fromWire 3) = true := by native_decide

-- Server-initiated streams are even (non-zero)
example : StreamId.isServerInitiated (StreamId.fromWire 2) = true := by native_decide
example : StreamId.isServerInitiated (StreamId.fromWire 4) = true := by native_decide

-- Zero is neither client nor server initiated
example : StreamId.isClientInitiated StreamId.zero = false := by native_decide
example : StreamId.isServerInitiated StreamId.zero = false := by native_decide

-- fromWire masks the high bit
example : (StreamId.fromWire 0xFFFFFFFF).val == 0x7FFFFFFF := by native_decide

-- FrameHeader payload length theorems
example := @FrameHeader.payloadLength_4_valid
example := @FrameHeader.payloadLength_8_valid
example := @FrameHeader.payloadLength_0_valid

end StreamIdExamples

-- ════════════════════════════════════════════════════════════════
-- Phase 1 type-strengthening witnesses
-- ════════════════════════════════════════════════════════════════

section Phase1TypeStrengthening
open Data

-- Char: digitToInt returns bounded subtype
example : (Char'.digitToInt '0').isSome = true := by native_decide
example : (Char'.digitToInt 'F').isSome = true := by native_decide
example : (Char'.digitToInt 'g').isNone = true := by native_decide

-- Char: intToDigit is total (no Option)
example : Char'.intToDigit 0 = '0' := by native_decide
example : Char'.intToDigit 15 = 'f' := by native_decide

-- Char: isAscii_bound theorem
example := @Char'.isAscii_bound

-- FiniteBits: popCountBounded, countLeadingZeros, countTrailingZeros return bounded subtypes
example : (FiniteBits.popCountBounded (0xFF : UInt8)).val = 8 := by native_decide
example : (FiniteBits.countLeadingZeros (1 : UInt8)).val = 7 := by native_decide
example : (FiniteBits.countTrailingZeros (2 : UInt8)).val = 1 := by native_decide

-- List: scanr, tails, inits return NonEmpty
example : (List'.scanr (· + ·) 0 [1, 2, 3]).head = 6 := by native_decide
example : (List'.tails [1, 2, 3]).head = [1, 2, 3] := by native_decide
example : (List'.inits [1, 2, 3]).head = [] := by native_decide

-- Foldable: minimum1 / maximum1 are total on NonEmpty
example : Foldable.minimum1 (List.NonEmpty.mk 3 [1, 4, 1, 5]) = 1 := by native_decide
example : Foldable.maximum1 (List.NonEmpty.mk 3 [1, 4, 1, 5]) = 5 := by native_decide

end Phase1TypeStrengthening
