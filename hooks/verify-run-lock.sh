#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
LOCK="$ROOT/_LOGS/.run-lock"
if [ -f "$LOCK" ]; then
  LOCK_AGE_SEC=$(( $(date +%s) - $(stat -f %m "$LOCK" 2>/dev/null || stat -c %Y "$LOCK") ))
  if [ "$LOCK_AGE_SEC" -lt 21600 ]; then
    echo "VIOLATION: fresh run-lock present ($LOCK_AGE_SEC s old) — another mutating skill is active on this root" >&2
    exit 1
  fi
fi
exit 0
