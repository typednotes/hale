import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestTuple

def tests : List TestResult :=
  [ checkEq "Tuple swap" ("hello", 1) (Tuple.swap (1, "hello"))
  , checkEq "Tuple swap involution" (1, 2) (Tuple.swap (Tuple.swap (1, 2)))
  , checkEq "Tuple mapFst" (10, "hi") (Tuple.mapFst (· * 10) (1, "hi"))
  , checkEq "Tuple mapSnd" (1, 6) (Tuple.mapSnd (· * 2) (1, 3))
  , checkEq "Tuple bimap" (10, 6) (Tuple.bimap (· * 10) (· * 2) (1, 3))
  , checkEq "Tuple bimap id id" (3, 4) (Tuple.bimap id id (3, 4))
  , checkEq "Tuple curry" 5 (Tuple.curry (fun p => p.1 + p.2) 2 3)
  , checkEq "Tuple uncurry" 5 (Tuple.uncurry (· + ·) (2, 3))
  , checkEq "Tuple curry uncurry roundtrip" 5 (Tuple.curry (Tuple.uncurry (· + ·)) 2 3)
  , checkEq "Tuple uncurry curry roundtrip" 5 (Tuple.uncurry (Tuple.curry (fun p => p.1 + p.2)) (2, 3))
  ]
end TestTuple
