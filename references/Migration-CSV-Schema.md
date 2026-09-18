# Migration CSV Schema (Foldero Plugin — references/)

Shared column schema and `action` vocabulary for every CSV the suite writes into `_LOGS/`. Introduced to prevent the drift seen when different mutating skills emit CSVs with different columns or suffix conventions.

Consumed by: `/folder-import` (live migration ledger), `/folder-deepen` (migration mapping), `/folder-dedupe` (duplicate-group listing), `/folder-lint` (validates CSV shape), `/folder-undo` (parses to walk reversibility).

---

## 1. Standard columns

Every migration CSV uses these columns in this order:

```
old-path,new-path,action,renamed,verify,confidence,tier,reversible
```

- **`old-path`** — source path relative to the folder root, quoted if it contains commas or spaces.
- **`new-path`** — destination path relative to the folder root, quoted if needed. Empty string for scaffold-only rows.
- **`action`** — one of the values in §2.
- **`renamed`** — `Y` if the destination name differs from the source name (rename or suffix applied), `N` otherwise.
- **`verify`** — `Y` if source-gone + destination-present confirmed, `N` if unverified, `SKIP` if action doesn't require verification.
- **`confidence`** — integer 0-100 percent, or `n/a` for scaffolds/reverts.
- **`tier`** — `FILE-BY-NAME` / `QUARANTINE` / `RESTRICTED-DOMAIN` / `none`.
- **`reversible`** — `yes` / `no` / `conditional` per `references/Undo-Rules.md` §2.

Skills may emit additional columns to the right of these eight (e.g. `/folder-dedupe`'s `group-id`, `/folder-import`'s `source-volume`) but must not reorder or omit the standard eight.

## 2. Canonical `action` vocabulary

Fixed set — do not invent new values without amending this document.

| Action | Meaning | Typical emitter |
|---|---|---|
| `mv` | Move within the managed folder, no collision, no rename. | Any mutating skill. |
| `mv-suffix` | Move with an appended collision suffix (see `references/Collision-Handling.md`). | Any mutating skill. |
| `mv-rename` | Move with a full rename (Improve-Names mode in import). | `/folder-import` only. |
| `copy` | Copy from external source, source untouched (Copy import mode). | `/folder-import`. |
| `copy-move` | Copy then remove source after verification (Move import mode). | `/folder-import`. |
| `scaffold` | Folder creation, no source, `old-path` empty. | `/folder-execute`, `/folder-deepen`, `/organisation-setup`. |
| `manifest-write` | `_MANIFEST.md` create or update. | Any skill writing to REVIEW-SORT/REVIEW-TRASH/CONFIRMED-TRASH. |
| `revert-mv` | Reversal of an earlier `mv` or `mv-suffix`. | `/folder-undo`. |
| `revert-copy` | Removal of an imported copy (undo of `copy`). | `/folder-undo`. |
| `signoff-approve` | Tier 3 item moved from Awaiting-sign-off to intended destination. | `/folder-signoff`. |
| `signoff-reject` | Tier 3 item removed from Awaiting-sign-off queue, staying in place. | `/folder-signoff`. |
| `review-confirm-trash` | Item moved from REVIEW-TRASH to CONFIRMED-TRASH. | `/folder-review`. |
| `review-file` | Item moved from REVIEW-SORT to a taxonomy pillar. | `/folder-review`. |
| `review-keep` | Item removed from a review queue, filed back into its origin pillar. | `/folder-review`. |
| `tag-write` | Metadata tag written to a file (EXIF/IPTC keyword field). | `/folder-tag`. |

## 3. Filename convention

CSVs are dated in the filename and live in `_LOGS/`:

- `Deepen-Migration-[FOLDER]-[DATE].csv`
- `Import-Migration-[SOURCE-NAME]-[DATE].csv`
- `Dedupe-Groups-[FOLDER]-[DATE].csv`
- `Tag-Write-Log-[DATE].csv`
- `Undo-Migration-[DATE].csv`

## 4. Header row required

Every CSV starts with the header row above. `/folder-lint` flags any CSV in `_LOGS/` missing the header or with the wrong column order.

## 5. Cross-skill application notes

- Skills may emit **rows for skipped/blocked operations** with `verify: SKIP` and a reason recorded in an extra `note` column (permitted extension right of the standard eight).
- `/folder-lint` check 6d (new): validates every CSV in `_LOGS/` follows this schema.
- `/folder-undo` refuses to parse a CSV missing the header row — it reads activity-log.md instead as the fallback source of truth. CSVs are supplementary, not authoritative.
- Content-level dedup (comparing file *contents*) is out of scope for this schema. `/folder-dedupe` compares by name + size + structure signature only per `references/Atomic-Unit-Signatures.md` §6.
