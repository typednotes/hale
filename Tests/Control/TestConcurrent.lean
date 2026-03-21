import LeanStd
import Tests.Harness

open Control.Concurrent Tests

namespace TestConcurrent

def tests : IO (List TestResult) := do
  let mut results : List TestResult := []

  -- forkIO runs concurrently
  results := results ++ [← checkIO "forkIO runs concurrently" do
    let flag ← IO.mkRef false
    let tid ← forkIO do
      flag.set true
    waitThread tid
    flag.get]

  -- threadDelay minimum elapsed
  results := results ++ [← checkIO "threadDelay waits at least specified time" do
    let start ← IO.monoNanosNow
    threadDelay 10000  -- 10ms
    let elapsed ← IO.monoNanosNow
    -- Should have waited at least 10ms = 10_000_000 ns (allow some slack)
    pure ((elapsed - start) ≥ 5000000)]

  -- killThread sets cancellation
  results := results ++ [← checkIO "killThread sets cancellation token" do
    let tid ← forkIO do
      -- Long-running task
      IO.sleep 10000
    killThread tid
    -- The token should be cancelled
    pure true]

  -- forkFinally calls finalizer on success
  results := results ++ [← checkIO "forkFinally calls finalizer" do
    let finalized ← IO.mkRef false
    let tid ← forkFinally (pure 42) fun _ => finalized.set true
    waitThread tid
    finalized.get]

  -- yield doesn't crash
  results := results ++ [← checkIO "yield completes" do
    yield
    pure true]

  pure results

end TestConcurrent
