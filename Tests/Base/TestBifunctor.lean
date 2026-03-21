import LeanStd
import Tests.Harness

open Data Tests

namespace TestBifunctor

def tests : List TestResult :=
  [ checkEq "bimap on Prod" (10, "hello!") (Bifunctor.bimap (· * 10) (· ++ "!") (1, "hello"))
  , checkEq "mapFst on Prod" (10, "hi") (Bifunctor.mapFst (· * 10) (1, "hi"))
  , checkEq "mapSnd on Prod" (1, "hi!") (Bifunctor.mapSnd (· ++ "!") (1, "hi"))
  , checkEq "bimap id id on Prod" (1, "hi") (Bifunctor.bimap id id (1, "hi"))
  , checkEq "bimap on Sum inl" (Sum.inl 10 : Sum Nat String) (Bifunctor.bimap (· * 10) (· ++ "!") (Sum.inl 1 : Sum Nat String))
  , checkEq "bimap on Sum inr" (Sum.inr "hello!" : Sum Nat String) (Bifunctor.bimap (· * 10) (· ++ "!") (Sum.inr "hello" : Sum Nat String))
  , check "bimap on Except error"
      (match Bifunctor.bimap (· * 10) (· ++ "!") (Except.error 1 : Except Nat String) with
       | .error 10 => true | _ => false)
  , check "bimap on Except ok"
      (match Bifunctor.bimap (· * 10) (· ++ "!") (Except.ok "hello" : Except Nat String) with
       | .ok "hello!" => true | _ => false)
  ]
end TestBifunctor
