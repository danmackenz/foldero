---
name: folder-tag
description: Reads and writes EXIF/IPTC keyword tags on image files. Vocabulary from Metadata-Tag-Vocabulary.md. Never writes specific Tier-3 brand names to portable metadata. Trigger on "tag my photos", "add metadata to images", "label these by brand".
---

# Foldero — Tag (EXIF/Metadata)

**Version:** v1.0 · Last modified 2026-09-17
**Role:** Reads EXIF/IPTC metadata from image files to aid classification and writes a constrained set of keyword/tag fields based on brand, intended use, or classification outcome. Metadata fields only — never pixel data, never file location beyond what other skills decide.
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## Dependencies & STOP conditions

- Requires the managed folder to have `CLAUDE.md`, `INDEX.md`, `_LOGS/`. STOP if any is missing.
- Acquire the run-lock (§13); release at the end.
- Every file being tagged must have already been classified by `/folder-audit` or `/folder-review`. This skill follows classification, not performs it.
- **Every mutating pass writes a Report** per SUITE-CONVENTIONS §9 — including tag-only runs that touch no filesystem paths.

## Tag vocabulary

Read from `references/Metadata-Tag-Vocabulary.md`:
- Shipped generic set: `personal`, `business`, `client-deliverable`, `stock`, `reference`, `raw`, `working`, `edited`, `archive`, `marketing`, `social-media`, `web`, `print`, `internal`, `restricted`.
- User extensions: `Metadata-Tag-Vocabulary.md` (user-configured, USER-CONFIGURED marker) — added by `/organisation-setup` from the user's registered brands and preferences.

Read the user-level file first, then fall back to the shipped vocabulary. User additions are additive.

## Sensitivity constraint — CRITICAL

**Never** write a tag value that would leak Tier 3 (`SENS:RESTRICTED-DOMAIN`) classification into embedded file metadata per `references/Sensitivity-Classification-Guide.md` §3 and `references/Metadata-Tag-Vocabulary.md` §3. Metadata travels with the file if it's copied, shared, or uploaded — the point of Tier 3 is that this content stays gated.

For Tier 3 content:
- Write the generic `restricted` marker only, if tagging at all.
- **Never** write the specific brand/context name into portable metadata.
- Refuse to write user-supplied Tier 3 brand names even if explicitly requested. The user can override this only by re-running `/organisation-setup` and moving the brand out of Tier 3, not by asking this skill directly.

Tier 2 (`SENS:QUARANTINE`) items are never tagged — they are in `REVIEW-SORT/secrets/` and stay there.

## Procedure

1. **Scope** — user names the target files or scope (a pillar, a subtree). Confirm read/write access.
2. **Read existing tags** — parse EXIF `Keywords` and IPTC `Subject` fields for each file. Surface existing tags in the review.
3. **Propose new tags** — based on the file's classification (from a prior audit/review), its location in the taxonomy, and the user's brand vocabulary. Cross-check against sensitivity constraints above.
4. **Per-batch confirmation** — show the user the full list of (file, existing-tags, tags-to-write) tuples. User approves before any write happens.
5. **Write** — to standard EXIF `Keywords` and IPTC `Subject` fields. Never touch pixel data, colour profiles, or non-keyword metadata. Use `exiftool` if available; otherwise use whichever library the environment provides.
6. **Verify** — re-read the file's metadata to confirm the write took effect.
7. **Log** — to `_LOGS/activity-log.md` per `references/Undo-Rules.md` §2 (action: `tag-write`) and to `_LOGS/Tag-Write-Log-[DATE].csv` per `references/Migration-CSV-Schema.md`.

## Must NOT do

- Open or analyse image content/pixels to infer subject matter. Classification comes from `/folder-audit` or `/folder-review`, not from this skill's own image analysis.
- Write any tag without the file having already been classified.
- Batch-write tags without a per-batch confirmation.
- Write Tier 3 brand names into portable metadata (§ Sensitivity constraint).

## Output

Write `Tag-Write-Report-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`: File | Existing Tags | Tags Written | Confirmation Received (Y/N). Companion CSV `Tag-Write-Log-[DATE].csv` per `references/Migration-CSV-Schema.md`. Release the run-lock.

## Reversibility

Tag writes are recorded in `activity-log.md` with `action: tag-write` and `reversible: yes`. `/folder-undo` can reverse a tag write by re-writing the previous keyword set (the pre-write state is recorded in the CSV `note` column).

## References

- `references/Metadata-Tag-Vocabulary.md` — shipped vocabulary + user extensions.
- `references/Sensitivity-Classification-Guide.md` — §3 Tier 3 tagging constraint.
- `references/Sensitivity-Defaults.md` — user-registered Tier 3 brands (never written as tags).
- `references/Migration-CSV-Schema.md` — `tag-write` action.
- `references/Report-Templates.md` — Tag-Write-Report format.
- `references/Undo-Rules.md` — activity-log entries for tag writes.

## Cross-references

- Requires: `CLAUDE.md` + `INDEX.md` + `_LOGS/`; files must be pre-classified by `/folder-audit` or `/folder-review`.
- Produces: `_LOGS/Tag-Write-Report-…md` + CSV; writes to file EXIF/IPTC. Reversible via `/folder-undo`.

## Tested against

_(fill in after first use: file count, tag categories written, outcome. Live-test note: EXIF write test deferred pending a safe test-image file — noted as v2.0 release known gap.)_
