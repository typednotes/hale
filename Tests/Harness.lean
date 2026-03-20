/-
  Tests.Harness — Minimal test framework for lean-std
-/
namespace Tests

structure TestResult where
  name : String
  passed : Bool
  message : String := ""
  deriving Repr

def check (name : String) (cond : Bool) (msg : String := "") : TestResult :=
  { name, passed := cond, message := if cond then "" else if msg.isEmpty then "assertion failed" else msg }

def checkEq [BEq α] [ToString α] (name : String) (expected actual : α) : TestResult :=
  let passed := expected == actual
  { name, passed,
    message := if passed then "" else s!"expected {expected}, got {actual}" }

def runTests (suiteName : String) (tests : List TestResult) : IO Nat := do
  IO.println s!"── {suiteName} ──"
  let mut failures := 0
  for t in tests do
    if t.passed then
      IO.println s!"  PASS: {t.name}"
    else
      IO.println s!"  FAIL: {t.name} — {t.message}"
      failures := failures + 1
  pure failures

end Tests
