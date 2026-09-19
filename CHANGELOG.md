# Changelog — foldero

Semantic versioning. Every mutating change to the plugin's public surface is called out. Format: [Added / Changed / Fixed / Removed / Deprecated / Security].

---

## [2.2.0] - 2026-09-19

### Added
- BRAIN.md persistent decision memory, hierarchical trickle-up (SUITE-CONVENTIONS §18): every managed subtree gets a leaf BRAIN.md; every ancestor up to the nearest managed root gets a parent BRAIN.md with a child-rollup table, kept in sync by the same PostToolUse hook that writes the leaf entry — full-tree status readable in O(depth), not O(node count).
- Hooks for structurally-enforced run-lock, hard-delete blocking, sign-off gating, and move-verification (source-gone/destination-present); BRAIN.md leaf-append and ancestor-rollup are now hook-driven, zero-token bookkeeping.
- `/folder-lint` rollup-freshness check (Warning-class) for stale child-rollup rows; `/folder-signoff` pruning check for oversized leaf BRAIN.md.
- Optional subtree-rollup sections in `/folder-blueprint` and `/folder-handoff`, surfaced only when a folder's own BRAIN.md has a child-rollup table.
- New standalone skill Artifex (`/folder-project-setup`) — interviews, matches project archetypes, researches industry convention, and scaffolds a brand-new project folder from nothing, wiring it into the BRAIN.md rollup chain like any other new managed subtree. Three new reference docs: `Project-Archetype-Library.md`, `Industry-Taxonomy-Index.md`, `Project-Scaffold-Templates.md`.
- Token-budget convention for skill outputs and reference docs (SUITE-CONVENTIONS).

### Changed
- Renamed `agents/orchestrator-conductor.md` to `agents/decurion.md` (Roman-themed naming pass, no behavior change).
- Rebuilt README skills table and renamed "the twenty skills" section to "The Foldero Machina" (Praeco Portarum / Praetorium / Triumviri Catenae / Decuria Praecipua / Seviri Architecti), reflecting the new 21-skill/17-reference-doc count.
- Plugin description shortened and clarified.

### Fixed
- LICENSE formatting (header/subtitle/rule, no legal-text changes).

### Investigated, no action
- §1-2-5 packaging scope (no `files` field exists in this plugin manifest system; git-source installs ship the whole repo, no allowlist mechanism available without a disproportionate `git-subdir` repo restructure — `brand/`, favicons, and `foldero-landing.html` continue shipping as before).
- §9 plugin icon and §10 subtitle/tagline fields — neither exists in the current plugin manifest schema.

### Known limitations
- BRAIN.md leaf entries are currently only produced by `/folder-execute`'s moves (it's the only skill wired to write the `_LOGS/.pending-brain-entry` staging file the append hook consumes). The other standalone mutating skills' moves remain fully captured in their own dated `_LOGS/` reports and `_LOGS/activity-log.md` — nothing is unlogged — but don't yet produce a BRAIN.md lesson-layer entry. Expanding staging-file writes to the remaining mutating skills is scoped, deferred follow-up work (see SUITE-CONVENTIONS §18).
- Neither `/folder-lint` nor `/folder-status` currently detects an untracked/unattributed filesystem change under a managed root (no item-count-vs-stored-baseline comparison exists in either skill today) — a separate drift-detection gap, not addressed in this pass.

### Note on version rationale
This ships as a minor version (v2.2.0), not a patch, because it introduces genuinely new runtime mechanisms (hierarchical BRAIN.md, hooks, structural token-efficiency changes) **and** a wholly new skill plus three new reference documents and orchestrator changes — both factors independently justify a minor bump, not branding alone.

---

## v2.1.3 · 2026-09-18 — Rebrand: Folder Organiser → Foldero

### Changed

