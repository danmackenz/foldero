---
name: folder-project-setup
description: Interviews the user, matches a project archetype, researches industry convention, then scaffolds a brand-new project folder from nothing — the only skill that builds from an empty target rather than reorganising an existing one. Trigger on "create a new project folder", "set up a Claude Code project for me", "scaffold a Cowork project", "make a project skeleton for [domain]", "project-init", "project-setup".
---

# Foldero — Project Setup

**Version:** v1.0 · Last modified 2026-09-19
**Role:** Artifex — "master craftsman/architect of a complete original work." Interviews the user, matches answers against a curated archetype library, refines with light industry research, then scaffolds a brand-new project folder. Distinct from every other skill in this suite: they all reorganise a folder that already has content; this is the only one that builds from nothing. Distinct from Fundator (`/organisation-setup`, founds the plugin's own system-wide config) and Structor (`/folder-deepen`, deepens what already exists).
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## Dependencies & STOP conditions

- **No disk writes before the user explicitly confirms the matched base template (Phase 2).** This is a hard STOP, not a soft suggestion — interview and template-match are read-only.
- Acquire the run-lock (§13) before Phase 4 (scaffold build); release at the end. Exclusive with any other mutating skill on the same target path.
- **Never-delete:** if the target path already has any content, show a diff of what's there and get explicit confirmation before touching it — never silently overwrite or merge without asking.
- **Every mutating pass writes a dated Report** per SUITE-CONVENTIONS §9 — no exceptions.

## Phase 1 — Interview

Ask, in order, skipping anything already answered: project type (coding / client engagement / creative / personal-admin), domain or niche, primary tools (Claude Code / Cowork / mixed), sensitivity tier (1–3, per `references/Sensitivity-Classification-Guide.md`), expected lifetime (short experiment vs. long-lived), collaboration level (solo vs. team). These answers drive the archetype match and tree-depth rules in Phase 2.

## Phase 2 — Template match (STOP before any write)

Match the interview answers against `references/Project-Archetype-Library.md`. Propose the best-fit archetype — or an explicit composite if none fits cleanly — and show the proposed folder tree and recommended docs. **Do not write anything to disk until the user explicitly confirms the base template.**

## Phase 3 — Research refinement

Look up industry/niche convention against `references/Industry-Taxonomy-Index.md` plus live web sources for the stated niche. Present refinements as explicit suggestions the user accepts, rejects, or modifies — e.g. "Industry convention for [niche] typically separates X from Y — add this pillar?" — never applied silently. This step is a light pass, not exhaustive research; if `Industry-Taxonomy-Index.md`'s entry for the niche is a "link TBD" pointer rather than a live URL, do the web lookup directly rather than stalling on it.

## Phase 4 — Scaffold build (run-lock, never-delete)

Under the run-lock: create the project root under the correct pillar per `references/TAXONOMY-REFERENCE.md`; create the confirmed tree; fill docs (`CLAUDE.md`, `AGENTS.md`, `CHANGELOG.md`, `INDEX.md`, `README.md`, `BLUEPRINT.md` stub) from `references/Project-Scaffold-Templates.md`, substituting only user-provided values — never Dan-specific or otherwise pre-filled content.

Seed `_LOGS/` the same way `/folder-execute`'s Phase A does: `activity-log.md` + `import-log.md` stubs, the three-section `INDEX.md` shape (§10), the `.run-lock` file format (§13) — same conventions, reused via these templates, not a runtime call to `/folder-execute` (that skill is hard-gated on a Reorganisation-Plan this skill doesn't produce, and shouldn't fake one to borrow its logic).

Create an empty leaf `BRAIN.md` (empty INDEX, no dated entries — matches any other first-run managed subtree per §18). **Scope limit (v2.2.0):** this skill does not write the `_LOGS/.pending-brain-entry` staging file the BRAIN.md-append hook consumes — only `/folder-execute` does that in this release (documented limitation, §18). A scaffolded project's BRAIN.md starts empty and stays empty until a later reorganisation pass touches it via the trio.

Log every write with `reversible:` metadata to `Project-Scaffold-Report-[DATE].md` in `_LOGS/`, per §9.

## Phase 5 — Blueprint and handoff

Call `/folder-blueprint` (Architectus) and `/folder-handoff` (Nuntius) where available to produce a human-readable SOP and handoff doc for the newly scaffolded project.

## Sensitivity

Tier-3 items never appear in shareable metadata (report summaries, blueprint/handoff docs) — defer to `references/Sensitivity-Classification-Guide.md` and `references/Sensitivity-Defaults.md`. If the interview reveals Tier-3 content (e.g. clinical records), flag it in `CLAUDE.md`'s Rules section but never propose retention/compliance specifics — that's the user's own regulatory call, not this skill's.

## Output

Write `Project-Scaffold-Report-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`. Release the run-lock.

## References

- `references/Project-Archetype-Library.md` — the archetype match set (Phase 2).
- `references/Industry-Taxonomy-Index.md` — research pointers per niche (Phase 3).
- `references/Project-Scaffold-Templates.md` — parametrised doc templates (Phase 4).
- `references/TAXONOMY-REFERENCE.md` — where the new project root lands.
- `references/Sensitivity-Classification-Guide.md`, `references/Sensitivity-Defaults.md` — Tier-3 handling.
- `references/SUITE-CONVENTIONS.md` §9 (reports), §10 (INDEX.md shape), §13 (run-lock), §18 (BRAIN.md + the folder-execute-only staging-file limitation).

## Cross-references

- Consumes: `Project-Archetype-Library.md`, `Industry-Taxonomy-Index.md`, `Project-Scaffold-Templates.md`, `TAXONOMY-REFERENCE.md`. Produces: a fully scaffolded project root; `_LOGS/Project-Scaffold-Report-…md`.
- After a run: `/folder-blueprint` and `/folder-handoff` (Phase 5); later, any standalone mutating skill or the trio can operate on the new project like any other managed folder.

## Tested against

_(fill in after first use: archetype matched, research suggestions accepted, files written, outcome.)_
