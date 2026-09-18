---
name: folder-undo
description: Reverses the most recent logged run per _LOGS/activity-log.md. Skips blocked reversals (collision, unmounted volume, superseded). Never deletes. Trigger on "undo", "reverse that", "put it back".
---

# Foldero — Undo

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Reverse the last logged run. Because every suite move is a reversible `mv` recorded per `references/Undo-Rules.md`, a run can be walked backwards.
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## Dependencies & STOP conditions

- Requires `CLAUDE.md`, `INDEX.md`, and `_LOGS/activity-log.md` at the root. STOP if `activity-log.md` is missing or has no run to reverse.
- Acquire the run-lock (§13); release at the end.
- Confirm scope with the user before moving anything. Undo is mutating — show what will be reversed and get a go-ahead in every mode.
- **Every mutating pass writes a Report** per SUITE-CONVENTIONS §9.

## Procedure

### 1. Identify the target run
Default to the **most recent** run block in `_LOGS/activity-log.md` (execute / inbox / import / deepen / dedupe / signoff / review / tag). If the user names a specific dated run, use that. Read its ordered list of `source → destination` entries plus any REVIEW-SORT/REVIEW-TRASH routings and renames.

### 2. Build the reversal plan
For each entry, apply the reversibility invariants in `references/Undo-Rules.md` §1:
- Destination unchanged since original move.
- Source path free.
- Atomic unit whole (per `references/Atomic-Unit-Signatures.md`).
- Source volume mounted (imports only).
- Within reversibility window (default 30 days; older → confirm).

Reverse in **reverse order** of the original run so nested and dependent moves unwind cleanly. Atomic units reverse whole. Present the plan (count, notable items, anything not cleanly reversible) and confirm.

### 3. Pre-flight checks
For each entry verify item at destination, source path free. Skip (do not force) any entry failing an invariant, per `references/Undo-Rules.md` §3 skip reasons.

**Pre-schema entries (`reversible: unknown`):** entries written before the `Undo-Rules.md` §2 schema was in force do not carry the `reversible:` field. Per `references/Undo-Rules.md` §5a, treat these as `reversible: unknown` — never as `yes` and never as `no` by default. Surface each such entry to the user with its recorded source and destination, state that the entry predates the reversibility schema, and require explicit per-entry confirmation before executing the reverse. Skip on user decline; on confirm, apply the normal invariant checks from §2 above (destination-unchanged, source-path-free, atomic-unit-whole). Record the outcome in the Undo-Report as `reversed: user-confirmed-pre-schema`, `skipped: user-declined-pre-schema`, or one of the standard skip reasons if an invariant fails on its own.

### 4. Reverse
Execute each safe reversal as a verified `mv` per `references/Collision-Handling.md` — never overwrite.

- **Imports:** reversing a Copy import removes the imported copy from the receiving folder (source untouched, permitted, logged). Reversing a Move import restores to the recorded source path (with volume name); if volume not mounted, STOP for that item and report.
- **REVIEW-TRASH / REVIEW-SORT routings** reverse the same way.
- **CONFIRMED-TRASH routings are NOT reversible** per `references/Undo-Rules.md` §5 — the user explicitly confirmed; reversing would contradict the confirmation.
- **Sign-off approvals** are not reversed here — those require re-running `/folder-signoff`.

### 5. Restore documents
Roll back the INDEX Taxonomy/Activity changes the run made (or re-derive INDEX from the actual post-undo tree). Append an **undo entry** to `_LOGS/activity-log.md` recording what was reversed and what was skipped, per `references/Undo-Rules.md` §2 schema (action: `revert-mv` / `revert-copy`). Do not touch `CLAUDE.md` rules.

## Output

Write `Undo-Report-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`: reversed items · skipped items with reasons · awaiting-user follow-ups. Companion migration CSV per `references/Migration-CSV-Schema.md`. Release the run-lock.

## Guarantees

Never deletes user content (the only removals are suite-created import *copies*, explicitly logged). Never overwrites — a reversal that would collide is skipped and reported. Leaves the folder in a consistent, described state even on partial undo.

## References

- `references/Undo-Rules.md` — primary consumer; reversibility invariants, required fields, skip reasons, partial-undo behaviour, what is NOT reversible by design.
- `references/Atomic-Unit-Signatures.md` — atomic units reverse whole.
- `references/Collision-Handling.md` — `(revert)` suffix on reversal collision.
- `references/Migration-CSV-Schema.md` — `revert-mv` / `revert-copy` action values.
- `references/Report-Templates.md` — Undo-Report format.

## Cross-references

- Requires: `_LOGS/activity-log.md` with a run to reverse (from any mutating skill).
- Produces: `_LOGS/Undo-Report-…md` + migration CSV; updates INDEX + `_LOGS/activity-log.md`.

## Tested against

_(fill in after first use: run type reversed, skips, outcome.)_
