import LeanStd
import Tests.Harness

open Data.List Tests

namespace TestNonEmpty

def tests : List TestResult :=
  [ checkEq "NonEmpty head" 1 (NonEmpty.mk 1 [2, 3]).head
  , checkEq "NonEmpty last" 3 (NonEmpty.mk 1 [2, 3]).last
  , checkEq "NonEmpty length" 3 (NonEmpty.mk 1 [2, 3]).length.val
  , checkEq "NonEmpty toList" [1, 2, 3] (NonEmpty.mk 1 [2, 3]).toList
  , checkEq "NonEmpty singleton" [42] (NonEmpty.singleton 42).toList
  , checkEq "NonEmpty cons" [0, 1, 2] (NonEmpty.cons 0 (NonEmpty.mk 1 [2])).toList
  , checkEq "NonEmpty map" [2, 4, 6] ((Functor.map (· * 2) (NonEmpty.mk 1 [2, 3]) : NonEmpty Nat).toList)
  , checkEq "NonEmpty append" [1, 2, 3, 4] ((NonEmpty.mk 1 [2] ++ NonEmpty.mk 3 [4]).toList)
  , checkEq "NonEmpty reverse" [3, 2, 1] (NonEmpty.mk 1 [2, 3]).reverse.toList
  , checkEq "NonEmpty foldr" 16 ((NonEmpty.mk 1 [2, 3]).foldr (· + ·) 10)
  , checkEq "NonEmpty foldr1" 6 ((NonEmpty.mk 1 [2, 3]).foldr1 (· + ·))
  , checkEq "NonEmpty foldl1" 6 ((NonEmpty.mk 1 [2, 3]).foldl1 (· + ·))
  , check "NonEmpty fromList? some" ((NonEmpty.fromList? [1, 2, 3]).isSome)
  , check "NonEmpty fromList? none" ((NonEmpty.fromList? ([] : List Nat)).isNone)
  ]
end TestNonEmpty
