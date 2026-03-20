#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "═══ lean-std cross-check suite ═══"
echo ""

total_pass=0
total_fail=0

for script in check-*.sh; do
  if bash "$script"; then
    total_pass=$((total_pass+1))
  else
    total_fail=$((total_fail+1))
  fi
  echo ""
done

echo "═══ Summary: $total_pass suites passed, $total_fail suites failed ═══"
[ "$total_fail" -eq 0 ]
