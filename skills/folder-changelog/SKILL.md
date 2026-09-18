---
name: folder-changelog
description: Read-only. Synthesises _LOGS/activity-log.md into a human-readable narrative changelog cross-linking dated Reports. Trigger on "summarise what's happened", "give me a changelog", "history of this folder".
---

# Foldero — Changelog

**Version:** v1.0 · Last modified 2026-09-17
**Role:** Standalone, read-only skill that synthesises `_LOGS/activity-log.md` (and `import-log.md`) across all runs into a human-readable narrative changelog — distinct from per-run dated Reports, which are technical/tabular. This is the "what has happened to this folder over time, in plain English" view.
**Shared rules:** `references/SUITE-CONVENTIONS.md`. Exempt from the run-lock (§13) because read-only.

## Dependencies & STOP conditions

- Requires the managed folder to have `CLAUDE.md`, `INDEX.md`, `_LOGS/activity-log.md`. STOP if any is missing.
- No run-lock acquired.
- Never modifies any file.

## Procedure

1. **Parse `_LOGS/activity-log.md`** — walk every recorded run in chronological order (oldest first). Each run has a header (`## Run: [skill-name] · [date]`) and a body of entries.
2. **Parse `_LOGS/import-log.md`** — imports are also summarised here; cross-link.
3. **Group by date and skill.** Consecutive runs of the same skill on the same day are one paragraph.
4. **Annotate reversibility.** Use `references/Undo-Rules.md` invariants to determine whether each historical run remains reversible today or has been locked in by subsequent activity. Note this per paragraph.
5. **Cross-link dated Reports.** For each run, if a matching Report file exists in `_LOGS/`, link to it. If missing (a violation of SUITE-CONVENTIONS §9's "every mutating pass writes a Report" rule), note it in the changelog for `/folder-lint`'s downstream check.
6. **Compose the narrative.** One paragraph per run, plain English, summarising what changed and why. Include counts (moves, scaffolds, flagged), tier awareness, and outcome. Avoid tabular data — that's what the dated Reports are for.

## Sections in the changelog

- **Overview** — one-paragraph summary of the folder's history (how many runs total, first-run date, most-recent-run date).
- **Timeline** — chronological narrative, grouped by date.
- **Currently reversible runs** — a short list at the end citing the most recent runs that `/folder-undo` could still walk back cleanly.
- **Locked-in decisions** — runs whose reversibility window has passed or that have been superseded, noted for reference.
- **Open items** — cross-reference to REVIEW-SORT / REVIEW-TRASH / Awaiting-sign-off counts (defers to `/folder-status` for the numeric dashboard).

## Output

Write `Changelog-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`.

## References

- `references/Undo-Rules.md` — reversibility annotation.
- `references/Report-Templates.md` — Changelog format.

## Cross-references

- Complements: `/folder-status` (dashboard snapshot), `/folder-handoff` (packages current state), `/folder-blueprint` (documents the system).
- Requires: `_LOGS/activity-log.md`. Produces: `_LOGS/Changelog-…md`.
- **Run-lock exempt** per §13.

## Tested against

_(fill in after first use: run count, changelog length, outcome.)_
