#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.."
echo "Cross-check: Ratio"
LEAN=$(lake exe lean-std 2>/dev/null)
pass=0; fail=0
if echo "$LEAN" | grep -q "1/2 + 1/3 = 5/6"; then
  echo "  PASS: add"
  pass=$((pass+1))
else
  echo "  FAIL: add"
  fail=$((fail+1))
fi
if echo "$LEAN" | grep -q "1/2 \* 1/3 = 1/6"; then
  echo "  PASS: mul"
  pass=$((pass+1))
else
  echo "  FAIL: mul"
  fail=$((fail+1))
fi
if echo "$LEAN" | grep -q "floor(5/3) = 1"; then
  echo "  PASS: floor"
  pass=$((pass+1))
else
  echo "  FAIL: floor"
  fail=$((fail+1))
fi
if echo "$LEAN" | grep -q "ceil(5/3) = 2"; then
  echo "  PASS: ceil"
  pass=$((pass+1))
else
  echo "  FAIL: ceil"
  fail=$((fail+1))
fi
echo "  $pass passed, $fail failed"
exit $fail
