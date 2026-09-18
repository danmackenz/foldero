#!/usr/bin/env bash
set -euo pipefail
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/lib-mv-parse.sh"
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0
extract_mv_args "$COMMAND"
if [ -z "$MV_SRC" ] || [ -z "$MV_DST" ]; then
  exit 0   # not a recognisable mv at all — nothing to gate against the sign-off queue
fi
ROOT=$(find_managed_root "$MV_SRC")
if [ -z "$ROOT" ]; then
  REASON="verify-signoff-gate.sh could not determine the managed root for '$MV_SRC' — blocking by default (SUITE-CONVENTIONS §5 fails closed on ambiguity, unlike §12/§13)."
  jq -n --arg reason "$REASON" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
  exit 0
fi
INDEX="$ROOT/INDEX.md"
[ -f "$INDEX" ] || exit 0
# flag-based extraction, not an awk range pattern — the range form `/start/,/end/` closes
# immediately here because the start line itself also matches the end pattern
if ! awk '/^## Awaiting sign-off/{flag=1; next} /^## /{flag=0} flag' "$INDEX" | grep -qF "$MV_SRC"; then
  exit 0
fi
MARKER="$ROOT/_LOGS/.signoff-approved-$(basename "$MV_SRC" | tr -c '[:alnum:]' '_')"
if [ -f "$MARKER" ]; then
  MARKER_AGE_SEC=$(( $(date +%s) - $(stat -f %m "$MARKER" 2>/dev/null || stat -c %Y "$MARKER") ))
  [ "$MARKER_AGE_SEC" -lt 60 ] && exit 0
fi
REASON="$MV_SRC is still queued in Awaiting sign-off (SUITE-CONVENTIONS §5) — only /folder-signoff may move it, and only with a fresh approved-for-move marker."
jq -n --arg reason "$REASON" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
exit 0
