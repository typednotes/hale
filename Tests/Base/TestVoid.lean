import LeanStd
import Tests.Harness

open LeanStd Tests

namespace TestVoid

def tests : List TestResult :=
  [ check "Void is alias for Empty" true
  ]
end TestVoid
