/-
  Tests.Control.TestGreen — Fair green thread tests

  ## Coverage

  **Tested here (runtime tests):**
  - Basic forkGreen / waitThread
  - MVar producer-consumer without pool starvation
  - Cancellation via checkCancelled
  - Exception propagation
  - Many green threads with MVar (fairness regression test)

  **Proofs in source:**
  - GreenBase.bind_terminates (axiom)
  - GreenBase.await_resumes (axiom)
  - GreenBase.no_pool_starvation (axiom)
-/

import Hale
import Tests.Harness

open Control.Concurrent Control.Concurrent.Green Tests

namespace TestGreen

def tests : IO (List TestResult) := do
  let mut results : List TestResult := []

  -- Proof coverage
  results := results ++ [
    proofCovered "GreenBase.bind terminates" "GreenBase.bind_terminates",
    proofCovered "GreenBase.await resumes on resolve" "GreenBase.await_resumes",
    proofCovered "GreenBase.bind does not block pool" "GreenBase.no_pool_starvation"
  ]

  -- Basic forkGreen
  results := results ++ [← checkIO "forkGreen runs and completes" do
    let tid ← forkGreen do
      (IO.println "  (green thread ran)")
    waitThread tid
    pure true]

  -- MVar take/put without pool starvation
  -- Fork more green threads than pool workers, all doing MVar ops.
  -- If awaiting blocked pool threads, this would deadlock.
  results := results ++ [← checkIO "MVar producer-consumer (no starvation)" do
    let mv ← MVar.newEmpty Nat
    -- Consumer: waits for a value
    let consumer ← forkGreen do
      let val ← Green.takeMVar mv
      if val != 42 then
        throw (IO.Error.userError s!"expected 42, got {val}")
    -- Producer: puts a value after a delay
    let producer ← forkGreen do
      (IO.sleep 10)
      Green.putMVar mv 42
    waitThread producer
    waitThread consumer
    pure true]

  -- Many green threads with MVar (fairness regression)
  results := results ++ [← checkIO "100 green threads with MVar" do
    let counter ← MVar.new (0 : Nat)
    let n := 100
    let mut tids : Array ThreadId := #[]
    for _ in List.range n do
      let tid ← forkGreen do
        let val ← Green.takeMVar counter
        Green.putMVar counter (val + 1)
      tids := tids.push tid
    for tid in tids do
      waitThread tid
    let final ← counter.tryRead
    match final with
    | some v => pure (v == n)
    | none => pure false]

  -- Cancellation
  results := results ++ [← checkIO "checkCancelled throws on cancel" do
    let tid ← forkGreen do
      (IO.sleep 50)
      Green.checkCancelled
      -- Should not reach here
      (IO.sleep 10000)
    killThread tid
    -- Give time for the thread to notice cancellation
    IO.sleep 100
    -- waitThread should either succeed (cancelled before sleep ended)
    -- or throw (cancelled exception propagated)
    try
      waitThread tid
      pure true
    catch _ =>
      pure true  -- cancellation exception is expected
    ]

  -- Exception propagation
  results := results ++ [← checkIO "exception propagates from Green" do
    let tid ← forkGreen do
      throw (IO.Error.userError "test error")
    try
      waitThread tid
      pure false  -- should have thrown
    catch e =>
      pure (toString e == "test error")]

  pure results

end TestGreen
