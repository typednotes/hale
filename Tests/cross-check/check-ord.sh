#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.."
echo "Cross-check: Ord"
LEAN=$(lake exe lean-std 2>/dev/null)
pass=0; fail=0
# Down(3) vs Down(7) should give gt (reversed)
if echo "$LEAN" | grep -q "compare Down(3) Down(7) = .*gt\|Ordering.gt"; then
  echo "  PASS: Down reverses"
  pass=$((pass+1))
else
  echo "  FAIL: Down reverses"
  fail=$((fail+1))
fi
echo "  $pass passed, $fail failed"
exit $fail
