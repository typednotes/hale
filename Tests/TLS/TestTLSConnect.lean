/-
  Tests.TLS.TestTLSConnect — TLS connection handshake test

  Exercises the exact bug scenario: Blocking.connect + TLS handshake.
  The original bug was that Blocking.connect could declare a socket
  connected before the TCP handshake finished, causing SSL_connect
  to fail with SSL_ERROR_WANT_WRITE (error 3) intermittently.

  This test connects to a real HTTPS server multiple times to verify
  the fix handles the race condition reliably.
-/
import Hale
import Tests.Harness

open Network.Socket Network.TLS Tests

namespace TestTLSConnect

/-- Perform a single TLS connection to a host:port, return true on success. -/
private def tryTLSConnect (host : String) (port : UInt16) : IO Bool := do
  let sock ← socket .inet .stream
  let sock ← Blocking.connect sock ⟨host, port⟩
  let ctx ← createClientContext
  let session ← connectSocket ctx sock.raw host
  let version ← getVersion session
  Network.TLS.close session
  let _ ← Network.Socket.close sock
  -- Success if we got a TLS version string
  pure (version.length > 0)

/-- Run n TLS connections sequentially, return (successes, failures, errors). -/
private def runNConnections (host : String) (port : UInt16) (n : Nat)
    : IO (Nat × Nat × List String) := do
  let mut successes := 0
  let mut failures := 0
  let mut errors : List String := []
  for _ in List.range n do
    try
      let ok ← tryTLSConnect host port
      if ok then successes := successes + 1
      else
        failures := failures + 1
        errors := "TLS connected but no version string" :: errors
    catch e =>
      failures := failures + 1
      errors := s!"{e}" :: errors
  pure (successes, failures, errors)

def tests : IO (List TestResult) := do
  -- Single connection test
  let singleOk ← try
    let ok ← tryTLSConnect "example.com" 443
    pure ok
  catch e =>
    IO.eprintln s!"  single TLS connect failed: {e}"
    pure false

  -- Repeated sequential connections (20x) to trigger the race condition
  let (seqSucc, seqFail, seqErrs) ← runNConnections "example.com" 443 20

  if seqFail > 0 then
    IO.eprintln s!"  sequential TLS failures ({seqFail}/20):"
    for e in seqErrs do
      IO.eprintln s!"    {e}"

  -- Parallel connections: launch 5 concurrent TLS handshakes
  -- This maximizes pressure on the connect → TLS transition
  let parallelTasks ← (List.range 5).mapM fun _ =>
    IO.asTask (prio := .dedicated) (tryTLSConnect "example.com" 443)
  let mut parSucc := 0
  let mut parFail := 0
  let mut parErrs : List String := []
  for task in parallelTasks do
    match task.get with
    | .ok true  => parSucc := parSucc + 1
    | .ok false =>
      parFail := parFail + 1
      parErrs := "no version string" :: parErrs
    | .error e  =>
      parFail := parFail + 1
      parErrs := s!"{e}" :: parErrs

  if parFail > 0 then
    IO.eprintln s!"  parallel TLS failures ({parFail}/5):"
    for e in parErrs do
      IO.eprintln s!"    {e}"

  pure [
    check "single TLS handshake succeeds" singleOk
  , check s!"sequential TLS handshakes ({seqSucc}/20 ok)" (seqFail == 0)
  , check s!"parallel TLS handshakes ({parSucc}/5 ok)" (parFail == 0)
  ]

end TestTLSConnect
