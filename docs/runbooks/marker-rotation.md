# Runbook — Released Run-Lock Marker Rotation

**Purpose:** Consolidate accumulated `_LOGS/.run-lock.released-*` markers once they exceed the threshold. `/folder-lint` flags them at 10+; this runbook is what to do when the flag surfaces.

**When to run:** After `/folder-lint` reports "Released run-lock markers: N accumulated (threshold 10 exceeded)" as a Warning.

**Skill involvement:** manual + `/folder-review` for the confirmation gate. `/folder-lint` never performs the consolidation itself.

---

## Background

Every mutating skill acquires `_LOGS/.run-lock` on start and releases it on end by renaming to `.run-lock.released-<timestamp>`. Some mounts refuse `rm`, so the released markers accumulate. Ten is fine; forty is cluttery.

Consolidation moves the accumulated released markers into a `_LOGS/lock-history/` sub-folder, preserving them (never-delete rule stands) but out of the top-level `_LOGS/` listing.

## Procedure

### 1. `/folder-lint` surfaces the Warning
The report line reads something like:
```
Check 4 (run-lock hygiene) — Warning — Released markers: 14 accumulated. Threshold: 10. Suggest consolidation via docs/runbooks/marker-rotation.md.
```

### 2. Decide whether to consolidate
This is user-territory, not automatic. Consolidation is fine at any point — the markers stay recoverable. Skip if you're actively debugging a series of runs and want the markers visible at the top level.

### 3. Consolidate
- Create `_LOGS/lock-history/` if it doesn't exist.
- Move every `.run-lock.released-*` marker into that sub-folder.
- Preserve filenames exactly (they encode the release timestamp).

Command sketch (bash, on the managed folder):
```bash
cd "<managed folder>/_LOGS"
mkdir -p lock-history
mv .run-lock.released-* lock-history/ 2>/dev/null || true
```

### 4. Verify
Re-run `/folder-lint`. The Warning should clear. If the count doesn't drop, check that the move succeeded and that no new mutating run has fired in the meantime (which would have created a fresh released marker).

### 5. Log the consolidation
Append a one-line entry to `_LOGS/activity-log.md`:
```
- consolidation: `.run-lock.released-*` markers → `_LOGS/lock-history/` [action: manifest-write] [confidence: n/a] [tier: none] [reversible: yes] [reason: /folder-lint threshold consolidation per docs/runbooks/marker-rotation.md]
```

Reversal (if needed) is `mv lock-history/.run-lock.released-* .` — same shape, opposite direction. Never a deletion.

## Do NOT

- `rm` any released marker. The never-delete rule (SUITE-CONVENTIONS §1) applies to suite artifacts too, even ones that outwardly look like housekeeping cruft.
- Consolidate active locks. Only `.run-lock.released-*` markers move. An active `.run-lock` (no `.released-` suffix) blocks concurrent runs and stays where it is until the owning skill releases it.

## Threshold rationale

10 markers ≈ enough activity to accumulate but still manageable at a glance. Below that, no action needed. Above that, the top-level listing gets noisy and future debug reads become harder. This is a cosmetic threshold, not a safety one — no data is at risk from accumulation, only readability.
