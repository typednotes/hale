import LeanStd
import Tests.Harness

open Control.Concurrent Tests

namespace TestMVar

def tests : IO (List TestResult) := do
  let mut results : List TestResult := []

  -- new / tryRead
  results := results ++ [← checkEqIO "MVar.new then tryRead" (some 42) do
    let mv ← MVar.new 42
    mv.tryRead]

  -- newEmpty / isEmpty
  results := results ++ [← checkIO "MVar.newEmpty is empty" do
    let mv ← MVar.newEmpty Nat
    mv.isEmpty]

  -- put then take round-trip (sync)
  results := results ++ [← checkEqIO "put then takeSync" 99 do
    let mv ← MVar.newEmpty Nat
    IO.wait (← mv.put 99)
    mv.takeSync]

  -- take then put round-trip (async)
  results := results ++ [← checkEqIO "async take-put round-trip" 7 do
    let mv ← MVar.new 7
    let task ← mv.take
    IO.wait task]

  -- read doesn't remove
  results := results ++ [← checkIO "read doesn't remove value" do
    let mv ← MVar.new 42
    let _ ← IO.wait (← mv.read)
    let v ← mv.tryRead
    pure (v == some 42)]

  -- tryTake on full
  results := results ++ [← checkEqIO "tryTake on full" (some 10) do
    let mv ← MVar.new 10
    mv.tryTake]

  -- tryTake on empty
  results := results ++ [← checkEqIO "tryTake on empty" (none : Option Nat) do
    let mv ← MVar.newEmpty Nat
    mv.tryTake]

  -- tryPut on empty succeeds
  results := results ++ [← checkIO "tryPut on empty" do
    let mv ← MVar.newEmpty Nat
    mv.tryPut 5]

  -- tryPut on full fails
  results := results ++ [← checkIO "tryPut on full fails" do
    let mv ← MVar.new 1
    let ok ← mv.tryPut 2
    pure (!ok)]

  -- swap
  results := results ++ [← checkEqIO "swap returns old value" 10 do
    let mv ← MVar.new 10
    IO.wait (← mv.swap 20)]

  results := results ++ [← checkEqIO "swap installs new value" (some 20) do
    let mv ← MVar.new 10
    let _ ← IO.wait (← mv.swap 20)
    mv.tryRead]

  -- modify
  results := results ++ [← checkEqIO "modify returns result" "hello" do
    let mv ← MVar.new 5
    IO.wait (← mv.modify fun n => pure (n + 1, "hello"))]

  results := results ++ [← checkEqIO "modify updates value" (some 6) do
    let mv ← MVar.new 5
    let _ ← IO.wait (← mv.modify fun n => pure (n + 1, "hello"))
    mv.tryRead]

  -- concurrent producer-consumer (100 items)
  results := results ++ [← checkIO "concurrent producer-consumer 100 items" do
    let mv ← MVar.newEmpty Nat
    let sum ← IO.mkRef 0
    -- Producer: put 1..100
    let producer ← IO.asTask do
      for i in List.range 100 do
        mv.putSync (i + 1)
    -- Consumer: take 100 values and sum
    let consumer ← IO.asTask do
      for _ in List.range 100 do
        let v ← mv.takeSync
        sum.modify (· + v)
    let _ ← IO.wait producer
    let _ ← IO.wait consumer
    let total ← sum.get
    pure (total == 5050)]

  pure results

end TestMVar
