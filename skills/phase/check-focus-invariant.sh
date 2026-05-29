#!/usr/bin/env bash
# Check that at most one phase holds FOCUS status in the Phase Registry
# Usage: ./check-focus-invariant.sh [path/to/INDEX.md]
INDEX="${1:-docs/phase-status/INDEX.md}"
if [ ! -f "$INDEX" ]; then
  echo "ERROR: Phase Registry not found at $INDEX"
  exit 2
fi
count=$(grep -c "| FOCUS" "$INDEX" 2>/dev/null || echo 0)
if [ "$count" -gt 1 ]; then
  echo "VIOLATION: $count phases hold FOCUS (max 1 allowed)"
  grep "| FOCUS" "$INDEX"
  exit 1
else
  echo "OK: $count phase(s) hold FOCUS"
  exit 0
fi
