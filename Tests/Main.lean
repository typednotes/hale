import Tests.Harness
import Tests.Base.TestVoid
import Tests.Base.TestFunction
import Tests.Base.TestNewtype
import Tests.Base.TestBifunctor
import Tests.Base.TestContravariant
import Tests.Base.TestConst
import Tests.Base.TestIdentity
import Tests.Base.TestCompose
import Tests.Base.TestCategory
import Tests.Base.TestNonEmpty
import Tests.Base.TestEither
import Tests.Base.TestOrd
import Tests.Base.TestTuple
import Tests.Base.TestFoldable
import Tests.Base.TestTraversable
import Tests.Base.TestRatio
import Tests.Base.TestComplex
import Tests.Base.TestFixed
import Tests.Base.TestArrow
import Tests.Control.TestMVar
import Tests.Control.TestChan
import Tests.Control.TestQSem
import Tests.Control.TestQSemN
import Tests.Control.TestConcurrent

open Tests

def main : IO UInt32 := do
  let mut totalFailures : Nat := 0

  let suites : List (String × List TestResult) :=
    [ ("Void",          TestVoid.tests)
    , ("Function",      TestFunction.tests)
    , ("Newtype",       TestNewtype.tests)
    , ("Bifunctor",     TestBifunctor.tests)
    , ("Contravariant", TestContravariant.tests)
    , ("Const",         TestConst.tests)
    , ("Identity",      TestIdentity.tests)
    , ("Compose",       TestCompose.tests)
    , ("Category",      TestCategory.tests)
    , ("NonEmpty",      TestNonEmpty.tests)
    , ("Either",        TestEither.tests)
    , ("Ord",           TestOrd.tests)
    , ("Tuple",         TestTuple.tests)
    , ("Foldable",      TestFoldable.tests)
    , ("Traversable",   TestTraversable.tests)
    , ("Ratio",         TestRatio.tests)
    , ("Complex",       TestComplex.tests)
    , ("Fixed",         TestFixed.tests)
    , ("Arrow",         TestArrow.tests)
    ]

  for (name, tests) in suites do
    let failures ← runTests name tests
    totalFailures := totalFailures + failures

  -- Phase 6: Concurrent IO test suites
  let ioSuites : List (String × IO (List TestResult)) :=
    [ ("MVar",       TestMVar.tests)
    , ("Chan",       TestChan.tests)
    , ("QSem",       TestQSem.tests)
    , ("QSemN",      TestQSemN.tests)
    , ("Concurrent", TestConcurrent.tests)
    ]

  for (name, testsIO) in ioSuites do
    let failures ← runIOTests name testsIO
    totalFailures := totalFailures + failures

  IO.println ""
  if totalFailures == 0 then
    IO.println s!"All tests passed!"
    return 0
  else
    IO.println s!"{totalFailures} test(s) failed."
    return 1
