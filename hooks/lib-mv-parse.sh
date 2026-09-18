#!/usr/bin/env bash
# Sourced by verify-run-lock.sh, verify-signoff-gate.sh, verify-move-mechanics.sh,
# post-tool-use-brain-append.sh. Best-effort extraction from a `mv "src" "dst"` shell
# command string — Foldero's own skills always double-quote both paths (SUITE-CONVENTIONS
# §12). This is deliberately not a general shell parser: on anything it can't confidently
# parse, MV_SRC/MV_DST come back empty and callers decide fail-open vs. fail-closed.

extract_mv_args() {
  local cmd="$1"
  MV_SRC=""
  MV_DST=""
  echo "$cmd" | grep -qE '(^|[[:space:]&;|])mv([[:space:]]|$)' || return 0
  local quoted
  quoted=$(echo "$cmd" | grep -oE '"[^"]*"' || true)
  MV_SRC=$(echo "$quoted" | sed -n '1p' | sed -e 's/^"//' -e 's/"$//')
  MV_DST=$(echo "$quoted" | sed -n '2p' | sed -e 's/^"//' -e 's/"$//')
}

find_managed_root() {
  local p="$1"
  local dir
  dir="$(dirname "$p")"
  while [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -d "$dir/_LOGS" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 0
}
