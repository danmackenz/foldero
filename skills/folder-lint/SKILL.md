---
name: folder-lint
description: Read-only validator of suite output against SUITE-CONVENTIONS. Checks numbering, INDEX shape, CLAUDE bloat, locks, manifests, USER-CONFIGURED markers, CSV shape. Trigger on "lint this folder", "validate suite output".
---

# Foldero — Lint Validator

**Version:** v2.1 · Last modified 2026-09-18
**Role:** Read-only validator. Compares the current state of a managed folder against SUITE-CONVENTIONS and every reference doc. Never modifies. Never gates.
**Shared rules:** `references/SUITE-CONVENTIONS.md`. Exempt from the run-lock (§13) because read-only.

## Dependencies & STOP conditions

- Requires the managed folder to have `CLAUDE.md`, `INDEX.md`, `_LOGS/`. STOP and point to the trio if any is missing.
- No run-lock is acquired (this skill is read-only per §13 and §14).
- Does not modify any file, ever. Even a detected defect is only reported.

## Checks performed

### Check 1 — Numbering conformance
Per `references/Numbering-Convention-Rules.md`:
- Top-level folders use the recorded prefix format (padded or unpadded per the folder's own scheme; deviation from that folder's convention is a Warning, not a Fail).
- No gaps suggesting a retired number was reused.
- Naming format matches `NN. Title Case Name` or the folder's local variant.
- Lifecycle-staging pillars (`01. Active/`, `02. Delivered-or-Paused/`, `99. Archive/`) do not nest decimal categories underneath.

### Check 2 — INDEX.md structure
Per SUITE-CONVENTIONS §10:
- Three named sections present: `Taxonomy`, `Awaiting sign-off`, `Activity`.
- `Awaiting sign-off` may be empty (valid) but must exist.
- Every `Awaiting sign-off` entry has a recorded intended destination (per `references/Sensitivity-Classification-Guide.md`) — missing intended destination is a **Fail**.

### Check 3 — CLAUDE.md bloat
Per §9:
- CLAUDE.md must not contain per-run entries. Only rules + a single one-line pointer to `_LOGS/activity-log.md`.
- Warn if line count exceeds 300 lines — suggests bloat.

### Check 4 — Run-lock hygiene
Per §13:
- `_LOGS/.run-lock` present with mtime > 6h → stale-lock Warning.
- **More than 10 `.run-lock.released-*` markers** → Warning, suggest consolidation into `_LOGS/lock-history/` (procedure in `docs/runbooks/marker-rotation.md`). Do not perform the consolidation — the user or a follow-up `/folder-review`-style confirmation does the actual move.

### Check 4a — Collision-suffix vocabulary
Per `references/Collision-Handling.md`:
- Scan `_LOGS/activity-log.md` for suffixes in move destinations. Every observed suffix must be in Collision-Handling.md §2's table.
- Suffixes not in the table → Warning (indicates a skill invented its own suffix).

### Check 5 — `_MANIFEST.md` presence
REVIEW-SORT and REVIEW-TRASH must each carry a `_MANIFEST.md` if populated. Missing manifest on a populated queue is a **Fail**.

CONFIRMED-TRASH (if present) also carries a `_MANIFEST.md`.

### Check 6a — Expected artifacts in `_LOGS/`
Per `references/Report-Templates.md`:
- `activity-log.md` and `import-log.md` present.
- Any run recorded in `activity-log.md` should have a matching dated report file — first-run OR supplementary/correction/revert report per Report-Templates.md's Supplementary-Pass shape. **Missing Report → Fail** (per SUITE-CONVENTIONS §9's "every mutating pass writes a Report" invariant; supplementary passes have no exemption).
- `Data-Integrity-Findings.md` is optional; when present, validate it follows the template shape in Report-Templates.md.

