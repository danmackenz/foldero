# Metadata Tag Vocabulary (Foldero Plugin — references/)

Documents the tag vocabulary `/folder-tag` writes to EXIF/IPTC keyword fields. Kept generic in the shipped plugin; extended per-user by `/organisation-setup`.

Consumed by: `/folder-tag` (primary), `/folder-audit` (may surface existing tags in the inventory), `/folder-review` (may read tags as a routing signal).

---

## 1. Shipped generic vocabulary

Categorical tag values that are safe defaults for any user, regardless of their domain:

**Usage type:**
- `personal`
- `business`
- `client-deliverable`
- `stock` (speculative/library work not tied to a specific engagement)
- `reference` (not for use; kept for later study)

**Content stage:**
- `raw` (unprocessed original)
- `working` (in-progress edit)
- `edited` (final delivered version)
- `archive` (retired, historical reference)

**Distribution channel:**
- `marketing`
- `social-media`
- `web`
- `print`
- `internal`

**Brand marker:**
- `restricted` — generic marker for Tier 3 `SENS:RESTRICTED-DOMAIN` content when tagging is appropriate at all. Never write the specific brand/context name into portable metadata for Tier 3 content (§3 below).
- User-specific brand tags are added by `/organisation-setup` to a per-user extension of this file, never to this shipped copy.

## 2. Extension by `/organisation-setup`

When the user names brands/entities in the `/organisation-setup` interview (§3.2 item 3), each brand becomes an additional tag value. The user-level `Metadata-Tag-Vocabulary.md` copy records these additions with the `USER-CONFIGURED` marker.

`/folder-tag` reads the user-level file first, then falls back to this shipped vocabulary — user additions are additive, never overwriting.

## 3. Sensitivity constraint — CRITICAL

**Never** write a tag value that would leak Tier 3 `SENS:RESTRICTED-DOMAIN` classification (per `references/Sensitivity-Classification-Guide.md`) into embedded file metadata. Metadata travels with the file if it's copied, shared, uploaded, or emailed — the point of Tier 3 is that this content stays gated. Writing a specific restricted-brand name (whatever the user's own registered restricted brand is called) into EXIF/IPTC keywords defeats the classification's purpose.

For Tier 3 content, `/folder-tag`:
- Writes the generic `restricted` marker only, if tagging is appropriate at all.
- Never writes the specific brand/context name.
- Refuses to write user-supplied Tier 3 brand names even if explicitly requested — the user can override this only by re-running `/organisation-setup` and moving the brand out of Tier 3, not by asking `/folder-tag` directly.

Tier 2 `SENS:QUARANTINE` items are never tagged — they are routed to `REVIEW-SORT/secrets/` and remain there until the user decides.

## 4. Tag write mechanics

`/folder-tag` writes to standard EXIF `Keywords` and IPTC `Subject` fields. Never touches pixel data, colour profiles, or non-keyword metadata fields.

Every tag write is logged to `_LOGS/activity-log.md` and `_LOGS/Tag-Write-Log-[DATE].csv` per `references/Migration-CSV-Schema.md` with `action: tag-write`.

Per-batch confirmation required before writing — user sees the full list of (file, tags-to-write) pairs and approves before any write happens.

## 5. Reading existing tags

`/folder-tag` reads existing EXIF/IPTC keywords on file inspection without writing anything. Existing tags are surfaced to `/folder-audit` as a classification signal (e.g. an existing "client-deliverable" tag increases confidence for filing the item into a client pillar). Reading is unconstrained; writing is gated per §3.

## 6. Cross-skill application notes

- `/folder-audit` may cite an item's existing tags in the audit report as evidence for a classification decision.
- `/folder-review` uses existing tags as a "why was this flagged" signal (though tag mismatch alone doesn't trigger flagging).
- `/folder-lint` does not validate tag correctness — tags are user content, not suite artifacts.
