#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/../.."
echo "Cross-check: Either"
LEAN=$(lake exe lean-std 2>/dev/null)
pass=0; fail=0
if echo "$LEAN" | grep -q "map (+1) on Right 42:.*43"; then
  echo "  PASS: map"
  pass=$((pass+1))
else
  echo "  FAIL: map"
  fail=$((fail+1))
fi
if echo "$LEAN" | grep -q 'partitionEithers:.*lefts=\[.*a'; then
  echo "  PASS: partitionEithers"
  pass=$((pass+1))
else
  echo "  FAIL: partitionEithers"
  fail=$((fail+1))
fi
echo "  $pass passed, $fail failed"
exit $fail
