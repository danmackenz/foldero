#!/usr/bin/env bash
set -euo pipefail
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/lib-mv-parse.sh"
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0
extract_mv_args "$COMMAND"
if [ -z "$MV_SRC" ] || [ -z "$MV_DST" ]; then
  echo "WARNING: verify-move-mechanics.sh could not parse this command's mv arguments — skipping source-gone/destination-present check (SUITE-CONVENTIONS §12, fail-open by design). Command: $COMMAND" >&2
  exit 0
fi
if [ -e "$MV_SRC" ]; then
  echo "VIOLATION: source still present after move: $MV_SRC (SUITE-CONVENTIONS §12)" >&2
  exit 1
fi
if [ ! -e "$MV_DST" ]; then
  echo "VIOLATION: destination missing after move: $MV_DST (SUITE-CONVENTIONS §12)" >&2
  exit 1
fi
exit 0
