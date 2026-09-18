#!/usr/bin/env bash
set -euo pipefail
CMD="${1:-}"
if echo "$CMD" | grep -qE '(^|[[:space:]&;|])(rm|rmdir|unlink|git[[:space:]]+rm|find[[:space:]].*-delete)([[:space:]]|$)'; then
  echo "VIOLATION: hard-delete command blocked — Foldero never hard-deletes (SUITE-CONVENTIONS §1). Use REVIEW-TRASH instead." >&2
  exit 1
fi
exit 0
