#!/usr/bin/env bash
# ponytail: shells out per-move rather than batching; fine at Foldero's per-run item counts, revisit if a single run routinely moves 1000+ items.
set -euo pipefail
SRC="$1"
DST="$2"
if [ -e "$SRC" ]; then
  echo "VIOLATION: source still present after move: $SRC" >&2
  exit 1
fi
if [ ! -e "$DST" ]; then
  echo "VIOLATION: destination missing after move: $DST" >&2
  exit 1
fi
exit 0
