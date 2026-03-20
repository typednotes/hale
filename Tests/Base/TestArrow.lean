import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestArrow

def tests : List TestResult :=
  [ checkEq "Arrow arr" 6 ((Arrow.arr (α := Nat) (β := Nat) (Cat := Fun) (· * 2)).apply 3)
  , checkEq "Arrow first" (6, "hi") ((Arrow.first (Cat := Fun) (Fun.mk (· * 2 : Nat → Nat))).apply (3, "hi"))
  , checkEq "Arrow second" ("hi", 6) ((Arrow.second (Cat := Fun) (Fun.mk (· * 2 : Nat → Nat))).apply ("hi", 3))
  , check "ArrowChoice left on Left" (
      let result := (ArrowChoice.left (Cat := Fun) (Fun.mk (· * 2 : Nat → Nat))).apply (Either.left (β := String) 3)
      match result with | .left n => n == 6 | .right _ => false)
  , check "ArrowChoice left on Right" (
      let result := (ArrowChoice.left (Cat := Fun) (Fun.mk (· * 2 : Nat → Nat))).apply (Either.right (α := Nat) "hi")
      match result with | .right s => s == "hi" | .left _ => false)
  ]
end TestArrow
