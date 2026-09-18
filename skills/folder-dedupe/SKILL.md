---
name: folder-dedupe
description: Full-tree duplicate scanner. Compares by name+size+structure signature, never contents. ≥90% groups routed WHOLE to REVIEW-SORT/duplicates/. Sensitivity tiers flag without routing. Trigger on "find duplicates", "dedupe".
---

# Foldero — Dedupe

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Read-mostly duplicate detector. The only mutating action is routing confirmed duplicate groups whole to `REVIEW-SORT/duplicates/` — never a merge, never a delete.
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## Dependencies & STOP conditions

- Requires the managed folder to have `CLAUDE.md`, `INDEX.md`, `_LOGS/`. STOP if any is missing.
- Acquire the run-lock (§13); release at the end.
- STOP if the requested scope would need access outside a single managed root.
- **Every mutating pass writes a Report** per SUITE-CONVENTIONS §9.

## Procedure

1. **Scope** — the whole managed root by default, or a subtree the user names. Confirm the scope in one line before scanning.
2. **Enumerate** — walk the tree. For every file and every atomic unit (per `references/Atomic-Unit-Signatures.md`), record: relative path · name · size · structure signature (for atomic units and folders: immediate-child count + sorted-name hash; NEVER open file contents).
3. **Group** — cluster candidates by name+size (exact match) and name+size+signature (near-match). Never diff internals.
4. **Confidence** — a group is ≥90% confidence when: names match exactly (allowing `(1)`, `(2)`, `_copy`, `-final`, `-v2` variants) AND sizes match to the byte AND for folders the structure signature matches.
5. **Sensitivity check** — apply `references/Sensitivity-Classification-Guide.md` and `references/Sensitivity-Defaults.md`. If any group member is Tier 2 or Tier 3, FLAG the group in the report but do NOT route into `REVIEW-SORT/duplicates/`. Sensitivity always wins over dedupe handling.
6. **Route confirmed groups** — for each ≥90% group with no sensitivity conflict, move the whole group into `00. Inbox/REVIEW-SORT/duplicates/<group-id>/` (create as needed). Preserve source path in each item's relative sub-path within the group folder. Collisions per `references/Collision-Handling.md`. Reversible via `/folder-undo`.
7. **Log** — every group and every routing decision to `_LOGS/activity-log.md` per `references/Undo-Rules.md` §2 schema.

## Output

Write `Dedupe-Report-[SCOPE]-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`: Group ID | Items | Match Basis | Confidence | Routed to REVIEW-SORT | Sensitivity Flag. Companion CSV `Dedupe-Groups-[FOLDER]-[DATE].csv` per `references/Migration-CSV-Schema.md`. Release the run-lock.

## References

- `references/Atomic-Unit-Signatures.md` — atomic units compared by name+size+structure signature only; never diff internal contents.
- `references/Report-Templates.md` — Dedupe-Report column structure.
- `references/Sensitivity-Classification-Guide.md` + `references/Sensitivity-Defaults.md` — Tier 2/3 members flag a group without routing it.
- `references/Migration-CSV-Schema.md` — Dedupe-Groups CSV columns.
- `references/Undo-Rules.md` — activity-log reversibility schema.
- `references/Collision-Handling.md` — collision handling in `REVIEW-SORT/duplicates/`.

## Cross-references

- Requires: `CLAUDE.md` + `INDEX.md` + `_LOGS/` at the root. Produces: `_LOGS/Dedupe-Report-…md` + CSV; routes confirmed duplicate groups into `REVIEW-SORT/duplicates/`. Reversible via `/folder-undo`.

## Tested against

_(fill in after first use: scope, groups found, routed vs flagged, outcome.)_
