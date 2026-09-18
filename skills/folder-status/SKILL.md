---
name: folder-status
description: Read-only multi-root health dashboard. Per folder: last run, backlogs, sign-off queue, lock, last lint, detected archetype. Trigger on "status of my folders", "health check across folders", "all my managed folders".
---

# Foldero — Status

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Read-only cross-folder dashboard. Aggregates the state of every managed folder into a single readable snapshot.
**Shared rules:** `references/SUITE-CONVENTIONS.md`. Exempt from the run-lock (§13) because read-only.

## Dependencies & STOP conditions

- Works on any folder(s) with the suite artifacts (`CLAUDE.md`, `INDEX.md`, `_LOGS/`). Folders without those are skipped with a one-line note.
- No run-lock acquired (§13, §14).
- Never modifies any file.

## Procedure

1. **Determine scope** — the user names a folder or a list of folders, or asks for "all my managed folders" (in which case scan every root the caller has visibility into and check for `CLAUDE.md` + `INDEX.md` + `_LOGS/` as the suite-managed marker).
2. **Per folder, gather** (no writes, no locks):
   - **Last run:** most recent entry in `_LOGS/activity-log.md` with skill name and date.
   - **REVIEW-SORT count:** items in `00. Inbox/REVIEW-SORT/` (excluding `_MANIFEST.md`).
   - **REVIEW-TRASH count:** items in `00. Inbox/REVIEW-TRASH/` (excluding `_MANIFEST.md`).
   - **CONFIRMED-TRASH count** (if present): items in `00. Inbox/CONFIRMED-TRASH/`.
   - **Awaiting sign-off count:** entries in INDEX's `Awaiting sign-off` section.
   - **Run-lock status:** `_LOGS/.run-lock` present? Fresh (<6h) or stale?
   - **Orchestrator lock status** (if present): `_LOGS/.orchestrator-lock` fresh or stale.
   - **Released-marker count:** if >10, flag for consolidation per `docs/runbooks/marker-rotation.md`.
   - **Last lint date:** newest `_LOGS/Lint-Report-*.md` mtime (or "never").
   - **Detected archetype:** based on `references/Enterprise-Domain-Archetypes.md` §3 heuristics applied to the folder's current top level. Reported as a signal, not a fixed classification.
   - **Numbering drift indicator:** does the folder's top-level match its own `CLAUDE.md`'s recorded numbering rules? Defers to `references/Numbering-Convention-Rules.md`.
3. **Compose dashboard.** One row per folder, most-attention-needed first (unresolved sign-off > stale lock > large review backlog > everything else).

## Output

Write `Status-Report-[DATE].md` to `_LOGS/` of the caller's choice per `references/Report-Templates.md`: Root Path | Last Run Type/Date | REVIEW-SORT | REVIEW-TRASH | Sign-off | Lock Status | Last Lint | Detected Archetype.

## References

- `references/Numbering-Convention-Rules.md` — drift indicator; this skill defers entirely to the reference, doesn't re-derive rules.
- `references/Enterprise-Domain-Archetypes.md` — archetype detection heuristics.
- `references/Report-Templates.md` — Status-Report column structure.
- `docs/runbooks/marker-rotation.md` — remediation for released-marker accumulation.

## Cross-references

- Complement: `/folder-lint` (single-folder deep validator, also read-only).
- **Run-lock exempt** per §13.
- The router `/foldero` sends multi-root / "all my folders" queries here.

## Tested against

- 2026-09-17 · v1.0 live smoke test on a managed folder: dashboard row correct against expected findings; matched real state.
