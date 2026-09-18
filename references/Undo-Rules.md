# Undo Rules (Foldero Plugin — references/)

Rules that govern what makes a mutating-skill's `activity-log.md` entry **reversible** by `/folder-undo`. Extracted from `/folder-undo`'s prior inline logic so every mutating skill and `/folder-lint` can reference the same schema.

Consumed by: `/folder-undo` (primary), `/folder-lint` (validates activity-log entries carry the required fields), `/folder-changelog` (identifies which entries are reversible for the narrative), and every mutating skill (writes entries that must be reversible).

---

## 1. Reversibility invariants

An `activity-log.md` entry is **reversible** when ALL of these hold:

1. **Structure recorded.** The entry names both `source` and `destination` (or `original-path` and `imported-path` for imports). Missing either → not reversible.
2. **Destination unchanged since original move.** If a later run moved the item again, the earlier entry is superseded and not reversible without walking the chain forward first.
3. **Source path free.** The original source location must not now be occupied by a different item — otherwise reversing would collide (§12 never-overwrite rule stands).
4. **Atomic unit whole.** If the moved item is an atomic unit (per `references/Atomic-Unit-Signatures.md`), it must still be intact at the destination — no internal reorganisation happened between the move and the undo attempt.
5. **Source volume accessible** (imports only). For Move-mode imports, the source volume must be currently mounted. Copy-mode imports reverse by removing the imported copy — always accessible.
6. **Timestamp within reversibility window.** The entry is dated within a reasonable window (default: last 30 days). Older entries can still be reversed but the skill flags them as beyond-typical and asks for confirmation.

Any entry failing one or more invariants is **skipped** during undo — reported in the Undo-Report, never forced. See "Skip reasons" below.

## 2. Required fields per activity-log entry

Every mutating skill writes entries matching this schema so undo can walk them:

```
- `source/path` → `destination/path` [action: mv|mv-suffix|copy|copy-move|revert-mv|scaffold] [confidence: N%] [tier: FILE-BY-NAME|QUARANTINE|RESTRICTED-DOMAIN|none] [reversible: yes|no|conditional] [reason: <one line>]
```

- **action** — one of the values in `references/Migration-CSV-Schema.md`.
- **confidence** — for filing operations; omitted for scaffolds.
- **tier** — sensitivity tier at classification time; `none` for non-sensitive.
- **reversible** — `yes` (fully reversible), `no` (scaffold or terminal action like CONFIRMED-TRASH), `conditional` (reverses cleanly only if invariants above hold at undo time), `unknown` (pre-schema entry from a mutating pass that ran before this schema was in force; treat as reversible-with-extra-confirmation, never as either yes or no by default).
- **reason** — one-line human explanation.

## 3. Skip reasons (reported, never forced)

When undo hits an entry that fails an invariant, it records the skip reason in the Undo-Report:

- `skipped: destination-moved` — a later run relocated the item; undo would need to walk that chain first.
- `skipped: source-occupied` — original source path now holds a different item.
- `skipped: atomic-unit-modified` — the atomic unit's internal structure changed post-move (a boundary violation flagged separately for `/folder-lint`).
- `skipped: source-volume-unmounted` — Move import; source drive not present.
- `skipped: outside-reversibility-window` — entry older than 30 days; requires explicit confirmation to reverse.
- `skipped: irreversible-action` — scaffold, `CONFIRMED-TRASH` disposition, or other terminal action.

## 4. Partial-undo behaviour

Undo is **best-effort**: reverses everything it can from a run in reverse order, skips what fails an invariant, and always produces a complete Undo-Report describing both the reverses and the skips. It never aborts a run partway through because a middle entry can't reverse — later entries may still be reversible in isolation.

## 5. What is NOT reversible by design

- **`CONFIRMED-TRASH` routings** — the user explicitly confirmed the item as junk via `/folder-review`. Reversing would contradict the user's confirmation. If the user wants to rescue an item from `CONFIRMED-TRASH`, they do it manually — no skill handles that.
- **Scaffolds** (folder creation) — reversing a scaffold means removing a folder, which the never-delete rule forbids. Scaffolds are recorded as `reversible: no` from the start.
- **Sign-off approvals** cleared by `/folder-signoff` — those move Tier 3 items to their intended destination; reversing is a *new* Tier 3 move that requires its own sign-off. Handled by re-invoking `/folder-signoff`, not `/folder-undo`.

## 5a. Pre-schema (`reversible: unknown`) handling

Activity-log entries written before this schema was in force do not carry the `reversible:` field. `/folder-undo` must not silently treat their omission as either `yes` or `no`. Instead:

- Treat as `reversible: unknown`.
- Before attempting to reverse such an entry, surface the entry to the user with its recorded source and destination (whatever the pre-schema log did record), state that this entry predates the reversibility schema, and require an explicit per-entry confirmation before executing the reverse.
- The Undo-Report records the entry's outcome as `reversed: user-confirmed-pre-schema`, `skipped: user-declined-pre-schema`, or one of the standard skip reasons above (e.g. `source-occupied`) if an invariant fails independently.

This rule replaces any silent assumption. `/folder-lint` Check 6c flags missing `reversible:` on new entries as a Warning; on historical (pre-schema) entries the flag is expected to be missing and the entry is not re-flagged.

## 6. Cross-skill application notes

- **Every mutating skill body** must state: "This skill records reversibility-schema entries per `references/Undo-Rules.md` §2 so that `/folder-undo` can walk them."
- **`/folder-lint`** check 6c (new): validates every activity-log entry carries the §2 fields. Missing `reversible:` flag on an entry → Warning.
- **`/folder-changelog`** uses the `reversible:` flag to annotate which runs can still be safely reversed vs which are now locked in by subsequent activity.
