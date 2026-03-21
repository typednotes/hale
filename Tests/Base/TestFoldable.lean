import LeanStd
import Tests.Harness

open Data Data.List Tests

namespace TestFoldable

def tests : List TestResult :=
  [ checkEq "Foldable.length List" 3 (Foldable.length [1, 2, 3])
  , checkEq "Foldable.sum List" 6 (Foldable.sum [1, 2, 3])
  , checkEq "Foldable.product List" 24 (Foldable.product [1, 2, 3, 4])
  , check "Foldable.null empty" (Foldable.null ([] : List Nat))
  , check "Foldable.null nonempty" (!(Foldable.null [1]))
  , check "Foldable.any" (Foldable.any (· > 2) [1, 2, 3])
  , check "Foldable.all" (Foldable.all (· > 0) [1, 2, 3])
  , check "Foldable.all fails" (!(Foldable.all (· > 2) [1, 2, 3]))
  , check "Foldable.elem" (Foldable.elem 2 [1, 2, 3])
  , check "Foldable.elem missing" (!(Foldable.elem 5 [1, 2, 3]))
  , checkEq "Foldable.find?" (some 3) (Foldable.find? (· > 2) [1, 2, 3, 4])
  , checkEq "Foldable Option some" 1 (Foldable.length (some 42))
  , checkEq "Foldable Option none" 0 (Foldable.length (none : Option Nat))
  , checkEq "Foldable NonEmpty length" 3 (Foldable.length (NonEmpty.mk 1 [2, 3]))
  , checkEq "Foldable.sum NonEmpty" 6 (Foldable.sum (NonEmpty.mk 1 [2, 3]))
  ]
end TestFoldable
