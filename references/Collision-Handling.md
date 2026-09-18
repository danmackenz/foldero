# Collision Handling (Foldero Plugin — references/)

Consolidates the per-context suffix conventions applied when a move would collide at the destination. Introduced after suffix-drift was measurable in production (six different suffixes observed across three passes on the same folder).

Consumed by: every mutating skill (the trio + all standalone mutating skills). `/folder-lint` uses this to validate that observed suffixes in `activity-log.md` match the expected-per-context set.

---

## 1. Core rule (unchanged from SUITE-CONVENTIONS §12)

Never overwrite on a name collision. Two responses only:

- **Append a suffix** per the context table in §2. Preserves both source and destination items with distinct names.
- **Route the whole item to `REVIEW-SORT`** with a manifest reason line naming the collision. Used when a suffix would be misleading or the collision itself signals a taxonomy problem.

The choice between suffix and REVIEW-SORT is made per the context table.

## 2. Canonical suffix table

| Context (skill + situation) | Suffix | When used |
|---|---|---|
| `/folder-execute` — collision during first-pass move | ` (2)`, ` (3)`, … | Numeric suffix escalates on repeated collisions. |
| `/folder-execute` — item merged from `00. Inbox` into an existing pillar destination | ` (from Inbox)` | Preserves the ancestor's known origin. |
| `/folder-inbox` — new arrival collides with an existing pillar item | ` (from Inbox)` | Consistent with the trio's Inbox-origin marker. |
| `/folder-import` — Copy or Move import collides with a receiving-folder item | ` (imported)` | Denotes cross-location origin. |
| `/folder-import` — Improve-Names mode collision after rename | ` (imported v2)` | Rare — the rename should preempt collisions, but if the improved name still clashes, escalate. |
| `/folder-deepen` — collision when re-homing into a deeper sub-pillar | ` (deepen)` | Denotes the item arrived via a deepen pass. |
| `/folder-deepen` — correction pass revising a prior deepen decision | ` (correction)` | Marks the re-homed item as a corrected placement. |
| `/folder-undo` — reversal collides at the original source location | ` (revert)` | Marks the reversed item where the source path is no longer free. |
| `/folder-review` — user directs a REVIEW-SORT item to a pillar that already contains a same-named item | ` (from REVIEW-SORT)` | Denotes a manual-review origin. |
| `/folder-signoff` — Tier 3 approval collides at the intended destination | ` (signed-off)` | Rare; escalation triggers a re-prompt to the user rather than silent suffix. |

## 3. When to route to REVIEW-SORT instead of suffixing

Route the whole item to `REVIEW-SORT` (not append a suffix) when:

- The collision involves an **atomic unit** on either side. Suffixing would break the atomic-unit boundary or produce two whole atomic units with near-identical names — a data-integrity smell. Route both (or the incoming) to REVIEW-SORT for the user to reconcile.
- The collision suggests the **taxonomy has a genuine duplication** (two pillars claim the same content). This is a plan-level defect, not a naming problem — the item goes to REVIEW-SORT with a manifest reason naming both candidate destinations.
- **Cross-brand ambiguity** — the item's name/structure signals match two or more registered brands with comparable confidence (per `/folder-plan` and `/folder-review` cross-brand logic). Manifest reason names both candidate brands.

## 4. Suffix precedence when multiple could apply

Rare but real: an item imported from an external drive, filed into a deepen destination that collides, in a correction pass. Precedence, most-recent action wins:

1. `(revert)` (undo context, ignore other suffixes)
2. `(correction)` (correction pass, ignore lower-priority)
3. `(deepen)` (deepen context)
4. `(imported)` / `(imported v2)` (import context)
5. `(from Inbox)` / `(from REVIEW-SORT)` (routing origin)
6. ` (2)`, ` (3)` (numeric escalation, applied only when no context suffix fits)

Skills should apply at most one suffix per move. Chaining (` (from Inbox) (deepen)`) is a smell — indicates two moves should have been logged, not one.

## 5. `/folder-lint` validation

`/folder-lint` check 4a (new): parses `activity-log.md` for suffixes and flags any suffix NOT in §2's table. Common cause: a skill body invented its own suffix during development. Fix by updating this table OR by changing the skill to use a canonical suffix.

## 6. Cross-skill application notes

- Every mutating skill body must state: "Collisions handled per `references/Collision-Handling.md`."
- Skills invoked via the orchestrator conductor inherit the same suffix conventions — the orchestrator does not add its own suffix layer.
- `/folder-undo` reads suffixed destinations correctly by stripping the suffix when computing the reversal target.
