---
name: folder-import
description: Imports external content (folder, SSD, chat attachment) into a folder that already has trio artifacts. Offers Move/Copy and Improve/keep-names. Verified copy-then-remove. Trigger on "import into my folder", "migrate this drive".
---

# Foldero — Cross-Folder Import

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Cross-location import processor. Files in content from outside. The source is strictly read-only except the single post-verification source removal a Move performs.
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## Dependencies & STOP conditions

- Requires the **receiving folder** to have `CLAUDE.md`, `INDEX.md`, taxonomy, and `_LOGS/`. STOP if the receiving folder isn't set up — never infer a taxonomy here.
- Acquire the run-lock (§13) on the receiving folder; release at the end.
- STOP if the source can't be resolved, is unreadable, or would require access outside the confirmed source and receiving roots.
- **Every mutating pass writes a Report** per SUITE-CONVENTIONS §9.

## On launch — source resolution

Present:

> **Import source — choose one:**
> **1.** File path to the source folder (local disk, external SSD, connected drive).
> **2.** Attach or add the source folder to the chat directly.

Do not proceed until one is given. For a **removable volume**, record the volume name in every log/report (records stay valid after disconnect). Re-confirm the receiving root and its `CLAUDE.md`/`INDEX.md`/`_LOGS/`.

## Step 1 — Audit the source (read-only)

Perform an inventory in memory: top-level items with atomic units as single rows per `references/Atomic-Unit-Signatures.md`, purpose/domain, mess signals, three-tier sensitivity, cruft/empty tags. **Never write anything to the source.** Fold the inventory into the Import-Report.

Use `data:explore-data` / `data:data-context-extractor` if available for data-heavy sources.

If the source is empty or unreadable, STOP and report — do not scaffold or write an empty report. Record the source conservation baseline.

## Step 2 — Map into the receiving taxonomy

A variant of `/folder-plan` that maps *into* an established taxonomy:

- Read the receiving `CLAUDE.md` and `INDEX.md` in full.
- For every source item, propose a destination at ≥90% confidence with a one-line reason. Sensitivity judged against the receiving `CLAUDE.md` and `references/Sensitivity-Defaults.md`; a tier overrides any type-based pillar.
- `NEEDS-REVIEW` / below-threshold → receiving `REVIEW-SORT` (whole); `LIKELY-JUNK` → receiving `REVIEW-TRASH`; anything fitting no category → `REVIEW-SORT`, never forced.
- New category needed → flag for explicit user approval. Importing never silently expands the receiving structure.
- Detect the source's own numbering/structure. Flag clashes with the receiving scheme.

## Step 3 — Transfer options (two independent choices)

Present the full mapping table (`source item → destination → proposed new name if Improve`), then require explicit confirmation of **both**:

- **Transfer mode:** Move (removed from source after verification) or Copy (source untouched).
- **Naming mode:** Improve (rename to the receiving conventions per `references/Numbering-Convention-Rules.md`) or keep-as-is (preserve source names). In keep-names mode, clashing source-number prefixes trigger a warning + offer to strip.

Never assume either choice. In Guided contexts, confirm per batch.

## Step 4 — Execute (verified, non-destructive, resumable)

- **Live migration-CSV ledger** written incrementally per `references/Migration-CSV-Schema.md` — one row per item as it verifies. Makes interrupted transfers and removable-drive disconnects safely resumable.
- **Copy mode:** copy → verify (item count, size, checksum where feasible) → leave source untouched.
- **Move mode:** copy → verify → then remove source. Never delete-then-copy. Verification fails → stop, leave both copies, report.
- **On re-run:** skip any item already ledger-recorded as verified-present at destination (idempotent resume).
- **Never-delete for junk:** `LIKELY-JUNK` transfers to receiving `REVIEW-TRASH` — source never deleted, even in Move with junk flagged.
- **Collisions** per `references/Collision-Handling.md` — `(imported)` suffix or route to `REVIEW-SORT`.
- **Atomic units** move whole per `references/Atomic-Unit-Signatures.md`.
- **`SENS:RESTRICTED-DOMAIN`** items not transferred until signed off (left at source, listed awaiting sign-off in receiving INDEX).
- **Duplicate detection is name/metadata-based only** — same-content/different-name near-duplicates possible. Content-level dedup is out of scope (use `/folder-dedupe` post-import).

## Step 5 — Document update

- Append an import entry to `_LOGS/import-log.md` (source path/volume, date, item count, transfer mode, naming mode, routing) and to INDEX's Activity section.
- `CLAUDE.md`: append only a single dated one-line pointer. Never the item list.

## Output

Write `Import-Report-[SOURCE-NAME]-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`. Emit the migration CSV alongside it per `references/Migration-CSV-Schema.md`. Release the run-lock.

## References

- `references/Atomic-Unit-Signatures.md` — atomic units imported whole.
- `references/File-Type-Heuristics.md` — mapping into the receiving taxonomy.
- `references/Sensitivity-Classification-Guide.md` + `references/Sensitivity-Defaults.md` — tier assignment against the receiving folder's context.
- `references/Migration-CSV-Schema.md` — the live ledger's columns and action vocabulary.
- `references/Collision-Handling.md` — `(imported)` suffix and REVIEW-SORT fallback.
- `references/Numbering-Convention-Rules.md` — Improve-Names mode conventions.
- `references/Report-Templates.md` — Import-Report format.

## Cross-references

- Requires: a receiving folder with `CLAUDE.md` + `INDEX.md` + `_LOGS/` + taxonomy. Produces: `_LOGS/Import-Report-…md` + migration CSV; updates INDEX + `_LOGS/import-log.md`. Reversible via `/folder-undo`.
- Sibling standalone: `/folder-inbox` (sorts the folder's own inbox).

## Tested against

_(fill in after first use: source type, transfer mode, naming mode, outcome.)_
