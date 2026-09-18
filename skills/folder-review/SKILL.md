---
name: folder-review
description: Interactive REVIEW-SORT/REVIEW-TRASH resolver. Routes confirmed junk to CONFIRMED-TRASH. Tier-3 items redirect to /folder-signoff. Trigger on "review the sort queue", "process REVIEW-SORT", "clear the review backlog".
---

# Foldero — Review Queue Resolver

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Human-in-the-loop resolver for the already-classified-and-flagged queues. Where flagged items get their final disposition.
**Shared rules:** `references/SUITE-CONVENTIONS.md`. Boundary partner of `/folder-inbox` per §15.

## Dependencies & STOP conditions

- Requires `CLAUDE.md`, `INDEX.md`, `_LOGS/`, and at least one populated `REVIEW-SORT` or `REVIEW-TRASH` queue. STOP if the folder isn't set up. If both queues are empty, tell the user and stop.
- **Acquire the run-lock** (§13); STOP if another run holds a fresh lock; release at the end.
- **Never touches Tier 3 items.** If any queued item is Tier 3 (`SENS:RESTRICTED-DOMAIN`), redirect the user to `/folder-signoff` — do not review it here.
- **Every mutating pass writes a Report** per SUITE-CONVENTIONS §9 — this skill always writes a dated Review-Report even for zero-move runs.

## Procedure

### 1. Read the queues
Parse `_MANIFEST.md` in both `REVIEW-SORT/` and `REVIEW-TRASH/`. Read flagging reasons alongside each item.

### 2. Present one item at a time
For each: item name, source path, reason flagged, and available dispositions.

**From `REVIEW-SORT`:**
- **File** — into a taxonomy pillar; user names or approves the destination.
- **Keep in place** — return to a pillar unchanged.
- **Move to CONFIRMED-TRASH** — user explicitly deciding it's junk.
- **Back to queue** — skip for now.

**From `REVIEW-TRASH`:**
- **CONFIRMED-TRASH** — user confirms disposable.
- **Rescue** — move back into a pillar.
- **Back to queue** — skip.

### 3. "Why was this flagged?"
If the user asks, re-apply `references/File-Type-Heuristics.md` and cite the specific rule the item matched. The manifest reason line should trace back to one of those bullets.

### 4. Cross-brand ambiguity items
When the flagging reason cites cross-brand ambiguity (two or more candidate brands with comparable confidence, per `/folder-plan`'s ambiguity resolver):
- Present the specific overlapping signal and both candidate brands from the manifest.
- Offer: File into Brand A · File into Brand B · Redefine the ambiguity (add a distinguishing rule to the user's `Brand-Taxonomy-Reference.md`, via `/organisation-setup` re-run) · Back to queue.
- **Sensitivity precedence:** if one candidate is Tier 3, decline to route into the non-Tier-3 candidate here — redirect to `/folder-signoff` as a Tier 3 item pending user resolution.

### 5. Atomic units are single decisions
Per `references/Atomic-Unit-Signatures.md` §6, an atomic unit in the review queue is resolved as one move — never partially filed, never descended into.

### 6. Execute the decision
`mv` to the chosen destination (pillar path, `CONFIRMED-TRASH/`, or back to the previous pillar). Verify (source gone AND destination present). Never overwrite — collisions handled per `references/Collision-Handling.md`.

### 7. CONFIRMED-TRASH mechanics
Create `00. Inbox/CONFIRMED-TRASH/` if missing. Move the item whole. This is a terminal user-decided state — the suite still never deletes, but the user has confirmed disposal is intended and may delete manually.

### 8. Update documents
Remove resolved entries from `_MANIFEST.md`. Append to INDEX's `Activity` section and `_LOGS/activity-log.md` per `references/Undo-Rules.md` §2 (reversibility schema).

## Output

Write `Review-Report-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`: Item | Source Queue | User Decision | Final Disposition (Pillar / KEEP-IN-PLACE / CONFIRMED-TRASH / back to queue). Release the run-lock.

## References

- `references/File-Type-Heuristics.md` — re-applied when the user asks "why was this flagged?"; the manifest reason should trace to one of these rules.
- `references/Atomic-Unit-Signatures.md` — atomic unit in REVIEW-SORT is resolved as a single move decision.
- `references/Report-Templates.md` — Review-Report column structure.
- `references/Collision-Handling.md` — suffix conventions on file-into-pillar collisions.
- `references/Undo-Rules.md` — activity-log entries carry the reversibility schema.
- Tier 3 items → redirect to `/folder-signoff`.

## Cross-references

- Requires: `CLAUDE.md` + `INDEX.md` + `_LOGS/` + populated REVIEW-SORT/REVIEW-TRASH. Produces: `_LOGS/Review-Report-…md`; updates `_MANIFEST.md` + INDEX + `_LOGS/activity-log.md`. Reversible via `/folder-undo`.
- **Boundary partner:** `/folder-inbox` handles NEW items in `00. Inbox`; this skill handles ALREADY-FLAGGED items in the REVIEW queues (§15).
- Tier 3 items redirect to `/folder-signoff`.

## Tested against

_(fill in after first use: queue processed, decisions taken, CONFIRMED-TRASH count, outcome.)_
