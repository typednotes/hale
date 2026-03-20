import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestIdentity

def tests : List TestResult :=
  [ checkEq "Identity construction" 42 (Identity.mk 42).runIdentity
  , checkEq "Identity map" 43 ((Functor.map (· + 1) (Identity.mk 42) : Identity Nat).runIdentity)
  , checkEq "Identity pure" 5 ((pure 5 : Identity Nat).runIdentity)
  , checkEq "Identity bind" 84 ((Identity.mk 42 >>= fun n => Identity.mk (n * 2) : Identity Nat).runIdentity)
  , checkEq "Identity seq" 10 ((Seq.seq (Identity.mk (· * 2)) (fun () => Identity.mk 5) : Identity Nat).runIdentity)
  ]
end TestIdentity
