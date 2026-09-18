#!/usr/bin/env bash
set -euo pipefail
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/lib-mv-parse.sh"
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0
extract_mv_args "$COMMAND"
[ -z "$MV_DST" ] && exit 0
ROOT=$(find_managed_root "$MV_DST")
if [ -z "$ROOT" ]; then
  echo "WARNING: verify-run-lock.sh could not determine the managed root for '$MV_DST' — skipping run-lock check (SUITE-CONVENTIONS §13, fail-open by design for this guarantee)." >&2
  exit 0
fi
LOCK="$ROOT/_LOGS/.run-lock"
if [ -f "$LOCK" ]; then
  LOCK_AGE_SEC=$(( $(date +%s) - $(stat -f %m "$LOCK" 2>/dev/null || stat -c %Y "$LOCK") ))
  if [ "$LOCK_AGE_SEC" -lt 21600 ]; then
    REASON="Fresh run-lock present (${LOCK_AGE_SEC}s old) at $ROOT — another mutating skill is active on this root (SUITE-CONVENTIONS §13)."
    jq -n --arg reason "$REASON" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
  fi
fi
exit 0
