import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestCompose

def tests : List TestResult :=
  [ checkEq "Compose getCompose" [some 1, none, some 3]
      (Compose.mk [some 1, none, some 3] : Compose List Option Nat).getCompose
  , checkEq "Compose map" [some 2, none, some 6]
      ((Functor.map (· * 2) (Compose.mk [some 1, none, some 3]) : Compose List Option Nat).getCompose)
  , checkEq "Compose map on Identity Option" (Identity.mk (some 10))
      ((Functor.map (· * 2) (Compose.mk (Identity.mk (some 5))) : Compose Identity Option Nat).getCompose)
  ]
end TestCompose
