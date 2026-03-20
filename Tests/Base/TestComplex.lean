import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestComplex

def tests : List TestResult :=
  [ checkEq "Complex re" 3 (Complex.mk 3 4 : Complex Int).re
  , checkEq "Complex im" 4 (Complex.mk 3 4 : Complex Int).im
  , checkEq "Complex add re" 4 ((Complex.mk 3 4 + Complex.mk 1 (-2) : Complex Int).re)
  , checkEq "Complex add im" 2 ((Complex.mk 3 4 + Complex.mk 1 (-2) : Complex Int).im)
  , checkEq "Complex conjugate" (-4) (Complex.conjugate (Complex.mk 3 4 : Complex Int)).im
  , checkEq "Complex magnitudeSquared" 25 (Complex.magnitudeSquared (Complex.mk 3 4 : Complex Int))
  , checkEq "Complex neg" (-3) ((-(Complex.mk 3 4 : Complex Int)).re)
  , check "Complex toString" (toString (Complex.mk 3 4 : Complex Int) != "")
  ]
end TestComplex
