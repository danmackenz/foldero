---
name: folder-blueprint
description: Read-only. Formats a folder's CLAUDE.md, INDEX.md, and taxonomy into a shareable SOP/blueprint document. Trigger on "document my folder structure", "make an SOP", "create a blueprint I can share".
---

# Foldero — Blueprint

**Version:** v1.0 · Last modified 2026-09-17
**Role:** Standalone read-only skill that formats a folder's own `CLAUDE.md`, `INDEX.md`, and taxonomy into a clean, shareable SOP/blueprint document — for a user who wants to document their own organisational system (e.g. to hand to a collaborator, or to replicate the same taxonomy on a second machine/drive).
**Shared rules:** `references/SUITE-CONVENTIONS.md`. Exempt from the run-lock (§13) because read-only.

## Dependencies & STOP conditions

- Requires the managed folder to have `CLAUDE.md`, `INDEX.md`. STOP if either is missing.
- No run-lock acquired.
- Never modifies the managed folder — writes only a new formatted document.

## Procedure

1. **Read `CLAUDE.md`** — extract pillars, intake model, naming/numbering rules, sensitivity handling, atomic-unit list.
2. **Read `INDEX.md`** — extract the Taxonomy tree.
3. **Read `references/` overview** — if the folder is managed by this plugin, cite the reference-doc set as background.
4. **Compose the blueprint** — a shareable SOP-style document formatted for a human collaborator or a new-machine setup:

   - **Overview** — one paragraph: what this folder is for.
   - **Taxonomy tree** — from INDEX Taxonomy section, one line per pillar.
   - **Naming conventions** — from CLAUDE.md, in prose: how items are named, how new items get filed.
   - **Sensitivity handling** — from CLAUDE.md three-tier rules, in prose: what kinds of content are treated with extra care.
   - **Atomic units** — from CLAUDE.md: what "atomic" means for this folder and where they live.
   - **How to replicate this setup** — a short section pointing to `/organisation-setup` if the collaborator wants to reuse the same conventions on their own folder.

5. **Write the output document** — clean, publishable Markdown. No suite-artefact clutter (no `_LOGS/`, no run reports, no reversibility annotations). This is for a human reader who may or may not be using the plugin themselves.

6. **Optional — subtree overview.** Only if this folder's own `BRAIN.md` has a non-empty child-rollup table (SUITE-CONVENTIONS §18): add a **Subtree overview** section, one line per direct child (path, archetype/taxonomy version), as a timeless structural summary of the managed subtrees beneath this root — consistent with Blueprint's existing "documents the system" framing. Skip this section entirely when there's no rollup table to show; this never changes the default output for a leaf-shaped or unmanaged folder.

## Output

Write `Blueprint-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`.

## Distinction from `/folder-handoff`

- `/folder-blueprint` documents the **system**: how the folder is organised, what conventions apply, how to replicate it.
- `/folder-handoff` documents the **current open state and next actions**: what's in the queues, what needs doing.

Blueprint is timeless (or slowly-changing); Handoff is a snapshot.

## References

- `references/Report-Templates.md` — Blueprint format.
- `references/Numbering-Convention-Rules.md` — referenced when the blueprint cites numbering conventions.

## Cross-references

- Complements: `/folder-handoff` (packages open state), `/folder-changelog` (narrates history).
- Requires: `CLAUDE.md` + `INDEX.md`. Produces: `_LOGS/Blueprint-…md`.
- **Run-lock exempt** per §13.

## Tested against

_(fill in after first use: folder scope, blueprint length, outcome.)_
