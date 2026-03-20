#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.."
echo "Cross-check: NonEmpty"
LEAN=$(lake exe lean-std 2>/dev/null)
pass=0; fail=0
if echo "$LEAN" | grep -q "head: 1"; then
  echo "  PASS: head"
  pass=$((pass+1))
else
  echo "  FAIL: head"
  fail=$((fail+1))
fi
if echo "$LEAN" | grep -q "last: 5"; then
  echo "  PASS: last"
  pass=$((pass+1))
else
  echo "  FAIL: last"
  fail=$((fail+1))
fi
if echo "$LEAN" | grep -q "length: 5"; then
  echo "  PASS: length"
  pass=$((pass+1))
else
  echo "  FAIL: length"
  fail=$((fail+1))
fi
echo "  $pass passed, $fail failed"
exit $fail
