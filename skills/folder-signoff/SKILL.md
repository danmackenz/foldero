---
name: folder-signoff
description: Sole authority to clear INDEX Awaiting-sign-off queue. Approve/Reject/Redirect per item, never batches. Only skill that moves Tier-3 items. Trigger on "sign off", "approve gated items", "clear sign-off queue".
---

# Foldero — Sign-off

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Sole authority to move `SENS:RESTRICTED-DOMAIN` items out of their as-classified location into their recorded intended destination. Every move is per-item, user-approved, logged.
**Shared rules:** `references/SUITE-CONVENTIONS.md`. Enforces §5's Tier 3 gating and §10's Awaiting-sign-off ownership.

## Dependencies & STOP conditions

- Requires the managed folder to have `CLAUDE.md`, `INDEX.md` (with an `Awaiting sign-off` section — empty is valid), and `_LOGS/`. STOP if any is missing.
- Acquire the run-lock (§13); release at the end.
- If the `Awaiting sign-off` section is empty, tell the user nothing is queued and stop.
- **Every mutating pass writes a Report** per SUITE-CONVENTIONS §9 — including passes where the user rejects all queued items.

## Procedure

1. **Read the queue.** Parse INDEX's `Awaiting sign-off` section. Each entry should record: item path · classified tier · intended destination · date queued. If an entry lacks an intended destination, flag it (a `/folder-lint`-detectable defect) and skip.
2. **Present one item at a time.** For each queued item, present: item path, classified tier reason, intended destination, date queued. Ask the user to **Approve** (move to intended destination), **Reject** (leave in place, remove from queue with a reason), or **Redirect** (approve with a different destination — user supplies it).
3. **Never batch.** Even when many items are queued, ask per item. This is Tier 3 — user attention is the point.
4. **Write the approval marker.** Before executing the approved move, write an ephemeral marker at `_LOGS/.signoff-approved-<sanitised-item-name>` (fresh timestamp — the gate hook treats anything older than 60 seconds as stale and ignores it). Attempt the `mv`. On success: delete the marker, then proceed to step 6 (remove the INDEX entry). On failure (destination collision, permissions, source vanished): delete the marker immediately, leave the INDEX entry queued as-is, and report the failure — the marker's lifetime never outlives a single attempt, success or not, so a failed attempt can never leave a live authorisation for a later unrelated operation on the same path to ride through.
5. **Execute one at a time.** On Approve or Redirect: `mv` to destination, verify (source gone AND destination present), log per `references/Undo-Rules.md` §2 with action `signoff-approve`. On Reject: remove queue entry, log with action `signoff-reject`. Never overwrite — collisions per `references/Collision-Handling.md`.
6. **Update documents.** Remove the resolved entry from INDEX's `Awaiting sign-off` section. Append to INDEX's `Activity` section and `_LOGS/activity-log.md` (dated, per-item, with the user's decision).
7. **Never open contents.** Tier 3 items are classified by name/metadata/structure only. Sign-off does not require or invite content inspection.
8. **Check leaf BRAIN.md size.** If the managed folder has a `BRAIN.md` and it is leaf-shaped (no child-rollup table — see SUITE-CONVENTIONS §18), check its line count. Over 500 lines: add a flag to the Output report — "BRAIN.md is N lines, consider reviewing for consolidation." Never auto-summarize or auto-delete. Parent-shaped `BRAIN.md` (has a child-rollup table) is exempt — its size scales with child count, not activity.

## Output

Write `Signoff-Report-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`: Item | Recorded Destination | User Decision (Approve/Reject/Redirect) | Final Destination | Timestamp. Include the BRAIN.md size flag (step 8) if triggered. Release the run-lock.

## References

- `references/Sensitivity-Classification-Guide.md` — this is the only skill authorised to clear an `Awaiting sign-off` entry.
- `references/Sensitivity-Defaults.md` — user-registered Tier 3 defaults.
- `references/Report-Templates.md` — Signoff-Report column structure.
- `references/Collision-Handling.md` — `(signed-off)` suffix on rare destination collision.
- `references/Undo-Rules.md` — `signoff-approve` / `signoff-reject` action values; sign-off approvals not reversed by `/folder-undo` (re-invoke this skill instead).

## Cross-references

- Requires: `CLAUDE.md` + `INDEX.md` with `Awaiting sign-off` section + `_LOGS/`. Produces: `_LOGS/Signoff-Report-…md`; updates INDEX + `_LOGS/activity-log.md`. Per-item reverse via re-invoking this skill.
- Other skills route Tier 3 items INTO the sign-off queue; only this skill clears them out.

## Tested against

_(fill in after first use: items queued, decisions taken, outcome.)_