- **Plugin renamed from "Folder Organiser" to "Foldero"** across every shipped file: `plugin.json` (`name` field), `README.md` (title, badges, all prose), `SUITE-CONVENTIONS.md`, every other reference doc that named the plugin, and every skill/agent frontmatter `description` field.
- **Router skill fully renamed**, not aliased: `skills/folder-organiser/` → `skills/foldero/`; the command slug is now `/foldero`. There is no prior shipped install of this plugin, so no backward-compatibility path was needed and none was added — `/folder-organiser` no longer resolves.
- **All other skill command slugs are unchanged** — `/folder-audit`, `/folder-plan`, `/folder-execute`, `/organisation-setup`, and the other fifteen skills keep their existing names. Only the router and the product's brand name changed.
- **Historical entries below this one are untouched.** They describe what shipped under the old name at the time — rewriting their wording would misrepresent what those past releases actually said. This entry is the record of the rename itself, not a retroactive relabelling of prior versions.
- **Semver note:** a full product rebrand plus a visual redesign of the landing page is arguably minor-bump (2.2.0) material under strict semver, not patch-bump material — a rename changes the public-facing identity of the package, which is more than a backwards-compatible fix or tweak. `2.1.3` was applied instead, per explicit instruction, since the router-slug break aside, no skill's inputs/outputs/behavior changed. Logged here as the judgment call it was, not a default the versioning scheme itself endorses.

---

## v2.1.2 · 2026-09-18 — Public release readiness

Documentation and generalisation pass only — no skill logic, check behaviour, or reference-rule semantics changed. Patch bump reflects that.

### Changed

