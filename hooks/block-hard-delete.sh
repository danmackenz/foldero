#!/usr/bin/env bash
set -euo pipefail
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0
if echo "$COMMAND" | grep -qE '(^|[[:space:]&;|])(rm|rmdir|unlink|git[[:space:]]+rm|find[[:space:]].*-delete)([[:space:]]|$)'; then
  jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Hard-delete command blocked — Foldero never hard-deletes (SUITE-CONVENTIONS §1). Use REVIEW-TRASH instead."}}'
fi
exit 0
