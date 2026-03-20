import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestCategory

def tests : List TestResult :=
  [ checkEq "Fun id" 42 ((Category.id (Cat := Fun)).apply 42)
  , checkEq "Fun comp diagrammatic" 8 ((Category.comp (Fun.mk (· + 1)) (Fun.mk (· * 2)) : Fun Nat Nat).apply 3)
  , checkEq "Fun comp id left" 5 ((Category.comp Category.id (Fun.mk (· + 1)) : Fun Nat Nat).apply 4)
  , checkEq "Fun comp id right" 5 ((Category.comp (Fun.mk (· + 1)) Category.id : Fun Nat Nat).apply 4)
  ]
end TestCategory
