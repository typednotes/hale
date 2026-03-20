import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestFixed

def tests : List TestResult :=
  [ checkEq "Fixed fromInt" 300 (Fixed.fromInt (p := 2) 3).raw
  , checkEq "Fixed add raw" 457 ((Fixed.fromInt (p := 2) 3 + (⟨157⟩ : Fixed 2)).raw)
  , check "Fixed toString 3.00" (toString (Fixed.fromInt (p := 2) 3) == "3.00")
  , check "Fixed toString 1.57" (toString (⟨157⟩ : Fixed 2) == "1.57")
  , checkEq "Fixed sub" 143 ((Fixed.fromInt (p := 2) 3 - (⟨157⟩ : Fixed 2)).raw)
  , checkEq "Fixed neg" (-300) ((-(Fixed.fromInt (p := 2) 3)).raw)
  , checkEq "Fixed scale 2" 100 (Fixed.scale 2)
  , checkEq "Fixed scale 0" 1 (Fixed.scale 0)
  ]
end TestFixed
