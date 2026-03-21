import LeanStd
import Tests.Harness

open Data.Tuple Tests

namespace TestTuple

def tests : List TestResult :=
  [ checkEq "Tuple swap" ("hello", 1) (Data.Tuple.swap (1, "hello"))
  , checkEq "Tuple swap involution" (1, 2) (Data.Tuple.swap (Data.Tuple.swap (1, 2)))
  , checkEq "Tuple mapFst" (10, "hi") (Data.Tuple.mapFst (· * 10) (1, "hi"))
  , checkEq "Tuple mapSnd" (1, 6) (Data.Tuple.mapSnd (· * 2) (1, 3))
  , checkEq "Tuple bimap" (10, 6) (Data.Tuple.bimap (· * 10) (· * 2) (1, 3))
  , checkEq "Tuple bimap id id" (3, 4) (Data.Tuple.bimap id id (3, 4))
  , checkEq "Tuple curry" 5 (Data.Tuple.curry (fun p => p.1 + p.2) 2 3)
  , checkEq "Tuple uncurry" 5 (Data.Tuple.uncurry (· + ·) (2, 3))
  , checkEq "Tuple curry uncurry roundtrip" 5 (Data.Tuple.curry (Data.Tuple.uncurry (· + ·)) 2 3)
  , checkEq "Tuple uncurry curry roundtrip" 5 (Data.Tuple.uncurry (Data.Tuple.curry (fun p => p.1 + p.2)) (2, 3))
  ]
end TestTuple
