import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestContravariant

def tests : List TestResult :=
  [ check "contramap on Predicate compiles" true
  , check "contramap on Equivalence compiles" true
  , check "Predicate contramap construction"
      (let p : Predicate Nat := ⟨fun n => n > 5⟩
       let _q : Predicate String := Contravariant.contramap String.length p
       true)
  , check "Equivalence contramap construction"
      (let e : Equivalence Nat := ⟨fun a b => a == b⟩
       let _f : Equivalence String := Contravariant.contramap String.length e
       true)
  ]
end TestContravariant