- **Personal-data genericisation audit.** Swept every skill body, reference doc, README, and CHANGELOG for hardcoded personal examples (a specific installer's real name/business, secondary/family brand names, literal absolute folder paths). Found and fixed two instances — both were real-world provenance notes describing the actual installation that surfaced the v2.1.1 Check 6b bug, not illustrative examples:
  - `CHANGELOG.md` (v2.1.1 entry, ×2) — "a live installation's ... `Deepen-Migration-*.csv`" replacing the real installer's business name and exact filename.
  - `skills/folder-lint/SKILL.md` ("Tested against") — same generalisation.
  - Confirmed clean elsewhere: `references/TAXONOMY-REFERENCE.md` and `references/Sensitivity-Defaults.md` already ship as proper empty templates (generic placeholders only, explicit "contains no user data" footers); `Brand-Taxonomy-Reference.md` is correctly never shipped at all — it's a runtime artifact `/organisation-setup` generates per-installation, referenced by name in five skill bodies but with no shipped content of its own. `plugin.json`'s `author.name` field is real authorship metadata, not an illustrative example, and was correctly left untouched.
- **`README.md` rewritten for a public, no-prior-context audience.** Added a dedicated `## Installation` section and restructured `## Quickstart` to open with "run `/organisation-setup` first, before anything else" as the single most important instruction. Reworded the opening to state plainly this is a general-purpose tool for anyone with a messy folder tree, not built around any one profession or industry. The one photography/creative-adjacent example (the "Creative Professional × Technical hybrid" archetype note) is now explicitly marked `(illustrative example only...)`. Confirmed present and unchanged: the "Plugin design principle — description length" section, and the OS support disclaimer (macOS-tested, Windows/Linux unverified). Added version/license/platform/skill-count badges and a table of contents (cosmetic, GitHub-Markdown-only — no CSS, no separate styling system, since a plugin README has none to carry).
- **Confirmed skill/reference-doc counts consistent** across `CONTRIBUTING.md`, `README.md`, `ORCHESTRATOR.md` §3.5, and `references/SUITE-CONVENTIONS.md` — all state 20 skills / 14 reference docs. No changes needed; the only "19/13" strings anywhere are `CHANGELOG.md`'s own v2.0.0 historical entry, which correctly preserves the count as it was at that release.

### Fixed

- **`skills/folder-audit-fix-claude/SKILL.md` frontmatter `description` exceeded the plugin's own 250-character guideline (was 376 characters).** Cause: the four trigger phrases were duplicated into the frontmatter description in addition to already being listed in the skill body's own `## Trigger phrases` section — not a justified routing-clarity exception, just redundant duplication introduced when the skill was added in v2.1.0. Trimmed the frontmatter to the description only (234 characters); the body's `## Trigger phrases` section is untouched, so no trigger phrase was lost. Verified via a full smoke test (`claude plugin list`/`details` — plugin loads cleanly, all 20 skills discoverable; `/folder-status` and `/folder-lint` re-run against a live installation — no regression) that this was the only one of the 20 skills over the limit.

---

## v2.1.1 · 2026-09-18 — Check 6b completeness fix

### Fixed

- **`/folder-lint` Check 6b logic bug** — the check's wording ("column order matches the schema" + "missing header row → Fail") never stated that all 8 standard columns from `Migration-CSV-Schema.md` §1 must be present. A CSV with only the first 3 columns (`old-path,new-path,action`) satisfied both stated conditions — the 3 present columns are trivially in schema order, and the header row isn't "missing" — so a lint run following the checklist literally reached a false Pass. Reworded to require all 8 standard columns explicitly, with an incomplete or reordered header now an explicit **Fail**. Found via a real-world re-lint on a live installation, against a pre-v2.0 migration CSV (`old-path,new-path,action` header only), which the v2.1.0-era lint had passed despite carrying only 3 of the 8 required columns.

### Known gaps (not retroactively rewritten — same posture as the v2.1.0 Check 4a/6c fixes below)

- **Pre-v2.0 Migration CSVs may have fewer than 8 columns.** `Migration-CSV-Schema.md` was introduced in v2.0.0 (2026-09-17); CSVs written before that date — e.g. a pre-v2.0 `Deepen-Migration-*.csv` (`old-path,new-path,action` only) — legitimately predate the schema. This release does not retroactively rewrite them. `/folder-lint` Check 6b (as fixed above) now reports this accurately as a Fail rather than silently passing it, so the gap is visible rather than hidden — but the file itself is left as historical record. New CSVs from v2.0 forward already emit the full 8-column schema; only pre-v2.0 CSVs are affected.

---

## v2.1.0 · 2026-09-18 — Claude Code project continuity

### Added

- **New skill `/folder-audit-fix-claude`** — retroactive Claude Code project-continuity check. Signal-based detection (`.claude/`, `CLAUDE.md`, `.mcp.json` — never folder-name heuristics). Scan mode is default and read-only; remediation mode is opt-in, per-finding, gated. The only skill authorised to touch `~/.claude/` or `~/.claude.json`, and only under the four-option per-finding gate with runtime-verified preconditions, a reversible checkpoint, and post-action verification. **Preflight** runs storage-schema and symlink-safety verifications **once per remediation-mode session** (cached in the checkpoint), not per finding, and offers an optional bulk-triage step so the user can pre-declare per-finding intended choices without deciding live at each step.
- **New reference doc `references/Claude-Code-Continuity.md`** — the mechanism: hard-exclusion boundary for `~/.claude/` and `~/.claude.json`, signal-based detection rules, the four-option remediation model, uncertainty and confidence rules, **the standard consent flow (§8) for reading `~/.claude/` global state — per-finding, never blanket, always re-requested per session, always revocable, scoped to specifically-named state**, and what this plugin does NOT do.
- **`/folder-audit` Step 2 item 10** — Claude Code project-folder detection. Flags folders carrying `.claude/`, `CLAUDE.md`, or `.mcp.json` signals as `CLAUDE-CODE-PROJECT`. Informational at audit time; flag propagates forward to `/folder-plan` and `/folder-execute`.
- **`/folder-execute` Phase C-Claude** — pre-move decision gate for `CLAUDE-CODE-PROJECT`-flagged folders. Four options: Recommended (Claude-integrated migration, only when preconditions verified), Balanced-safe (reversible compatibility strategy), Skip (accept orphan risk, report clearly), Other (user-specified). Never silently edits Claude global state. Never claims path migration preserves sessions until post-action verification succeeds.
- **`orchestrator-conductor` ownership of mid-chain Claude Code continuity** (`ORCHESTRATOR.md` §2.6). When an audit→plan→execute chain reaches a flagged folder, the conductor pauses at Phase C-Claude, presents the four options via checkpoint, and resumes after the user selects. Conductor never touches `~/.claude/` itself.
- **Root `CHANGELOG.md`** — this file. Consolidates version history so public users can see what changed without diffing files.

### Changed

- **Total skill count: 20 (was 19).** `/folder-audit-fix-claude` added.
- **Total reference doc count: 14 (was 13).** `Claude-Code-Continuity.md` added.
- **`plugin.json` version 2.1.0** — bumped from 2.0.0. Description updated to reflect the continuity capability and hard-exclusion boundary.
- **`references/Undo-Rules.md` §5a** — pre-schema (`reversible: unknown`) handling. Activity-log entries written before the reversibility schema was in force are treated as `reversible: unknown` by `/folder-undo`, never silently as either `yes` or `no`. Requires per-entry user confirmation before executing the reverse.
- **`/folder-undo` Procedure §3** — implements the `reversible: unknown` handling described above.
- **`/folder-lint` Check 6c** — clarified: missing `reversible:` on NEW entries is a Warning; on historical pre-schema entries the flag is expected to be missing and the entry is not re-flagged.
- **`README.md`** — twenty-skill and fourteen-reference-doc tables. Public "Feature notes" section documents hybrid archetype detection and signal-based Claude Code project detection. Global-state hard-exclusion added to the Privacy and safety list.
- **`ORCHESTRATOR.md`** — §2.6 Claude Code project continuity (mid-chain). §3.6 hard boundary: never touch global Claude state.

### Fixed

- **Collision-suffix vocabulary drift (`/folder-lint` v2.0 Check 4a Warning)** — this release does not retroactively rewrite pre-v2.0 paths. Pre-v2.0 folders may carry legacy suffix vocabulary (e.g. `(from Inbox)`, `(empty shell)`) that predates `references/Collision-Handling.md`'s canonical §2 table. All new suffix-generating actions from v2.0 forward use the canonical table; legacy paths are normalised naturally on next contact by `/folder-inbox` or `/folder-review`, never retroactively.
- **Reversibility-schema drift (`/folder-lint` v2.0 Check 6c Warning)** — same posture as above. Pre-v2.0 activity-log entries are not rewritten. New mutating passes emit the `reversible:` flag; `/folder-undo` treats pre-schema entries as `reversible: unknown`.

### Notes

- **Explicit non-scope for this release:** the plugin does not maintain its own copy of Claude Code session data. It does not hard-code path-encoding schemes or registry field names — those are runtime-inspected and verified before use. It does not offer batch remediation actions. Every option that would touch `~/.claude/` or `~/.claude.json` is per-finding, per-user-choice, and precondition-gated.

---

## v2.0.0 · 2026-09-17 — Public GitHub release

### Added

- Orchestrator architectural layer (`ORCHESTRATOR.md`) and dedicated conductor sub-agent (`agents/orchestrator-conductor.md`).
- Six new skills: `/organisation-setup`, `/folder-tag`, `/folder-changelog`, `/folder-blueprint`, `/folder-repo-check`, `/folder-handoff`.
- Seven new reference docs: `Undo-Rules.md`, `Migration-CSV-Schema.md`, `Collision-Handling.md`, `Enterprise-Domain-Archetypes.md`, `TAXONOMY-REFERENCE.md`, `Metadata-Tag-Vocabulary.md`, `Sensitivity-Defaults.md`.
- SUITE-CONVENTIONS §16 (upgrade-safety via `USER-CONFIGURED` markers).
- SUITE-CONVENTIONS §17 (orchestrator layer).
- Public `LICENSE` (MIT).
- Public `README.md`, `CONTRIBUTING.md`.
- Runbooks: `docs/runbooks/marker-rotation.md`, `docs/runbooks/user-configured-verification.md`.
- `/folder-lint` Checks 4a, 6b, 6c, 6e, 8.
- `/folder-status` archetype indicator field (hybrid classification supported).
- SUITE-CONVENTIONS §13 released-marker rotation threshold (10-marker warning).

### Changed

- Total skill count: 19.
- Total reference doc count: 13.
- SUITE-CONVENTIONS §0.1 tightened — every mutating pass writes a Report; supplementary/correction/revert passes have no exemption.
- SUITE-CONVENTIONS §2a re-homing exception narrowed to name-identical or trivial-variant match (from v1.4).
- Full generalisation pass — all personal defaults removed; brand names replaced with generic placeholders where used illustratively.

---

## v1.4.0 · 2026-09-17 — Skill rename and expansion

### Added

- `/folder-dedupe`, `/folder-signoff`, `/folder-review`, `/folder-lint`, `/folder-status`.
- §2a re-homing exception (broader wording; narrowed in v2.0).

### Changed

- Renamed `/skill-folder-*` slash commands to `/folder-*`.

---

## v1.3.0 · 2026-09-15 — Skill-Suite-Review fixes

### Fixed

- Full Skill-Suite-Review E1–E9 / G1–G9 fixes applied to the audit → plan → execute chain and to the standalone skills.
