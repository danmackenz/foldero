---
name: folder-execute
description: Chain Step 3 — the executor. Scaffolds taxonomy, writes CLAUDE.md/INDEX.md, moves files with reversible mv, logs every move. Trigger on "execute the plan", "go ahead and reorganise".
---

# Foldero — Execute

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Executor — the only trio skill that changes the filesystem.
**Chain position:** Step 3 of 3. Consumes `_LOGS/Reorganisation-Plan-*.md`.
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## Dependencies & STOP conditions

- Requires a complete Reorganisation-Plan. STOP if missing/incomplete, if the working root changed since audit, or (Guided) if the user hasn't approved the plan.
- Acquire the run-lock (§13) before any change; STOP if a fresh lock is held; release at the end.
- Any planned "delete" is converted to a `REVIEW-TRASH` route and flagged. The suite never deletes.
- **Every mutating pass writes a dated Report** per SUITE-CONVENTIONS §9 — no exceptions, including supplementary/correction passes.

## Execution sequence

### Phase A — Scaffolding
Create all taxonomy folders. Move nothing yet. Ensure `00. Inbox/REVIEW-SORT`, `00. Inbox/REVIEW-TRASH`, and `_LOGS/` exist; seed `_LOGS/activity-log.md` and `_LOGS/import-log.md` stubs.

