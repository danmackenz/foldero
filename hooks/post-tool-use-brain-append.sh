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
[ -z "$ROOT" ] && exit 0
STAGING="$ROOT/_LOGS/.pending-brain-entry"
[ -f "$STAGING" ] || exit 0

SKILL=$(jq -r '.skill // "unknown"' "$STAGING" 2>/dev/null || echo unknown)
DECISION=$(jq -r '.decision // ""' "$STAGING" 2>/dev/null || echo "")
CONFIDENCE=$(jq -r '.confidence // ""' "$STAGING" 2>/dev/null || echo "")
rm -f "$STAGING"

BRAIN="$ROOT/BRAIN.md"
[ -f "$BRAIN" ] || exit 0

# 1. Append this folder's own leaf entry.
{
  echo ""
  echo "### $(date -u +%Y-%m-%dT%H:%M:%SZ) — $SKILL"
  echo "- decision: $DECISION"
  echo "- confidence: $CONFIDENCE"
} >> "$BRAIN"

# 2. Walk ancestors, updating each one's child-rollup table row for $ROOT — awk-based,
#    not sed, avoiding both the `&`-as-replacement-metacharacter risk and the `|`-as-
#    sed-delimiter collision a prior draft had (ROLLUP_LINE is itself pipe-delimited).
TAXONOMY_VERSION=$(grep -m1 '^taxonomy-version:' "$BRAIN" | cut -d: -f2- | xargs || echo "unknown")
LATEST_DECISION="$DECISION"
OPEN_FLAGS=$(grep -c '^- flag:' "$BRAIN" 2>/dev/null || true)
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
CHILD="$ROOT"
WALK_DIR="$(dirname "$ROOT")"
STOPPED_AT=""
while :; do
  if [ "$WALK_DIR" = "/" ] || [ "$WALK_DIR" = "$CHILD" ]; then
    STOPPED_AT="filesystem-root:$WALK_DIR"
    break
  fi
  if [ ! -w "$WALK_DIR" ]; then
    STOPPED_AT="permission-denied:$WALK_DIR"
    break
  fi
  ANCESTOR_BRAIN="$WALK_DIR/BRAIN.md"
  if [ ! -f "$ANCESTOR_BRAIN" ]; then
    STOPPED_AT="unmanaged-ancestor:$WALK_DIR"
    break
  fi
  ROLLUP_LINE="| $CHILD | $TAXONOMY_VERSION | $LATEST_DECISION | $OPEN_FLAGS | $NOW |"
  awk -v child="$CHILD" -v newline="$ROLLUP_LINE" '
    BEGIN{done=0}
    index($0, "| " child " |") == 1 {print newline; done=1; next}
    {print}
    END{if (!done) print newline}
  ' "$ANCESTOR_BRAIN" > "$ANCESTOR_BRAIN.tmp" && mv "$ANCESTOR_BRAIN.tmp" "$ANCESTOR_BRAIN"
  CHILD="$WALK_DIR"
  WALK_DIR="$(dirname "$WALK_DIR")"
done

echo "BRAIN.md rollup stopped at: $STOPPED_AT" >&2
exit 0
