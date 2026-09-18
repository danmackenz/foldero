---
name: folder-deepen
description: Builds deep multi-tier sub-structure (SOP-scale, 6-9 tiers) after a first pass exists. Always gated per batch. Trigger on "go deeper", "sub-number these pillars", "break this down further".
---

# Foldero — Deepen (SOP-scale sub-structure)

**Version:** v1.2 · Last modified 2026-09-17
**Role:** Build deep decimal sub-structure under a first-pass taxonomy — the pass the trio deferred to keep the first pass legible. This is where the Folder Structure SOP's 6–9-tier decimal scheme belongs (SUITE-CONVENTIONS §11).
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## Dependencies & STOP conditions

- Requires a folder with `CLAUDE.md` + `INDEX.md` + `_LOGS/` and an existing first-pass taxonomy. STOP and point to the trio if missing.
- Acquire the run-lock (§13); release at the end.
- **Always gated:** deepening reshapes structure, so every batch requires explicit user approval — no unattended posture, in any mode.
- **Scope to a chosen pillar/subtree at a time** unless the user explicitly asks for the whole tree.
- **Every mutating pass writes a Report** per SUITE-CONVENTIONS §9 — including supplementary/correction passes per `references/Report-Templates.md` Supplementary-Pass shape.

## Inputs

1. If the Reorganisation-Plan carries a deeper-pass sub-numbering appendix (in `_LOGS/`), use it as the starting design.
2. Read `CLAUDE.md` and `INDEX.md`. Honour the folder's own convention over the SOP where they differ (§11 precedence, including the user's `TAXONOMY-REFERENCE.md`).

## SOP rules (applied to newly created sub-structure only)

- **Depth:** aim for 6 tiers minimum where content justifies it, up to 9; do not force depth on a pillar that doesn't need it.
- **Numbering:** sub-numbering restarts at `1.` within each parent (`3.1`, `3.2` under `3.`). Decimal cascades stop at two levels — do not go beyond `3.2.1`; deeper needs are expressed as named sub-folders.
- **Labels:** concise, single words or short two-word phrases, first letter capitalised, no ALL-CAPS.
- **Never** create depth inside a repo, app package, or other atomic unit (§4), or inside a restricted domain without separate sign-off.
- **§2a re-homing exception:** if a below-90% item's destination sub-pillar name is IDENTICAL or a trivial variant of the item's own name, and exactly one such destination exists, the ≥85% bar applies. Sensitivity tiers always win over this exception.

## Procedure

1. **Propose the deep tree** for the chosen subtree as newline-delimited slash-terminated POSIX paths (the SOP output format), with a one-line rationale per new tier. Show it and get approval before creating anything.
2. **Scaffold** the approved folders with `mkdir` (creation only — no file moves in this step). Never overwrite an existing folder.
3. **Re-home existing items (optional, only if approved).** Move with verified reversible `mv` per `references/Collision-Handling.md`. Conservation check §8; atomic units whole per `references/Atomic-Unit-Signatures.md`; sensitivity tiers §5. Skip and report anything below the applicable confidence bar → leave at the parent pillar or `REVIEW-SORT`.
4. **Migration worklist.** Emit a CSV per `references/Migration-CSV-Schema.md` mapping `old-path,new-path,action,renamed,verify,confidence,tier,reversible` for every move.
5. **Update documents.** Extend INDEX's Taxonomy section. Append the run to `_LOGS/activity-log.md` per `references/Undo-Rules.md` §2. If the deep scheme establishes durable sub-numbering rules, record those **rules** (not the run) in `CLAUDE.md`.

## Output

Write `Deepen-Plan-[SUBTREE]-[DATE].md` (proposal) and `Deepen-Report-[SUBTREE]-[DATE].md` (execution) to `_LOGS/` per `references/Report-Templates.md`. **Three-column split (Moves / Scaffolds / Flagged) mandatory** — never merge Scaffolds into Moves. Release the run-lock.

**Supplementary/correction/revert passes** write `Deepen-Correction-Report-*.md` or `Deepen-Revert-Report-*.md` per Report-Templates.md's Supplementary-Pass shape. Every filesystem-changing pass produces its own dated Report.

## References

- `references/Numbering-Convention-Rules.md` — the decimal sub-numbering scheme this skill applies.
- `references/Sensitivity-Classification-Guide.md` — the §2a re-homing exception does NOT apply to sensitive items.
- `references/Report-Templates.md` — Deepen-Plan format; the re-homing exception log columns; the Supplementary-Pass shape.
- `references/Migration-CSV-Schema.md` — migration CSV columns and action vocabulary.
- `references/Collision-Handling.md` — `(deepen)` and `(correction)` suffix conventions.
- `references/Undo-Rules.md` — activity-log reversibility schema.
- `references/Atomic-Unit-Signatures.md` — never descend into an atomic unit.

## Cross-references

- Requires: first-pass `CLAUDE.md` + `INDEX.md` (+ optional deeper-pass appendix in the Reorganisation-Plan).
- Produces: `_LOGS/Deepen-Plan-…md` + `_LOGS/Deepen-Report-…md` + migration CSV; updates INDEX + `_LOGS/activity-log.md`.
- Grounded in the project's `Folder Structure Requirement SOP`.

## Changelog

- **v1.2 · 2026-09-17** — Reference-doc integration (Migration-CSV-Schema, Collision-Handling, Undo-Rules, Sensitivity-Classification-Guide, Atomic-Unit-Signatures). Supplementary-pass Report invariant made explicit.
- **v1.1 · 2026-09-17** — Added the §2a re-homing exception. First real test (managed folder correction pass): all 6 candidate items failed the name-identical test; exception retained for future cases. Split report template's single moves column into separate **Moves / Scaffolds / Flagged** columns. Corrected count-reconciliation error — the earlier deepen run's actual total was **35 moves**, not the miscounted 43 or 32.
- **v1.0 · 2026-09-15** — Initial release: SOP-scale deep-structure builder with per-batch approval gate.

## Tested against

- 2026-09-15/17 · Live tested on a managed folder: 35 moves, 12 new scaffold folders, 2 MANIFEST files, correction pass covered.
