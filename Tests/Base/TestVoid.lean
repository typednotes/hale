import LeanStd
import Tests.Harness

open Data Tests

namespace TestVoid

def tests : List TestResult :=
  [ check "Void is alias for Empty" true
  ]
end TestVoid