### Check 6b — Migration CSV shape
Per `references/Migration-CSV-Schema.md` §1:
- Every CSV in `_LOGS/` starts with the header row.
- The header contains all 8 standard columns (`old-path,new-path,action,renamed,verify,confidence,tier,reversible`), in that order. Extra columns may follow to the right (permitted extension) — but none of the 8 may be reordered or omitted.
- `action` values are in the canonical vocabulary (§2 of the schema doc).
- Missing header row → Fail. Header present but missing/reordering any of the 8 standard columns → **Fail** (this is a schema-shape defect, not a Warning — data rows built against an incomplete header cannot be parsed reliably by `/folder-undo` or `/folder-dedupe`). Pre-v2.0 CSVs that predate this schema are still flagged as Fail here (never silently grandfathered by the check itself) — the "don't retroactively rewrite" posture from Check 4a/6c applies to whether the *file* gets fixed, not to whether the *lint* reports it accurately.

### Check 6c — Activity-log entry schema
Per `references/Undo-Rules.md` §2:
- Every mutating-run entry in `activity-log.md` carries the required fields (source, destination, action, reversible flag).
- Missing `reversible:` flag → Warning.

### Check 6e — USER-CONFIGURED marker (upgrade safety)
Per SUITE-CONVENTIONS §16:
- Any reference-doc file diverging from the shipped generic template (i.e. showing signs of user customization) must carry the `<!-- USER-CONFIGURED — do not overwrite on plugin update -->` marker.
- Customized-looking file missing the marker → Warning. Procedure to fix in `docs/runbooks/user-configured-verification.md`.

### Check 7 — Atomic-unit integrity
Per `references/Atomic-Unit-Signatures.md`:
- Flag (do not fix) any case in `_LOGS/` reports where a prior run appears to have split or partially moved an atomic unit — this indicates a prior-run bug.
- Empty worktree containers → informational note only (already documented as user-decision territory).

### Check 8 — Orchestrator checkpoint hygiene
Per `ORCHESTRATOR.md` §6:
- Unresolved `_LOGS/.orchestrator-checkpoint-*.md` files older than 24h → Warning (indicates a paused sequence never resumed).

## Output

Write `Lint-Report-[DATE].md` to `_LOGS/` using the format in `references/Report-Templates.md`: Check | Result (Pass/Fail/Warning) | Detail. Summary line at top: total Pass / Fail / Warning counts.

## References

- `references/SUITE-CONVENTIONS.md` — the rules being checked.
- `references/Numbering-Convention-Rules.md` — Check 1.
- `references/Sensitivity-Classification-Guide.md` — Check 2 (intended destination).
- `references/Collision-Handling.md` — Check 4a.
- `references/Report-Templates.md` — Check 6a; also the Lint-Report format itself.
- `references/Migration-CSV-Schema.md` — Check 6b.
- `references/Undo-Rules.md` — Check 6c.
- `references/Atomic-Unit-Signatures.md` — Check 7.
- `ORCHESTRATOR.md` — Check 8.
- `docs/runbooks/marker-rotation.md`, `docs/runbooks/user-configured-verification.md` — remediation procedures.

## Cross-references

- Requires: `CLAUDE.md` + `INDEX.md` + `_LOGS/`. Produces: `_LOGS/Lint-Report-…md`. Never modifies.
- Complement: `/folder-status` (multi-root dashboard, also read-only).
- **Run-lock exempt** per §13.

## Tested against

- 2026-09-17 · v2.0 smoke test on a managed folder with real trio + deepen + correction history: 5 checks passed, 2 warnings surfaced (Report-writing supplementary-pass gap, absence of `Lint-Report-*` file at that point). Findings fed the §0.1 invariant that produced this v2.0.
- 2026-09-18 · v2.1 fix: a re-lint against a live installation's real pre-v2.0 `Deepen-Migration-*.csv` (header `old-path,new-path,action` only) surfaced that Check 6b's old wording ("column order matches the schema" + "missing header row → Fail") let a 3-of-8-column header pass, since the 3 present columns are trivially in-order and the only stated Fail condition didn't cover incompleteness. Reworded to require all 8 standard columns explicitly, with incompleteness now a Fail. See `CHANGELOG.md` v2.1.1.
