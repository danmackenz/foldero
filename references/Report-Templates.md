# Report Templates (Foldero Plugin — references/)

Standardises the column structure and naming pattern for every dated report the suite produces into `_LOGS/` (SUITE-CONVENTIONS §9). Applies to first-run passes AND supplementary/correction/revert passes — the "every mutating pass writes a Report" invariant (§9) has no exceptions.

All reports live in `_LOGS/`, are dated in the filename (`Report-Name-YYYY-MM-DD.md`), and are never placed at folder root or referenced from `CLAUDE.md` beyond the single activity-log pointer permitted by §9.

---

## Shared header block (every report type)

```
# [Report Type] — [Folder Root Name] — [Date]

**Skill:** /folder-[name] vN.N
**Run started:** [timestamp]
**Run completed:** [timestamp]
**Conservation check:** N in → N accounted for (per SUITE-CONVENTIONS §8)
```

For supplementary/correction/revert passes, add:

```
**Pass type:** first-run | correction | revert | supplementary
**Prior run reference:** [path or date of the run this pass follows up on]
```

---

## First-run reports

### `Audit-Report-*.md` (from `/folder-audit`)
- Top-level inventory table: Name | Type | Size | Last Modified | Purpose Guess | Confidence
- Depth snapshot per top-level folder.
- Brand content map (only if brand evidence found).
- Mess signals list.
- Naming convention check.

### `Reorganisation-Plan-*.md` (from `/folder-plan`)
- Proposed taxonomy tree with one-line description per pillar.
- Move map: Source | Destination | Confidence | Tier (if sensitive).
- Awaiting sign-off preview: items that will need Tier 3 gating.
- Cross-brand ambiguity log (new): items whose signals matched two or more registered brands with comparable confidence.

### `Execution-Report-*.md` (from `/folder-execute`)
Three-column split (mandatory — never merge Scaffolds into Moves):
- **Moves** — Source | Destination | Verified (Y/N).
- **Scaffolds** — Path | Reason.
- **Flagged** — Item | Destination Queue | Reason.

Report the count of each column separately, then a combined total.

### `Inbox-Run-*.md` (from `/folder-inbox`)
- New arrivals processed: Item | Destination | Confidence | Tier.
- Explicitly excludes anything already in REVIEW-SORT/REVIEW-TRASH from a prior run.

### `Import-Report-*.md` (from `/folder-import`)
- Source | Destination | Mode (Copy/Move) | Verified (Y/N) | Source removed (Y/N, Move mode only).

### `Deepen-Plan-*.md` and `Deepen-Report-*.md` (from `/folder-deepen`)
- Deep sub-numbering proposal: Pillar | New Sub-Structure | Rationale.
- Re-homing exception log (§2a): Candidate | Destination Tested | Name-Match Result | Applied (Y/N).
- Three-column split (Moves / Scaffolds / Flagged) same as Execution-Report.

### `Dedupe-Report-*.md` (from `/folder-dedupe`)
- Duplicate group table: Group ID | Items (list) | Match Basis | Confidence | Routed to REVIEW-SORT (Y/N) | Sensitivity Flag.

### `Signoff-Report-*.md` (from `/folder-signoff`)
- Item | Recorded Destination | User Decision (Approve/Reject/Redirect) | Final Destination | Timestamp.

### `Review-Report-*.md` (from `/folder-review`)
- Item | Source Queue (REVIEW-SORT/REVIEW-TRASH) | User Decision | Final Disposition.

### `Tag-Write-Report-*.md` (from `/folder-tag`)
- File | Existing Tags | Tags Written | Confirmation Received (Y/N).
- Companion CSV `Tag-Write-Log-*.csv` per `references/Migration-CSV-Schema.md`.

### `Lint-Report-*.md` (from `/folder-lint`)
- Check | Result (Pass/Fail/Warning) | Detail.
- Summary line at top: total Pass / Fail / Warning counts.

### `Status-Report-*.md` (from `/folder-status`)
- Per scanned root: Root Path | Last Run Type/Date | REVIEW-SORT | REVIEW-TRASH | Sign-off | Lock | Last Lint | Detected Archetype.

### `Changelog-*.md` (from `/folder-changelog`)
- Grouped by date, one paragraph per run in plain English, cross-linking to the relevant dated Report.
- Annotates which runs remain reversible per `references/Undo-Rules.md`.

### `Blueprint-*.md` (from `/folder-blueprint`)
- Taxonomy tree with one-line-per-pillar description.
- Naming conventions in use (reference `references/Numbering-Convention-Rules.md` where applicable).
- "How to replicate this setup" section pointing to `/organisation-setup`.

### `Handoff-*.md` (from `/folder-handoff`)
- Current State (one paragraph summary).
- Open Items Requiring Decision (pulled from REVIEW-SORT, REVIEW-TRASH, Awaiting-sign-off).
- Recommended Next Skill(s) To Run.
- Anything Time-Sensitive.

### `Repo-Check-Report-*.md` (from `/folder-repo-check`)
- Per repo: Path | .gitignore Present (Y/N) | In Repositories Pillar (Y/N) | Empty Worktree Container Flag | Suite Artifacts Inside Repo Flag.

### `Undo-Report-*.md` (from `/folder-undo`)
- Reversed: Current Location | Reverted-To Location | Verified (Y/N).
- Skipped: Entry | Skip Reason (per `references/Undo-Rules.md` §3).

---

## Supplementary / Correction / Revert reports (§9 — the "every pass writes a Report" invariant)

Any mutating pass that is not a first-run of its skill still writes a dated Report, however small. Naming:

- `[Skill-Name]-Correction-Report-YYYY-MM-DD.md` — for corrections applied to a prior run's decisions.
- `[Skill-Name]-Revert-Report-YYYY-MM-DD.md` — for reversions (distinct from `/folder-undo`'s full-run reversal; a Revert-Report is written when a skill reverts a specific decision within its own domain, e.g. `/folder-deepen` reverting a re-homing decision).
- `[Skill-Name]-Supplementary-Report-YYYY-MM-DD.md` — for anything else (a mid-session fix, an addendum run).

Minimum table:

| Item | Prior State | New State | Reason |
|---|---|---|---|

Header includes `**Pass type:** correction|revert|supplementary` and `**Prior run reference:**`.

---

## `Data-Integrity-Findings.md` (folder root of `_LOGS/`, not dated in the filename)

Ongoing findings log — not per-run. Written by any skill or by the user manually.

```
# Data Integrity Findings — [Folder Root Name]

## §[N] — [Short title]
[Finding, evidence, disposition — never auto-resolved; always "user's call" for anything destructive-adjacent.]
```

Optional — not every folder has findings. When present, `/folder-lint` check 6a validates its structure.

---

## Migration CSVs

Every CSV follows `references/Migration-CSV-Schema.md` — standard columns, canonical `action` vocabulary, header row required.

---

## General rule for all reports

If a column's definition could be ambiguous (e.g. does "Moves" include scaffolded folders), state the definition inline in the report's header block rather than assuming the reader remembers this file — this reference standardises the *template*, but each report should still be self-explanatory in isolation.
