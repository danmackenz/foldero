---
name: folder-inbox
description: Sorts NEW arrivals in 00. Inbox into the established taxonomy per CLAUDE.md. Never designs a new taxonomy. Complements /folder-review (see §15). Trigger on "sort my inbox", "process 00. Inbox", "file these new downloads".
---

# Foldero — Inbox Processor

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Ongoing inbox sorter. Standalone; runs on-demand against a folder whose taxonomy already exists.
**Shared rules:** `references/SUITE-CONVENTIONS.md`. Boundary partner of `/folder-review` per §15.

## Dependencies & STOP conditions

- Requires `CLAUDE.md` and `INDEX.md` at the root. STOP if either is missing — guessing a taxonomy would fragment the folder.
- Acquire the run-lock (§13); STOP if another run holds a fresh lock; release at the end.
- Works on `[ROOT]/00. Inbox` by default, or an inbox subfolder the user names.
- **Every mutating pass writes a Report** per SUITE-CONVENTIONS §9 — always dated, always in `_LOGS/`.

## On launch

1. Confirm the root and that `CLAUDE.md` + `INDEX.md` exist.
2. Read `CLAUDE.md` in full — owner context, sensitivity handling, routing preferences from prior runs.
3. Read `INDEX.md` in full — Taxonomy, Awaiting-sign-off register (if absent, treat as empty, not malformed), Activity log.
4. Read any `_MANIFEST.md` in REVIEW-SORT/REVIEW-TRASH — don't re-sort what's already flagged.
5. Read the user's `references/Brand-Taxonomy-Reference.md`, `references/Sensitivity-Defaults.md`, and `references/File-Type-Heuristics.md` (with any user-appended patterns).

## Per-item processing

For each item in the inbox:

1. **Classify** — content type, brand/owner, purpose from name, extension, metadata, parent context. Use `references/File-Type-Heuristics.md`.
2. **Match to taxonomy** — best-fit destination from `INDEX.md`. Strong match (≥90%) → route there. §2a re-homing exception applies where the sub-pillar name is identical or a trivial variant of the item's own name.
3. **Create if needed** — if a category exists in concept but not yet as a folder, create it using the recorded numbering convention, add to INDEX Taxonomy, then move. Prefer existing category over near-duplicate.
4. **Sensitivity check (§5) — tier OVERRIDES type-based pillar:** File-by-name → its restricted pillar, logged sensitive; Quarantine → `REVIEW-SORT/secrets`; Restricted-domain → **pause and get explicit user sign-off before moving. No unattended-move posture** — never auto-route these.
5. **Cruft & empties** — OS-cruft (§6), generic empty folders (§7) → `REVIEW-TRASH`.
6. **Execute move** — reversible `mv`. Collisions handled per `references/Collision-Handling.md`. Log per `references/Undo-Rules.md` §2 schema.
7. **Update logs** — append the move to INDEX's Activity section and `_LOGS/activity-log.md`.
8. **Below threshold / junk** — under-confidence → `REVIEW-SORT`; suspected junk → `REVIEW-TRASH`; each with a `_MANIFEST.md` entry.

## Boundary partner note (§15)

This skill handles **new items in `00. Inbox`**. It does NOT touch items already in `REVIEW-SORT/`, `REVIEW-TRASH/`, or `CONFIRMED-TRASH/` — those already-flagged items belong to `/folder-review`. If a user asks this skill to "process what's in REVIEW-SORT", redirect them.

## Output

Write `Inbox-Run-[DATE].md` to `_LOGS/`: items processed · to taxonomy · to REVIEW-SORT (incl. quarantined secrets) · to REVIEW-TRASH · kept in place · new folders created · gates awaiting user. Release the run-lock.

## References

- `references/File-Type-Heuristics.md` — per-item classification rules.
- `references/Sensitivity-Classification-Guide.md` — three-tier check; Tier 3 pause.
- `references/Sensitivity-Defaults.md` — user's per-brand tier mappings.
- `references/Collision-Handling.md` — suffix conventions.
- `references/Undo-Rules.md` — activity-log reversibility schema.
- `references/Report-Templates.md` — Inbox-Run column structure.
- **Boundary (§15):** ambiguous already-flagged items belong to `/folder-review`, not this skill.

## Cross-references

- Requires: `CLAUDE.md` + `INDEX.md` (from `/folder-execute` or pre-existing). Produces: `_LOGS/Inbox-Run-…md`; updates INDEX + `_LOGS/activity-log.md`.
- Sibling standalone: `/folder-import` (external source) and `/folder-review` (already-flagged backlog).

## Tested against

- 2026-09-15 · Validated via shared routing rules across four fixtures. v2.0 adds Report-invariant statement + user-config awareness.
