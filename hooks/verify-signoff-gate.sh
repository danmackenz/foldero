#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
TARGET_PATH="${2:-}"
INDEX="$ROOT/INDEX.md"
MARKER="$ROOT/_LOGS/.signoff-approved-$(basename "$TARGET_PATH" | tr -c '[:alnum:]' '_')"
[ -f "$INDEX" ] || exit 0
# Not currently queued in Awaiting sign-off — nothing to gate.
awk '/^## Awaiting sign-off/{flag=1; next} /^## /{flag=0} flag' "$INDEX" | grep -qF "$TARGET_PATH" || exit 0
# Queued. Check for a fresh (< 60s) approved-for-move marker written by folder-signoff's own step 4.
if [ -f "$MARKER" ]; then
  MARKER_AGE_SEC=$(( $(date +%s) - $(stat -f %m "$MARKER" 2>/dev/null || stat -c %Y "$MARKER") ))
  if [ "$MARKER_AGE_SEC" -lt 60 ]; then
    exit 0
  fi
fi
echo "VIOLATION: $TARGET_PATH is still queued in Awaiting sign-off (SUITE-CONVENTIONS §5) — only /folder-signoff may move it, and only with a fresh approved-for-move marker." >&2
exit 1
