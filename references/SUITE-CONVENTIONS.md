# Foldero — Suite Conventions (canonical shared rules)

Single source of truth for rules shared across every skill in this plugin. Where a skill says "per the suite conventions," it means this file. If this file and a skill body ever disagree, this file wins for the shared rules below; the skill body wins for its own step logic.

## 1. Never-delete
Nothing is ever hard-deleted, on either side of any operation. Suspected junk is routed to `00. Inbox/REVIEW-TRASH` for the user's decision. The import skill's Move mode is the only operation that removes a source item, and only after a verified successful copy (copy → verify → then remove).

## 2. Confidence threshold
≥90% confidence to file an item into a taxonomy pillar. Anything below → `00. Inbox/REVIEW-SORT` with a one-line reason.

## 2a. Re-homing exception (destination-identical or trivial-variant match)
A below-90%-confidence item may still be auto-filed, without dropping to `REVIEW-SORT`, if: the destination sub-pillar name is IDENTICAL or a trivial variant of the item's own name, exactly one such destination exists in the taxonomy, and combined match confidence is ≥85%. Narrow exception, not a replacement for §2. Sensitivity tiers always win over this exception.

See `references/File-Type-Heuristics.md` and `references/Sensitivity-Classification-Guide.md`.

## 3. REVIEW-SORT vs REVIEW-TRASH vs CONFIRMED-TRASH
- `00. Inbox/REVIEW-SORT` — below-confidence items, ambiguous plain folders (moved whole, never scattered), quarantined secrets (in a `secrets/` subfolder), and duplicate groups from `/folder-dedupe` (in a `duplicates/` subfolder). Things a human should sort.
- `00. Inbox/REVIEW-TRASH` — `LIKELY-JUNK`: OS-metadata cruft and generically-named empty folders. Suspected disposable, never deleted.
- `00. Inbox/CONFIRMED-TRASH` — items the user has explicitly confirmed as disposable via `/folder-review`. Terminal user-decided state. Still never deleted by the suite; the user may delete manually.

Each review folder carries a `_MANIFEST.md` listing every item and why it was flagged.

## 4. Atomic units
Never inspect, split, or restructure the internals of an atomic unit — move it whole.
- **Repositories:** any folder with `.git`, `package.json`, `node_modules`, build output, `.next`/`.astro`/`.turbo`/`.wrangler`, or worktrees.
- **Application packages:** `.pages`, `.key`, `.numbers`, `.logicx`, `.musiclibrary`, `.lrlibrary`/`.lrcat`, `.djayMediaLibrary`, `.photoslibrary`, `.rtfd`, `.xcodeproj`.
- **Markerless self-contained folders:** two or more structural signals (root entry/index/manifest file; sibling `assets`/`css`/`js`/`img`/`images`/`fonts`; version-suffixed folder name; sequential or paired asset naming).
- **NOT atomic:** a folder that is merely a category of loose files with no entry/manifest and no interdependent structure. A **generically-named container** (`misc stuff`, `New Folder`, `stuff`, `to sort`) is never atomic — this beats atomic-suspicion.
- **Ambiguity fallback:** route the whole folder to `REVIEW-SORT`.

For the full atomic-unit signature list including edge cases (empty worktree containers, markerless self-contained folders, generic-container override), see `references/Atomic-Unit-Signatures.md`.

## 5. Sensitivity — three tiers, and a tier OVERRIDES the pillar a file-type suggests
Classify by name/structure/metadata only; never open contents.
- **`SENS:FILE-BY-NAME`** — name confidently states what it is AND a clear restricted pillar exists. Files normally, logged sensitive. Being financial/legal/PII by *type* alone does not freeze it.
- **`SENS:QUARANTINE`** — raw credentials/keys/password stores/seed phrases. → `REVIEW-SORT/secrets`. Never a normal folder. Wins over any type-based pillar.
- **`SENS:RESTRICTED-DOMAIN`** — clinical/client/safeguarding records, adult content. Gated: always requires explicit user sign-off before any move. Stays in place until signed off, with an **intended destination** recorded. Only `/folder-signoff` clears an `Awaiting sign-off` entry.

