import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestOrd

def tests : List TestResult :=
  [ check "Down reverses ordering lt->gt" (compare (Down.mk 3) (Down.mk 7) == Ordering.gt)
  , check "Down reverses ordering gt->lt" (compare (Down.mk 7) (Down.mk 3) == Ordering.lt)
  , check "Down equal" (compare (Down.mk 5) (Down.mk 5) == Ordering.eq)
  , checkEq "Down getDown" 42 (Down.mk 42).getDown
  , check "Down BEq equal" (Down.mk 5 == Down.mk 5)
  , check "Down BEq not equal" (!(Down.mk 5 == Down.mk 6))
  , check "comparing by length" (comparing (α := String) String.length "hi" "hello" == Ordering.lt)
  , check "comparing equal lengths" (comparing (α := String) String.length "ab" "cd" == Ordering.eq)
  ]
end TestOrd
