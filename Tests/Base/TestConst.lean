import LeanStd
import Tests.Harness

open Data.Functor Tests

namespace TestConst

def tests : List TestResult :=
  [ checkEq "Const getConst" 42 (Const.mk (β := String) 42).getConst
  , checkEq "Const functor map preserves value" 42
      ((Functor.map (· ++ "!") (Const.mk (β := String) 42) : Const Nat String).getConst)
  , check "Const BEq equal" (Const.mk (β := String) 42 == Const.mk (β := String) 42)
  , check "Const BEq not equal" !(Const.mk (β := String) 42 == Const.mk (β := String) 99)
  ]
end TestConst