On the first successful run against this root only, also create `BRAIN.md`: an empty INDEX (taxonomy version = this run's, no prior decisions, no open flags), no dated entries yet if this is a leaf. If this run creates a new managed subtree beneath an existing managed root, also create (or update) `BRAIN.md` in every ancestor folder between the new subtree and the nearest managed root, giving each a child-rollup table entry for the new subtree per SUITE-CONVENTIONS §18. Subsequent runs never recreate an existing `BRAIN.md` — see §18.

### Phase B — CLAUDE.md & INDEX.md
Write tailored `CLAUDE.md` and `INDEX.md` (three sections per §10) from the plan's drafts, to the root. Ensure `CLAUDE.md` ends with a single one-line pointer to `_LOGS/activity-log.md`. Use `engineering:documentation` / `desktop-commander:knowledge-base` if available.

If either file already exists, **merge** — preserve every recorded rule and append; never overwrite wholesale.

### Phase C — File moves (CONFIDENT + SENS:FILE-BY-NAME)
Execute every ≥90% routing with reversible `mv`, including confidently-named sensitive files to their restricted pillar (logged "sensitive — filed by name, contents not opened"). Sensitivity tier always wins over the type-based pillar.

Immediately before each `mv`, write `_LOGS/.pending-brain-entry` as JSON: `{"skill": "folder-execute", "decision": "<one-line reason this item routed here>", "confidence": "<this item's classified confidence>"}`. The PostToolUse hook consumes and deletes this file automatically after the move completes — no cleanup needed here even on failure, since a stale unconsumed staging file simply means the next successful move's hook invocation overwrites it before reading (the hook always reads-then-deletes on its own next trigger, never accumulates).

Log each move to `_LOGS/activity-log.md` per `references/Undo-Rules.md` §2 (reversibility schema). Collisions handled per `references/Collision-Handling.md` (never overwrite).

### Phase C-Claude — Claude Code project pre-move gate
For any folder flagged `CLAUDE-CODE-PROJECT` by `/folder-audit` (per `references/Claude-Code-Continuity.md` §2 signals) that is about to be moved or renamed, **pause before executing the move** and present the four options per `Claude-Code-Continuity.md` §4:

1. **Recommended — Claude-integrated migration.** Perform the move, then update the corresponding Claude Code session/project metadata to reference the new path. Requires: runtime verification of the current Claude Code storage layout, a reversible checkpoint/backup of the affected `~/.claude/projects/<encoded-old-path>/` and the `~/.claude.json` entry, and defined post-action verification. If any precondition cannot be met, this option is **not offered as executable** — say so plainly rather than approximating.
2. **Balanced-safe compatibility strategy.** Use a documented reversible mechanism (e.g. a symlink, only where verified safe on this filesystem/platform/Claude version) rather than rewriting Claude state directly.
3. **Skip continuity remediation.** Move the folder only; leave the session history orphaned; report the risk clearly.
4. **Other.** User-specified handling within the plugin's safety envelope.

Never silently edit `~/.claude/` or `~/.claude.json`. Never claim path migration preserves sessions until post-action verification succeeds. The four-option gate is the ONLY way `/folder-execute` reaches outside the managed `Documents` tree.

The chosen option's outcome (executed action, verification result, `reversible:` flag per `Undo-Rules.md` §2) is recorded both in the Execution-Report and in `_LOGS/activity-log.md`. In Hands-Off mode, the user is still prompted for the per-folder choice — this decision is never auto-selected.

When a chain (audit→plan→execute) hits a flagged folder mid-sequence, `decurion` may own the pause per `ORCHESTRATOR.md` §6 — the chain suspends via `_LOGS/.orchestrator-checkpoint-*.md` until the user picks an option.

### Phase D — Review, quarantine, cruft, in-place
- `NEEDS-REVIEW` → `REVIEW-SORT` (whole, never scattered).
- `SENS:QUARANTINE` → `REVIEW-SORT/secrets`. Never a normal folder.
- `LIKELY-JUNK` → `REVIEW-TRASH`.
- `KEEP-IN-PLACE` → leave and log.
- `SENS:RESTRICTED-DOMAIN` → moved **only if signed off**; otherwise stays in place, recorded in INDEX "Awaiting sign-off" with intended destination. Only `/folder-signoff` clears these.
- Write `_MANIFEST.md` into REVIEW-SORT and REVIEW-TRASH.

### Phase E — Verification & container cleanup
- Each move: confirm source gone, destination present.
- **Conservation check (§8):** every original top-level item accounted for. Report `N in → N accounted for`. Resolve any real discrepancy before continuing.
- Emptied-container cleanup: an original container left empty after draining → `REVIEW-TRASH` if generically named, else `KEEP-IN-PLACE`.

### Phase F — Document update
Update `INDEX.md`'s Taxonomy section to the actual post-execution tree and Awaiting-sign-off section for any gated items. Append run summary to `_LOGS/activity-log.md`. **Do not** write per-run entries into `CLAUDE.md`.

## Output

Write `Execution-Report-[FOLDERNAME]-[DATE].md` to `_LOGS/` per `references/Report-Templates.md` — **three-column split (Moves / Scaffolds / Flagged) mandatory**. Companion migration CSV per `references/Migration-CSV-Schema.md`. Release the run-lock.

**Supplementary/correction/revert passes:** always write a dated Report per Report-Templates.md's Supplementary-Pass shape. No pass ever appends to activity-log.md without producing a report.

## Mode-dependent close

- **Hands-Off:** produce the report and completion summary. Offer `/folder-deepen` if audit flagged deep-pass candidates.
- **Guided:** present the report and ask whether to proceed to a deeper pass or close out.
- **Manual:** runs only Phase A + B (scaffold), never Phase C moves.

## References

- `references/Report-Templates.md` — Execution-Report three-column format; supplementary-pass shape.
- `references/Migration-CSV-Schema.md` — migration CSV columns and action vocabulary.
- `references/Collision-Handling.md` — per-context suffix conventions.
- `references/Undo-Rules.md` — activity-log entries carry reversibility schema.
- `references/Sensitivity-Classification-Guide.md` — never moves Tier 2 or Tier 3; Tier 3 sign-off is `/folder-signoff`.
- `references/Claude-Code-Continuity.md` — the four-option pre-move gate in Phase C-Claude for `CLAUDE-CODE-PROJECT`-flagged folders; the hard-exclusion boundary for `~/.claude/` and `~/.claude.json`.

## Cross-references

- Consumes: `_LOGS/Reorganisation-Plan-…md`. Produces: `_LOGS/Execution-Report-…md`; live `CLAUDE.md` + `INDEX.md`; `_MANIFEST.md` per review folder; seeded `_LOGS/`. Reversible via `/folder-undo`.
- After a full run the folder is ready for `/folder-inbox`, `/folder-import`, `/folder-deepen`, `/folder-review`, `/folder-dedupe`, `/folder-tag`, `/folder-blueprint`, `/folder-handoff`, `/folder-changelog`.

## Tested against

- 2026-09-15/17 · Live tested on a managed folder with real hybrid-state resolution + 46-file Inbox drain. Conservation held with zero deletions.
