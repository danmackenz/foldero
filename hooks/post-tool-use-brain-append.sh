#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-}"
SKILL="${2:-unknown}"
DECISION="${3:-}"
CONFIDENCE="${4:-}"
MANAGED_ROOT="${5:-}"   # nearest registered managed root, passed by the calling skill; empty if none registered
BRAIN="$ROOT/BRAIN.md"
[ -f "$BRAIN" ] || exit 0

# 1. Append this folder's own leaf entry.
{
  echo ""
  echo "### $(date -u +%Y-%m-%dT%H:%M:%SZ) — $SKILL"
  echo "- decision: $DECISION"
  echo "- confidence: $CONFIDENCE"
} >> "$BRAIN"

# 2. Walk ancestors, updating each one's child-rollup table row for $ROOT (or leaving
#    each ancestor's own dated log untouched — rollup rows only, per SUITE-CONVENTIONS §18).
TAXONOMY_VERSION=$(grep -m1 '^taxonomy-version:' "$BRAIN" | cut -d: -f2- | xargs || echo "unknown")
LATEST_DECISION="$DECISION"
OPEN_FLAGS=$(grep -c '^- flag:' "$BRAIN" 2>/dev/null || true)
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
CHILD="$ROOT"
DIR="$(dirname "$ROOT")"
STOPPED_AT=""
while :; do
  if [ -n "$MANAGED_ROOT" ] && [ "$CHILD" = "$MANAGED_ROOT" ]; then
    STOPPED_AT="managed-root:$MANAGED_ROOT"
    break
  fi
  if [ "$DIR" = "/" ] || [ "$DIR" = "$CHILD" ]; then
    STOPPED_AT="filesystem-root:$DIR"
    break
  fi
  ANCESTOR_BRAIN="$DIR/BRAIN.md"
  if [ ! -w "$DIR" ]; then
    STOPPED_AT="permission-denied:$DIR"
    break
  fi
  [ -f "$ANCESTOR_BRAIN" ] || touch "$ANCESTOR_BRAIN"
  # Update (not append) this child's row in the ancestor's rollup table — a single
  # in-place row update, legitimate per §D.4 since it's a status table, not a history.
  ROLLUP_LINE="| $CHILD | $TAXONOMY_VERSION | $LATEST_DECISION | $OPEN_FLAGS | $NOW |"
  if grep -q "^| $CHILD |" "$ANCESTOR_BRAIN" 2>/dev/null; then
    sed -i.bak "s|^| $CHILD |.*|$ROLLUP_LINE|" "$ANCESTOR_BRAIN" && rm -f "$ANCESTOR_BRAIN.bak"
  else
    echo "$ROLLUP_LINE" >> "$ANCESTOR_BRAIN"
  fi
  CHILD="$DIR"
  DIR="$(dirname "$DIR")"
done

echo "BRAIN.md rollup stopped at: $STOPPED_AT" >&2
exit 0
