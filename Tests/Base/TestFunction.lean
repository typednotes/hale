import LeanStd
import Tests.Harness

open Data.Function Tests

namespace TestFunction

def tests : List TestResult :=
  [ checkEq "const returns first arg" (42 : Nat) (Data.Function.const 42 "ignored")
  , checkEq "flip swaps args" (3 : Nat) (Data.Function.flip Nat.sub 2 5)
  , checkEq "applyTo applies" (10 : Nat) (Data.Function.applyTo 5 (· * 2))
  , checkEq "on lifts through projection" true (Data.Function.on (· == ·) (· % 2) 3 5)
  , checkEq "flip involution" (3 : Nat) (Data.Function.flip (Data.Function.flip Nat.sub) 5 2)
  ]
end TestFunction
