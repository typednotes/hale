#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.."
echo "Cross-check: Complex"
LEAN=$(lake exe lean-std 2>/dev/null)
pass=0; fail=0
if echo "$LEAN" | grep -q "|z1|.*= 25"; then
  echo "  PASS: magnitudeSquared"
  pass=$((pass+1))
else
  echo "  FAIL: magnitudeSquared"
  fail=$((fail+1))
fi
echo "  $pass passed, $fail failed"
exit $fail
