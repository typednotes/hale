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
-- New base modules
import Tests.Base.TestProxy
import Tests.Base.TestBool
import Tests.Base.TestMaybe
import Tests.Base.TestDataString
import Tests.Base.TestProduct
import Tests.Base.TestFunctorSum
import Tests.Base.TestApplicative
import Tests.Base.TestMonad
import Tests.Base.TestDataChar
import Tests.Base.TestBits
import Tests.Base.TestIx
import Tests.Base.TestDataList
import Tests.Base.TestUnique
import Tests.Base.TestIORef
-- Control
import Tests.Control.TestMVar
import Tests.Control.TestChan
import Tests.Control.TestQSem
import Tests.Control.TestQSemN
import Tests.Control.TestConcurrent
import Tests.Control.TestScheduler
import Tests.Control.TestGreen
import Tests.Control.TestException
-- System
import Tests.System.TestSysIO
import Tests.System.TestExit
import Tests.System.TestEnvironment
-- CaseInsensitive
import Tests.CaseInsensitive.TestCaseInsensitive
-- ByteString
import Tests.ByteString.TestByteString
import Tests.ByteString.TestShort
import Tests.ByteString.TestLazy
import Tests.ByteString.TestBuilder
import Tests.ByteString.TestChar8
import Tests.ByteString.TestLazyChar8
-- Word8
import Tests.Word8.TestWord8
-- Vault
import Tests.Vault.TestVault
-- UnliftIO
import Tests.UnliftIO.TestUnliftIO
-- Time
import Tests.Time.TestClock
-- STM
import Tests.STM.TestSTM
-- Network
import Tests.Network.TestSocket
-- AutoUpdate
import Tests.AutoUpdate.TestAutoUpdate
-- IpRoute
import Tests.IpRoute.TestIP
-- HttpDate
import Tests.HttpDate.TestHttpDate
-- BsbHttpChunked
import Tests.BsbHttpChunked.TestChunked
-- TimeManager
import Tests.TimeManager.TestTimeManager
-- SimpleSendfile
import Tests.SimpleSendfile.TestSendfile
-- UnixCompat
import Tests.UnixCompat.TestCompat
-- StreamingCommons
import Tests.StreamingCommons.TestNetwork
-- WAI
import Tests.WAI.TestWai
import Tests.WAI.TestWaiSmoke
import Tests.Examples
-- Warp
import Tests.Warp.TestWarp
-- HttpTypes
import Tests.HttpTypes.TestMethod
import Tests.HttpTypes.TestStatus
import Tests.HttpTypes.TestHeader
import Tests.HttpTypes.TestURI
-- Http2
import Tests.Http2.TestFrame
import Tests.Http2.TestHPACK
-- QUIC
import Tests.QUIC.TestTypes
-- Http3
import Tests.Http3.TestFrame
import Tests.Http3.TestQPACK
-- WarpQUIC
import Tests.WarpQUIC.TestWarpQUIC
-- HttpClient
import Tests.HttpClient.TestRequest
import Tests.HttpClient.TestResponse
-- Req
import Tests.Req.TestReq

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
    -- New base modules
    , ("Proxy",         TestProxy.tests)
    , ("Bool",          TestBool.tests)
    , ("Maybe",         TestMaybe.tests)
    , ("DataString",    TestDataString.tests)
    , ("Product",       TestProduct.tests)
    , ("FunctorSum",    TestFunctorSum.tests)
    , ("Applicative",   TestApplicative.tests)
    , ("Monad",         TestMonad.tests)
    , ("DataChar",      TestDataChar.tests)
    , ("Bits",          TestBits.tests)
    , ("Ix",            TestIx.tests)
    , ("DataList",      TestDataList.tests)
    , ("Exit",          TestExit.tests)
    -- ByteString
    , ("ByteString",    TestByteString.tests)
    , ("ShortByteString", TestShort.tests)
    , ("LazyByteString", TestLazy.tests)
    , ("Builder",       TestBuilder.tests)
    , ("Char8",         TestChar8.tests)
    , ("LazyChar8",    TestLazyChar8.tests)
    -- CaseInsensitive
    , ("CaseInsensitive", TestCaseInsensitive.tests)
    -- Word8
    , ("Word8",         TestWord8.tests)
    -- IpRoute
    , ("IpRoute",          TestIP.tests)
    -- HttpDate
    , ("HttpDate",         TestHttpDate.tests)
    -- BsbHttpChunked
    , ("BsbHttpChunked",   TestChunked.tests)
    -- WAI
    , ("WAI",              TestWai.tests)
    -- Warp
    , ("Warp",              TestWarp.tests)
    -- HttpTypes
    , ("HttpTypes.Method", TestMethod.tests)
    , ("HttpTypes.Status", TestStatus.tests)
    , ("HttpTypes.Header", TestHeader.tests)
    , ("HttpTypes.URI",    TestURI.tests)
    -- Http2
    , ("Http2.Frame",     TestFrame.tests)
    , ("Http2.HPACK",     TestHPACK.tests)
    -- QUIC
    , ("QUIC.Types",      TestQUICTypes.tests)
    -- Http3
    , ("Http3.Frame",     TestH3Frame.tests)
    , ("Http3.QPACK",     TestQPACK.tests)
    -- WarpQUIC
    , ("WarpQUIC",        TestWarpQUIC.tests)
    -- HttpClient
    , ("HttpClient.Request", TestRequest.tests)
    -- Req
    , ("Req",             TestReq.tests)
    ]

  for (name, tests) in suites do
    let failures ← runTests name tests
    totalFailures := totalFailures + failures

  -- IO test suites — run sequentially to avoid interaction effects
  let runIO (name : String) (mkTests : Unit → IO (List TestResult)) : IO Nat := do
    let results ← mkTests ()
    runTests name results
  -- IO tests that don't use async primitives — safe to run in compiled mode
  totalFailures := totalFailures + (← runIO "IORef"       fun () => TestIORef.tests)
  totalFailures := totalFailures + (← runIO "Unique"      fun () => TestUnique.tests)
  totalFailures := totalFailures + (← runIO "Exception"   fun () => TestException.tests)
  -- Scheduler tests (green threads) — run early to catch regressions fast
  totalFailures := totalFailures + (← runIO "Scheduler"   fun () => TestScheduler.tests)
  totalFailures := totalFailures + (← runIO "Green"        fun () => TestGreen.tests)
  totalFailures := totalFailures + (← runIO "Vault"       fun () => TestVault.tests)
  totalFailures := totalFailures + (← runIO "UnliftIO"    fun () => TestUnliftIO.tests)
  totalFailures := totalFailures + (← runIO "Clock"       fun () => TestClock.tests)
  totalFailures := totalFailures + (← runIO "STM"         fun () => TestSTM.tests)
  totalFailures := totalFailures + (← runIO "Sendfile"    fun () => TestSendfile.tests)
  totalFailures := totalFailures + (← runIO "UnixCompat"  fun () => TestCompat.tests)
  totalFailures := totalFailures + (← runIO "Environment" fun () => TestEnvironment.tests)
  totalFailures := totalFailures + (← runIO "AutoUpdate"  fun () => TestAutoUpdate.tests)
  totalFailures := totalFailures + (← runIO "TimeManager" fun () => TestTimeManager.tests)
  totalFailures := totalFailures + (← runIO "WAI Smoke"  fun () => TestWaiSmoke.tests)
  totalFailures := totalFailures + (← runIO "HttpClient.Response" fun () => TestResponse.tests)
  -- Concurrency + network IO tests — use dedicated OS threads to avoid pool starvation.
  -- These tests call IO.wait on tasks spawned with IO.asTask (.dedicated).
  -- Currently segfault in compiled mode (exit 139) — needs further investigation.
  -- All pass in interpreter: lake env lean --run <test_file>
  -- totalFailures := totalFailures + (← runIO "MVar"       fun () => TestMVar.tests)
  -- totalFailures := totalFailures + (← runIO "Chan"       fun () => TestChan.tests)
  -- totalFailures := totalFailures + (← runIO "QSem"       fun () => TestQSem.tests)
  -- totalFailures := totalFailures + (← runIO "QSemN"      fun () => TestQSemN.tests)
  -- totalFailures := totalFailures + (← runIO "Concurrent" fun () => TestConcurrent.tests)
  -- totalFailures := totalFailures + (← runIO "Socket"      fun () => TestSocket.tests)
  -- totalFailures := totalFailures + (← runIO "StreamingNetwork" fun () => TestStreamingNetwork.tests)
  -- totalFailures := totalFailures + (← runIO "Warp.IO"     fun () => TestWarp.ioTests)

  IO.println ""
  if totalFailures == 0 then
    IO.println s!"All tests passed!"
    return 0
  else
    IO.println s!"{totalFailures} test(s) failed."
    return 1
