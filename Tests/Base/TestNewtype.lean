import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestNewtype

def tests : List TestResult :=
  [ -- Sum
    checkEq "Sum append" (Sum.mk 7) (Sum.mk 3 ++ Sum.mk 4 : Sum Nat)
  , -- Product
    checkEq "Product append" (Product.mk 12) (Product.mk 3 ++ Product.mk 4 : Product Nat)
  , -- All
    checkEq "All true ++ true" (All.mk true) (All.mk true ++ All.mk true)
  , checkEq "All true ++ false" (All.mk false) (All.mk true ++ All.mk false)
  , -- Any
    checkEq "Any false ++ true" (Any.mk true) (Any.mk false ++ Any.mk true)
  , checkEq "Any false ++ false" (Any.mk false) (Any.mk false ++ Any.mk false)
  , -- First
    checkEq "First none ++ some" (First.mk (some 42)) (First.mk (none : Option Nat) ++ First.mk (some 42))
  , checkEq "First some ++ some" (First.mk (some 1)) (First.mk (some 1) ++ First.mk (some 2) : First Nat)
  , -- Last
    checkEq "Last some ++ some" (Last.mk (some 2)) (Last.mk (some 1) ++ Last.mk (some 2) : Last Nat)
  , -- Dual
    checkEq "Dual reverses append" (Dual.mk [2, 1]) (Dual.mk [1] ++ Dual.mk [2] : Dual (List Nat))
  , -- Endo
    checkEq "Endo composes" 7 ((Endo.mk (· + 1) ++ Endo.mk (· * 2) : Endo Nat).appEndo 3)
  ]
end TestNewtype
