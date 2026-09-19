---
name: folder-handoff
description: Read-only. Packages current folder state (open REVIEW-SORT/TRASH items, awaiting sign-off, recommended next skills) for handoff to another person or tool. Trigger on "prepare a handoff", "brief someone on this folder's state".
---

# Foldero — Handoff

**Version:** v1.0 · Last modified 2026-09-17
**Role:** Standalone read-only skill that packages the current state of a managed folder into a single handoff summary intended for another person or another tool/automation picking up work on this folder next.
**Shared rules:** `references/SUITE-CONVENTIONS.md`. Exempt from the run-lock (§13) because read-only.

## Distinction from `/folder-blueprint`

- `/folder-blueprint` documents the **system** — the taxonomy and conventions. Timeless.
- `/folder-handoff` documents the **current open state and next actions** — what's in the queues, what needs doing, who to escalate what to. Snapshot.

Both are read-only, but they serve different audiences.

## Dependencies & STOP conditions

- Requires the managed folder to have `CLAUDE.md`, `INDEX.md`, `_LOGS/`. STOP if any is missing.
- No run-lock acquired.
- Never modifies any file.

## Procedure

1. **Read INDEX.md** — Taxonomy section (current shape), Awaiting sign-off section (Tier 3 items pending), Activity section (recent moves).
2. **Read `00. Inbox/REVIEW-SORT/_MANIFEST.md`** — list flagged items with reasons.
3. **Read `00. Inbox/REVIEW-TRASH/_MANIFEST.md`** — list disposable candidates with reasons.
4. **Read `_LOGS/activity-log.md` tail** — the most recent run and any patterns in recent activity.
5. **Compose the handoff document** with these sections:

   - **Current State** — one paragraph: the folder is X, has Y taxonomy, last touched by Z on <date>.
   - **Open Items Requiring Decision** — a bullet list pulling from REVIEW-SORT / REVIEW-TRASH / Awaiting-sign-off, with per-item reason and suggested route.
   - **Recommended Next Skill(s) To Run** — inferred from the open-items list (e.g. many REVIEW-SORT items → `/folder-review`; large sign-off backlog → `/folder-signoff`; new arrivals in `00. Inbox` → `/folder-inbox`).
   - **Anything Time-Sensitive** — released-lock accumulation crossing threshold, unresolved orchestrator checkpoints >24h old, sign-off items awaiting weeks, etc.
   - **How to continue** — a short "if you're picking this up" section pointing to `/folder-status` for the numeric snapshot and `/folder-blueprint` for the system SOP.

6. **Optional — cross-tree open items.** Only if this folder's own `BRAIN.md` has a non-empty child-rollup table (SUITE-CONVENTIONS §18): add a **Cross-tree open items** section, aggregating each direct child's open-flag count straight from the rollup table (no descending into any child's own `BRAIN.md`) — consistent with Handoff's existing "current open state" framing. Skip this section entirely when there's no rollup table to show; this never changes the default output for a leaf-shaped or unmanaged folder.

## Output

Write `Handoff-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`.

## References

- `references/Report-Templates.md` — Handoff format.
- `references/Undo-Rules.md` — for annotating whether the most recent run is still reversible in the "recent activity" summary.

## Cross-references

- Complements: `/folder-status` (numeric dashboard), `/folder-blueprint` (system SOP), `/folder-changelog` (full history).
- Requires: `CLAUDE.md` + `INDEX.md` + `_LOGS/`. Produces: `_LOGS/Handoff-…md`.
- **Run-lock exempt** per §13.

## Tested against

_(fill in after first use: folder state at time of handoff, sections included, outcome.)_
