import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestRatio

def tests : List TestResult :=
  [ check "Ratio 1/2 + 1/3 = 5/6" (toString (Ratio.mk' 1 2 (by omega) + Ratio.mk' 1 3 (by omega)) == "5/6")
  , check "Ratio 1/2 * 1/3 = 1/6" (toString (Ratio.mk' 1 2 (by omega) * Ratio.mk' 1 3 (by omega)) == "1/6")
  , checkEq "Ratio floor 5/3" 1 (Ratio.mk' 5 3 (by omega)).floor
  , checkEq "Ratio ceil 5/3" 2 (Ratio.mk' 5 3 (by omega)).ceil
  , check "Ratio fromInt 3" (toString (Ratio.fromInt 3) == "3")
  , check "Ratio ordering 1/3 < 1/2" (compare (Ratio.mk' 1 3 (by omega)) (Ratio.mk' 1 2 (by omega)) == .lt)
  , check "Ratio equality 2/4 == 1/2" (Ratio.mk' 2 4 (by omega) == Ratio.mk' 1 2 (by omega))
  , check "Ratio sub 1/2 - 1/3 = 1/6" (toString (Ratio.mk' 1 2 (by omega) - Ratio.mk' 1 3 (by omega)) == "1/6")
  , check "Ratio neg" (toString (-(Ratio.mk' 1 2 (by omega))) == "-1/2")
  ]
end TestRatio