For worked tier-classification examples and user-level tier mappings, see `references/Sensitivity-Classification-Guide.md` (three-tier model) and `references/Sensitivity-Defaults.md` (user's per-brand/folder defaults).

## 6. OS-metadata cruft
`.DS_Store`, `Thumbs.db`, `.Spotlight-V100`, AppleDouble `._*`, `desktop.ini` → `LIKELY-JUNK` → `REVIEW-TRASH`. Never placed in the taxonomy, never gated, never hard-deleted.

## 7. Empty folders
Generically-named empty folders (`New Folder`, `untitled folder`, `Untitled`) → `REVIEW-TRASH`. Meaningfully-named empty folders → `KEEP-IN-PLACE` (a distinct disposition; never `REVIEW-SORT`), unless the name maps to an obvious pillar being created, in which case file it there so the domain isn't split.

A REVIEW-TRASH item confirmed by the user via `/folder-review` moves to `CONFIRMED-TRASH` (see §3) — never deleted by the suite.

## 8. Conservation unit
The conservation count's unit is the **top-level item** recorded in the audit inventory: every original top-level file and every original top-level folder node, each counted once; an atomic unit or a gated folder is one item. Never count `find` lines or nested files. Exclude suite-authored files (see §9). Report as `N in → N accounted for`.

## 9. Suite artifacts live in `_LOGS/`, not loose at root and not in CLAUDE.md
The trio's `execute` (Phase A) scaffolds `_LOGS/` at the folder root with `activity-log.md` and `import-log.md` stubs. All suite-authored artifacts go there:
- Dated reports (`Audit-Report-*.md`, `Reorganisation-Plan-*.md`, `Execution-Report-*.md`, `Inbox-Run-*.md`, `Import-Report-*.md`, `Undo-Report-*.md`, `Deepen-Plan-*.md`, `Dedupe-Report-*.md`, `Lint-Report-*.md`, `Status-Report-*.md`, `Signoff-Report-*.md`, `Review-Report-*.md`, `Changelog-*.md`, `Blueprint-*.md`, `Handoff-*.md`, `Repo-Check-Report-*.md`, `Tag-Write-Report-*.md`, and any Supplementary/Correction/Revert Reports per `references/Report-Templates.md`) → `_LOGS/`.
- Every run/move/import entry → `_LOGS/activity-log.md`, following the reversibility-schema in `references/Undo-Rules.md` §2.
- `CLAUDE.md` holds durable **rules only**, plus a single one-line pointer to `_LOGS/activity-log.md` — never per-run entries. This is the anti-bloat rule.
- `INDEX.md` and `CLAUDE.md` themselves stay at the root.

**Every mutating pass writes a dated Report, no exceptions.** This applies to first runs and to supplementary/correction/revert passes. See `references/Report-Templates.md` for shapes.

Report column structure standardised in `references/Report-Templates.md`. Migration CSVs follow `references/Migration-CSV-Schema.md`.

## 10. INDEX.md structure (defined once; skills append to named sections)
`INDEX.md` has exactly three logged sections, created by `plan`/`execute`:
- **Taxonomy** — the folder tree with one-line descriptions and key-file pointers.
- **Awaiting sign-off** — gated `SENS:RESTRICTED-DOMAIN` items and their intended destinations (may be absent = empty, which is valid). Entries are cleared by `/folder-signoff` only — no other skill moves gated items.
- **Activity** — a running log with two entry kinds: moves (from `folder-inbox`/`folder-execute`) and imports (from `folder-import`). Skills append here; they do not invent new log sections.

## 11. Convention precedence (when a folder has no existing convention)
Ordered highest-precedence first:
1. **Live filesystem** — what actually exists.
2. **The folder's own `CLAUDE.md`** — decisions recorded for this specific managed folder.
3. **The user's `TAXONOMY-REFERENCE.md`** (if `/organisation-setup` has been run) — the user's own decided pillar skeleton, applied as a fallback for new or unstructured folders. **Never silently overrides a folder's already-recorded `CLAUDE.md` decision** — a folder whose `CLAUDE.md` predates the user's first `/organisation-setup` run keeps its own structure.
4. **Project `Numbering-Convention-Rules`** — a project-level doc if the managed folder belongs to one.
5. **Plugin's own `references/Numbering-Convention-Rules.md`** — the shipped fallback.
6. **The Folder Structure SOP** — the deep 6–9-tier decimal scheme, applied only by `/folder-deepen`, never in a first pass.

The first pass creates plain, un-numbered functional sub-folders freely (`03. Finance/Tax`, `REVIEW-SORT/secrets`) but imposes no numbered decimal sub-scheme (`03.1`, `03.2`).

## 12. Move mechanics
Every in-folder change is a reversible `mv`. Verify each: source gone AND destination present; `mv -n` skips silently on collision, so always check. On a name collision never overwrite — see `references/Collision-Handling.md` for per-context suffix conventions and REVIEW-SORT fallbacks. Same-volume moves are renames; a cross-mounted-root move is copy-then-remove and needs source-delete permission first.

## 13. Run lock (concurrency)
Every mutating skill (`/folder-execute`, `/folder-inbox`, `/folder-import`, `/folder-undo`, `/folder-deepen`, `/folder-dedupe`, `/folder-signoff`, `/folder-review`, `/folder-tag`, `/organisation-setup`) writes `_LOGS/.run-lock` (skill name + timestamp) at start and clears it at end. On finding a **fresh** lock (< 6 h), STOP and tell the user another run is in progress. A stale lock (≥ 6 h) is ignored with a warning and overwritten.

`/folder-lint`, `/folder-status`, `/folder-changelog`, `/folder-blueprint`, `/folder-repo-check`, and `/folder-handoff` are read-only skills and are **exempt** from the run-lock requirement.

**Released run-lock markers** (`.run-lock.released-*`) are never deleted by any skill (`rm` is refused on some mounts, and consistency trumps convenience). When more than 10 accumulate in a single `_LOGS/` folder, `/folder-lint` flags it as a Warning (not a Fail) and suggests — but does not perform — consolidation into a `_LOGS/lock-history/` subfolder. The user or a follow-up `/folder-review`-style confirmation performs the actual move.

**Sequence-level lock** — when the orchestrator conductor sub-agent drives a multi-skill chain, it acquires an additional `_LOGS/.orchestrator-lock` marker for the duration of the sequence, so a concurrent single-skill invocation from elsewhere doesn't interleave mid-sequence. Individual skills keep their own §13 lock-check logic when invoked directly (not through the conductor).

## 14. Helper skills are advisory
`enterprise-search` (context sweep), `engineering:documentation` (CLAUDE.md formatting), `desktop-commander:knowledge-base` (INDEX/knowledge-base formatting), `data:explore-data` / `data:data-context-extractor` (import source characterisation). Use each if available; otherwise do the work directly. Absence of any helper never blocks a run.

`/folder-lint`, `/folder-status`, `/folder-changelog`, `/folder-blueprint`, `/folder-repo-check`, and `/folder-handoff` are read-only advisory skills that complement the mutating skills; their absence never blocks a run of any other skill.

## 15. Skill boundaries (disambiguation)
`/folder-inbox` processes *new* items that have arrived in `00. Inbox` but have not yet been classified. `/folder-review` works the *already-classified-and-flagged* queues (`REVIEW-SORT`, `REVIEW-TRASH`). The two skills do not overlap: if the user's request is ambiguous, `/foldero` (the router) should ask whether they mean new arrivals or the flagged backlog before routing.

## 16. Upgrade-safe configuration protection
Every file written or updated by `/organisation-setup` carries a header marker:

```
<!-- USER-CONFIGURED — do not overwrite on plugin update -->
```

Files affected: `Brand-Taxonomy-Reference.md`, `TAXONOMY-REFERENCE.md`, `File-Type-Heuristics.md` (user-appended section), `Numbering-Convention-Rules.md` (if overridden), `Enterprise-Domain-Archetypes.md` (user extension), `Sensitivity-Defaults.md`, `Metadata-Tag-Vocabulary.md` (user extension).

The plugin's own update/sync process should check for that marker before touching any file under `references/` — a marked file is never silently replaced by a new shipped default. Cowork/Claude Code sync behaviour honouring this marker is a **convention the plugin declares, not a guarantee it can force** — see `docs/runbooks/user-configured-verification.md` for verification procedure.

`/folder-lint` check 6e verifies: any reference-doc file showing signs of user customization (i.e. diverges from the shipped generic template) carries the `USER-CONFIGURED` marker. Missing marker on a customized-looking file → Warning (indicates the protection wasn't applied correctly during a setup run).

## 17. Orchestrator architectural layer
An orchestration layer sits above the router for genuine multi-skill requests. Documented in `ORCHESTRATOR.md` at the plugin root; implemented by the conductor sub-agent at `agents/decurion.md`. The conductor sequences skill invocations, arbitrates the sequence-level run-lock (§13), propagates current user config (from `/organisation-setup` outputs) to each invoked skill, owns cross-skill state resolution, and pauses/resumes on mid-chain escalation.

The conductor is **not a skill** — it is not counted among the 21 skills, not invoked via `/folder-*` slash commands, and does not have its own SKILL.md. It is bound by the same SUITE-CONVENTIONS guarantees as every skill it invokes: never-delete, ≥90% confidence + §2a exception, atomic units, sensitivity tiers, run-lock semantics. The conductor never touches `~/.claude/` or `~/.claude.json` itself; those boundaries belong to `/folder-execute` (mid-chain) and `/folder-audit-fix-claude` (retroactive) alone (see `references/Claude-Code-Continuity.md`).

## 18. BRAIN.md — persistent decision memory, hierarchical trickle-up

Every folder Foldero creates or manages via `/folder-execute` (Legatus) that becomes a new organised subtree gets a `BRAIN.md` at creation time, alongside `CLAUDE.md`/`INDEX.md`. So does every ancestor folder between that new subtree and the nearest already-managed root (inclusive), created if it doesn't already exist. Never inside an atomic unit (§4) — an atomic unit is one conservation-counted item in its parent's rollup, never a subtree of its own. Never in `_LOGS/`, `REVIEW-SORT/`, or `REVIEW-TRASH/`.

**Two-tier content shape:**
- **Leaf `BRAIN.md`** (no managed child subtrees below it): INDEX section (taxonomy version, most recent major decision, open flags) + dated append-only entries (date, skill invoked, decision, confidence, correction if any) — a distilled lesson layer one level above `_LOGS/`'s raw history, never a narrative log.
- **Parent `BRAIN.md`** (one or more child subtrees, each with their own `BRAIN.md`): INDEX section extended with a **child-rollup table** — one row per direct child: path, child's current taxonomy version, child's most recent major decision (one line, pulled from the child's own INDEX, not re-derived), count of open flags in that child, last-sync timestamp. No dated entry log of its own unless the parent folder is itself a direct target of moves/decisions independent of its children. This keeps the true root's `BRAIN.md` cheap to read regardless of tree depth — O(depth) reads for full-tree status, not O(node count).

Only Praeco and the Decurion read a folder's INDEX by default. A parent's rollup table usually satisfies routing without descending into children; a skill descends into a specific child's own `BRAIN.md` only when it needs decision-level detail the rollup can't answer.

Never auto-deleted or silently rewritten. Rollup-table rows are a status table, not a history — in-place update of a row (taxonomy version, latest decision, open-flag count, last-sync timestamp) is legitimate and does not violate never-delete, since the prior value remains recoverable from the child's own dated entry log. Everything else (child dated entries; any ancestor's own direct dated entries, for the parent-as-direct-target case) stays append-only.

Scope-bounded to Foldero's own managed tree: the ancestor walk stops at the nearest registered managed root (per `/organisation-setup`) or the filesystem root, whichever comes first — never assumes a specific user's folder depth or drive layout.

Distinct from `/organisation-setup`'s USER-CONFIGURED docs (plugin-install-scoped, global fallback config; BRAIN.md is per-target, per-organised-folder).

**Current limitation (v2.2.0):** only `/folder-execute` is wired to write the `_LOGS/.pending-brain-entry` staging file that feeds a BRAIN.md leaf entry. The other standalone mutating skills' moves remain fully captured in their own dated `_LOGS/` reports and `_LOGS/activity-log.md` per §9's invariant — nothing is unlogged — but they do not yet produce a BRAIN.md lesson-layer entry. Expanding staging-file writes to the remaining mutating skills is deferred, scoped follow-up work, not an oversight.

**Token-budget convention (skill report outputs):** Lint-Report, Status-Report, audit summaries, and similar skill-generated reports stay under ~150 words per section — counts/categories/exceptions only, never raw file-by-file listings. This formalizes existing behavior (no skill in this suite currently dumps raw listings) rather than imposing a new constraint.
