#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.."
echo "Cross-check: Fixed"
LEAN=$(lake exe lean-std 2>/dev/null)
pass=0; fail=0
if echo "$LEAN" | grep -q "Fixed 2:.*3.00.*1.57.*= 4.57"; then
  echo "  PASS: add"
  pass=$((pass+1))
else
  echo "  FAIL: add"
  fail=$((fail+1))
fi
echo "  $pass passed, $fail failed"
exit $fail
