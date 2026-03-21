import LeanStd
import Tests.Harness

open Control.Concurrent Tests

namespace TestChan

def tests : IO (List TestResult) := do
  let mut results : List TestResult := []

  -- write then read
  results := results ++ [← checkEqIO "Chan write-then-read" 42 do
    let ch ← Chan.new Nat
    ch.write 42
    IO.wait (← ch.read)]

  -- FIFO ordering
  results := results ++ [← checkIO "Chan FIFO ordering" do
    let ch ← Chan.new Nat
    ch.write 1
    ch.write 2
    ch.write 3
    let a ← IO.wait (← ch.read)
    let b ← IO.wait (← ch.read)
    let c ← IO.wait (← ch.read)
    pure (a == 1 && b == 2 && c == 3)]

  -- dup shares future writes
  results := results ++ [← checkIO "Chan dup shares writes" do
    let ch ← Chan.new Nat
    let ch2 ← ch.dup
    ch.write 99
    let v1 ← IO.wait (← ch.read)
    let v2 ← IO.wait (← ch2.read)
    pure (v1 == 99 && v2 == 99)]

  -- tryRead on empty
  results := results ++ [← checkEqIO "Chan tryRead empty" (none : Option Nat) do
    let ch ← Chan.new Nat
    ch.tryRead]

  -- tryRead on non-empty
  results := results ++ [← checkEqIO "Chan tryRead non-empty" (some 5) do
    let ch ← Chan.new Nat
    ch.write 5
    ch.tryRead]

  -- concurrent producer-consumer
  results := results ++ [← checkIO "Chan concurrent producer-consumer" do
    let ch ← Chan.new Nat
    let n := 100
    let producer ← IO.asTask do
      for i in List.range n do
        ch.write (i + 1)
    let sum ← IO.mkRef 0
    let consumer ← IO.asTask do
      for _ in List.range n do
        let v ← IO.wait (← ch.read)
        sum.modify (· + v)
    let _ ← IO.wait producer
    let _ ← IO.wait consumer
    let total ← sum.get
    pure (total == 5050)]

  pure results

end TestChan
