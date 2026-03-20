#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.."
echo "Cross-check: Newtypes"
# Compare key computed values
LEAN=$(lake exe lean-std 2>/dev/null)
lean_sum=$(echo "$LEAN" | grep "^Sum:" | sed 's/.*= //')
lean_prod=$(echo "$LEAN" | grep "^Product:" | sed 's/.*= //')
lean_all=$(echo "$LEAN" | grep "^All:" | sed 's/.*= //')
lean_any=$(echo "$LEAN" | grep "^Any:" | sed 's/.*= //')

pass=0; fail=0
# Sum 3+4=7
if [[ "$lean_sum" == *"7"* ]]; then
  echo "  PASS: Sum"
  pass=$((pass+1))
else
  echo "  FAIL: Sum (got $lean_sum)"
  fail=$((fail+1))
fi
if [[ "$lean_prod" == *"12"* ]]; then
  echo "  PASS: Product"
  pass=$((pass+1))
else
  echo "  FAIL: Product (got $lean_prod)"
  fail=$((fail+1))
fi
if [[ "$lean_all" == *"false"* ]]; then
  echo "  PASS: All"
  pass=$((pass+1))
else
  echo "  FAIL: All (got $lean_all)"
  fail=$((fail+1))
fi
if [[ "$lean_any" == *"true"* ]]; then
  echo "  PASS: Any"
  pass=$((pass+1))
else
  echo "  FAIL: Any (got $lean_any)"
  fail=$((fail+1))
fi
echo "  $pass passed, $fail failed"
exit $fail
