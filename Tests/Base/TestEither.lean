import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestEither

def tests : List TestResult :=
  [ check "Either isRight" (Either.right (α := String) 42).isRight
  , check "Either isLeft" (Either.left (β := Nat) "err").isLeft
  , check "Either not isLeft for right" (!(Either.right (α := String) 42).isLeft)
  , check "Either not isRight for left" (!(Either.left (β := Nat) "err").isRight)
  , checkEq "Either fromRight on right" 42 (Either.fromRight 0 (Either.right (α := String) 42))
  , checkEq "Either fromRight on left" 0 (Either.fromRight 0 (Either.left (β := Nat) "err"))
  , checkEq "Either fromLeft on left" "err" (Either.fromLeft "" (Either.left (β := Nat) "err"))
  , checkEq "Either fromLeft on right" "" (Either.fromLeft "" (Either.right (α := String) 42))
  , check "Either either left" (Either.either String.length id (Either.left (β := Nat) "hello") == 5)
  , check "Either either right" (Either.either String.length id (Either.right (α := String) 7) == 7)
  , check "Either swap left->right"
      (match Either.swap (Either.left (β := Nat) "a") with | .right "a" => true | _ => false)
  , check "Either swap right->left"
      (match Either.swap (Either.right (α := String) 42) with | .left 42 => true | _ => false)
  , check "Either swap involution"
      (match Either.swap (Either.swap (Either.right (α := String) 42)) with | .right 42 => true | _ => false)
  , checkEq "Either mapRight" (Either.right (α := String) 43) (Either.mapRight (· + 1) (Either.right (α := String) 42))
  , checkEq "Either mapLeft" (Either.left (β := Nat) "ERR") (Either.mapLeft String.toUpper (Either.left (β := Nat) "err"))
  , check "Either partitionEithers" (
      let (ls, rs) := Either.partitionEithers [Either.left "a", Either.right 1, Either.left "b", Either.right 2]
      ls == ["a", "b"] && rs == [1, 2])
  ]
end TestEither
