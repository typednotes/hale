import LeanStd
import Tests.Harness

open Control.Concurrent Tests

namespace TestQSem

def tests : IO (List TestResult) := do
  let mut results : List TestResult := []

  -- signal then wait
  results := results ++ [← checkIO "QSem signal-then-wait" do
    let sem ← QSem.new 1
    IO.wait (← sem.wait)
    sem.signal
    IO.wait (← sem.wait)
    sem.signal
    pure true]

  -- semaphore(1) as mutex
  results := results ++ [← checkIO "QSem(1) mutual exclusion" do
    let sem ← QSem.new 1
    let counter ← IO.mkRef 0
    let tasks ← (List.range 10).mapM fun _ => IO.asTask do
      sem.withSem do
        let v ← counter.get
        IO.sleep 1
        counter.set (v + 1)
    for t in tasks do
      let _ ← IO.wait t
    let final ← counter.get
    pure (final == 10)]

  -- QSem(0) blocks until signal
  results := results ++ [← checkIO "QSem(0) blocks then unblocks" do
    let sem ← QSem.new 0
    let flag ← IO.mkRef false
    let _ ← IO.asTask do
      IO.sleep 10
      sem.signal
    IO.wait (← sem.wait)
    flag.set true
    flag.get]

  pure results

end TestQSem
