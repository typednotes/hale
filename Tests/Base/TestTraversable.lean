import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestTraversable

def tests : List TestResult :=
  [ -- sequence collapses List of Options
    checkEq "sequence List Option all some" (some [1, 2, 3]) (Traversable.sequence [some 1, some 2, some 3])
  , checkEq "sequence List Option with none" (none : Option (List Nat)) (Traversable.sequence [some 1, none, some 3])
  , -- traverse
    checkEq "traverse List with Option" (some [2, 4, 6]) (Traversable.traverse (fun n => some (n * 2)) [1, 2, 3])
  ]
end TestTraversable
