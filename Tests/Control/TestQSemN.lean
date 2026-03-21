import LeanStd
import Tests.Harness

open Control.Concurrent Tests

namespace TestQSemN

def tests : IO (List TestResult) := do
  let mut results : List TestResult := []

  -- acquire and release
  results := results ++ [← checkIO "QSemN acquire-release" do
    let sem ← QSemN.new 10
    IO.wait (← sem.wait 5)
    sem.signal 5
    IO.wait (← sem.wait 10)
    sem.signal 10
    pure true]

  -- acquire more than available blocks
  results := results ++ [← checkIO "QSemN blocks when insufficient" do
    let sem ← QSemN.new 3
    IO.wait (← sem.wait 3)
    let released ← IO.mkRef false
    let _ ← IO.asTask do
      IO.sleep 10
      released.set true
      sem.signal 3
    IO.wait (← sem.wait 3)
    released.get]

  -- withSemN exception safety
  results := results ++ [← checkIO "QSemN.withSemN releases on success" do
    let sem ← QSemN.new 5
    sem.withSemN 5 (pure ())
    IO.wait (← sem.wait 5)
    sem.signal 5
    pure true]

  pure results

end TestQSemN
