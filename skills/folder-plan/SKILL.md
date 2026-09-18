---
name: folder-plan
description: Chain Step 2 — taxonomy architect. Reads the Audit-Report, designs routing table and CLAUDE.md/INDEX.md drafts. Applies the user's TAXONOMY-REFERENCE.md fallback. Trigger on "plan reorganisation", "design a taxonomy".
---

# Foldero — Plan & Optimise

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Taxonomy architect. Read-mostly — the only file it writes is the Reorganisation-Plan (into `_LOGS/`). Makes no filesystem changes.
**Chain position:** Step 2 of 3. Consumes `_LOGS/Audit-Report-*.md`; hands off to `/folder-execute`.
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## Dependencies & STOP conditions

- Requires the Audit-Report (in `_LOGS/`) plus any `CLAUDE.md`/`INDEX.md` at the root. STOP if the Audit-Report is missing. Never re-audit here.
- Inherit the mode from Step 1. Do not change it without user re-confirmation.

## Planning objectives

### 1. Taxonomy design
Apply the SUITE-CONVENTIONS §11 precedence chain in order:
1. **Live filesystem** — what already exists in this folder.
2. **The folder's own `CLAUDE.md`** — decisions already recorded here.
3. **User's `TAXONOMY-REFERENCE.md`** (if `/organisation-setup` has run) — the user's own pillar skeleton, applied as a fallback for new or unstructured folders. **Never silently overrides a folder's already-recorded `CLAUDE.md` decision.**
4. **Project `Numbering-Convention-Rules`** — if the managed folder belongs to a project.
5. **`references/Enterprise-Domain-Archetypes.md`** — archetype starting points (Creative Professional, Business, Technical, Family, Content Creator, Clinical, Generalised).
6. **`references/Numbering-Convention-Rules.md`** — the plugin's shipped fallback.

Starting points, not straitjackets. Add a Staging/Production/Development pillar (`90.`–`98.`) whenever content calls for it. Extend a partial convention and name every point of extension.

### 2. Numbering convention
Default `00.` Inbox/Review · `01.`–`89.` active · `90.`–`94.` Staging · `95.`–`97.` Production · `98.` Development · `99.` Archive, unless a higher-precedence source above overrides. First pass imposes no numbered decimal sub-scheme (`03.1`, `03.2`) — record those ideas in the deeper-pass appendix for `/folder-deepen`. Plain functional sub-folders are created freely.

### 3. Item routing
Every inventory item gets destination, confidence, one-line reason, per the audit tags:
- `CONFIDENT` → its pillar.
- `NEEDS-REVIEW` → `00. Inbox/REVIEW-SORT` (whole, never scattered).
- `LIKELY-JUNK` → `00. Inbox/REVIEW-TRASH`.
- `KEEP-IN-PLACE` → leave and log, unless the name maps to an obvious pillar being created (then file it there). Never `REVIEW-SORT`.
- **Sensitivity (§5) — tier OVERRIDES the type-based pillar:** `SENS:FILE-BY-NAME` → its restricted pillar; `SENS:QUARANTINE` → `REVIEW-SORT/secrets`; `SENS:RESTRICTED-DOMAIN` → gated, intended destination recorded in INDEX "Awaiting sign-off" for `/folder-signoff` to clear.

### 4. Cross-brand ambiguity resolution
When an item's name/structure signals match **two or more registered brands with comparable confidence**:
- Do NOT silently pick one.
- Route the WHOLE item to `REVIEW-SORT` with a manifest reason line naming both candidate brands and the specific overlapping signal.
- **Sensitivity precedence:** if one candidate brand is Tier 3 and the other isn't, treat the item as Tier 3 pending human resolution (safer default). Never the reverse. Record intended destination against the Tier 3 candidate; `/folder-signoff` clears.
- Referenced brand list comes from the user's `Brand-Taxonomy-Reference.md` (populated by `/organisation-setup`) — the plugin does not ship any brand list.

### 5. `CLAUDE.md` design
Draft the full intended `CLAUDE.md`, tailored to the archetype: a clinical folder gets record-handling rules; a dev folder gets version conventions; a creative brand gets asset-handling rules. Every `CLAUDE.md` states this folder's pillars, intake model, naming/numbering rules, three-tier sensitivity handling, restricted domains, atomic-unit guardrails, and a single one-line pointer to `_LOGS/activity-log.md`.

If this root already has a `CLAUDE.md` and a Claude-Code-Continuity signal (`Claude-Code-Continuity.md` §2) fires for it, do not replace that file. Fold the organization-taxonomy rules (pillars, intake model, naming/numbering, sensitivity handling, pointer line) into a clearly delimited `## Foldero organization rules` section appended to the existing file, leaving the dev-project's own content untouched above it.

Use `engineering:documentation` to format if available; otherwise write directly.

### 6. `INDEX.md` design
Draft the full intended `INDEX.md` with exactly the three sections from SUITE-CONVENTIONS §10: Taxonomy, Awaiting sign-off, Activity. Use `desktop-commander:knowledge-base` if available.

### 7. Optimise self-check
Folders with <3 items: consider merging. Folders with >12 direct children: consider splitting or flag for the deeper pass. Duplicate proposed names: flag for consolidation.

### 8. Open questions
List every below-90% item, every gated item needing sign-off, every judgement call. In Guided mode: drives the approval conversation. In Hands-Off mode: auto-resolve conservatively — below-90% & QUARANTINE → REVIEW-SORT; RESTRICTED-DOMAIN → stays in place with intended destination for `/folder-signoff`; generic empties → REVIEW-TRASH; meaningful empties → KEEP-IN-PLACE.

## Output

Write `Reorganisation-Plan-[FOLDERNAME]-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`: taxonomy rationale · full routing table (with tier + intended destination per gated item) · **cross-brand ambiguity log** · CLAUDE.md draft · INDEX.md draft · optimise findings · open questions · deeper-pass sub-numbering appendix (consumed later by `/folder-deepen`).

## Mode-dependent close

- **Hands-Off:** launch `/folder-execute`; auto-resolve open questions per §8.
- **Guided:** present the plan and routing table; for each open question present **options, not assumptions**; require explicit "approved, proceed to execution".
- **Manual:** produce the plan and ask — (a) hand off to `/folder-execute` to create the empty scaffolded tree (no files moved), or (b) output the plain-text tree only — then stop.

## References

- `references/Enterprise-Domain-Archetypes.md` — archetype starting points and domain-signal detection heuristics.
- `references/Sensitivity-Classification-Guide.md` — record intended destinations for Tier 3 items.
- `references/Sensitivity-Defaults.md` — user's per-brand tier mappings.
- `references/Report-Templates.md` — Reorganisation-Plan column structure.
- `references/Collision-Handling.md` — proposed suffix conventions for planned moves.
- `references/TAXONOMY-REFERENCE.md` — the user's own pillar skeleton (precedence §11 step 3).
- `SENS:RESTRICTED-DOMAIN` sign-off is actioned by `/folder-signoff`, not by this skill.
- **Every mutating pass writes a Report per SUITE-CONVENTIONS §9** (though this skill itself is read-mostly, its downstream `/folder-execute` is bound by this invariant).

## Cross-references

- Consumes: `_LOGS/Audit-Report-…md`. Produces: `_LOGS/Reorganisation-Plan-…md`, read by `/folder-execute`.
- Optionally uses (advisory): `engineering:documentation`, `desktop-commander:knowledge-base`.

## Tested against

- 2026-09-15/17 · Creative/dev + stress fixtures; live tested against a managed folder including the §2a re-homing exception's first-real-world application (6 candidates, 0 passing).
