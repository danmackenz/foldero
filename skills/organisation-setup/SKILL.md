---
name: organisation-setup
description: First-run configuration interview. Captures the user's taxonomy, brands, sensitivity defaults, tag vocabulary. Writes USER-CONFIGURED reference docs. Trigger on "set up foldero", "/organisation-init", "configure this".
---

# Foldero — Organisation Setup

**Version:** v1.0 · Last modified 2026-09-17
**Role:** Interview-style configuration skill, run on first use by a new user (or re-run any time to reconfigure). Produces the user-level versions of every reference doc that ships with generic defaults, so the rest of the suite operates against the installing user's actual context.
**Alias trigger:** `/organisation-init` — same skill.
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## Dependencies & STOP conditions

- Acquire the run-lock (§13); release at the end. This skill writes configuration files that other skills read.
- If a prior user config exists (files carrying the `<!-- USER-CONFIGURED — do not overwrite on plugin update -->` marker), show a diff and ask for confirmation before overwriting — never clobber a prior setup silently.
- **Every mutating pass writes a Report** per SUITE-CONVENTIONS §9.

## Interview flow

Ask in this order. Skip any question the user has already answered in prior turn or free-form input.

### 1. Intended use / role
Free-text plus a menu of the archetypes in `references/Enterprise-Domain-Archetypes.md` §1: Creative Professional · Business/Service Practice · Technical/Software/Dev · Family/Household · Content Creator · Clinical/Professional Records · Mixed/Generalised. User may pick more than one.

### 2. Niche/industry detection mode
- **Global** — a single industry applies to all managed folders.
- **Per-folder auto-detection** — `/folder-audit` infers domain per folder.
- **User-specified list** — the user names specific niches/brands to watch for.

Store this as a **mode flag**, not a one-time answer. It governs how `/folder-audit` behaves on every future folder.

### 3. Managed brands/entities
Name each brand/person/project container the user wants the taxonomy to recognise. Do not assume any brand exists by default. Each brand becomes:
- A row in `Brand-Taxonomy-Reference.md`.
- A potential tag value in `Metadata-Tag-Vocabulary.md`.
- A candidate for Tier 3 default assignment in `Sensitivity-Defaults.md`.

Recognise cross-brand ambiguity risk: if the user names brands with overlapping signals (similar names, shared vocabulary), flag it now for the cross-brand resolver in `/folder-plan` and `/folder-review`.

### 4. Preferred folder taxonomy starting point
Offer the shipped default archetype tables as a starting point. Let the user override pillar names, add/remove pillars, and set their own top-level category count preference. This answer populates `TAXONOMY-REFERENCE.md`.

Ask about numbering preference: zero-padded (`01.`) or non-zero-padded (`1.`). Ask about `1.`–`4.` reservation preferences (some users reserve them, others don't).

### 5. Deepening depth preference
Default: max two decimal levels per `/folder-deepen`. Confirm or override.

### 6. Sensitivity handling preferences
The three-tier model stays as-is (suite invariant). Ask which of the user's own brands/content types map to which tier by default:

- Any brands that default to Tier 3 (adult content, clinical records, safeguarding data)?
- Additional Tier 2 patterns beyond the shipped `.env` / `passwords*` / key-file patterns?
- Which pillars are the user's "restricted" destinations for Tier 1 named-legal / named-financial / named-PII?

Populate `Sensitivity-Defaults.md`.

### 7. Metadata/tagging preferences
If `/folder-tag` is installed and the user works with image files, ask what keyword/tag vocabulary they want beyond the shipped generic set. Add to `Metadata-Tag-Vocabulary.md` user extension.

## Research step

After capturing the interview answers, before finalising any config file:

**Perform a research step.** Look up general best practice and industry-standard folder/file management conventions relevant to the user's stated niche/industry (e.g. photography studio asset management, software repo hygiene, therapy/clinical records retention). Use `enterprise-search` if available for internal-context; use web-search sparingly for well-established industry conventions.

Refine the proposed taxonomy and heuristics with what research surfaces. **Present the refinements back to the user as suggestions**, not silent injections: "Industry convention for [niche] typically also separates [X] from [Y] — add this pillar?" The user accepts, rejects, or modifies each suggestion.

This research capability is available on every run where genuinely new context appears — not just first-time setup. That's what makes the knowledge "maintained" rather than a single snapshot.

## Outputs

Write/update the user-level copies of, each carrying the `<!-- USER-CONFIGURED — do not overwrite on plugin update -->` header marker per SUITE-CONVENTIONS §16:

- `Brand-Taxonomy-Reference.md` — brand/entity signal mapping.
- `TAXONOMY-REFERENCE.md` — user's decided top-level pillar structure.
- `File-Type-Heuristics.md` (appends user-specific patterns without deleting shipped defaults).
- `Numbering-Convention-Rules.md` (only if the user overrides the plugin default).
- `Enterprise-Domain-Archetypes.md` (records which archetype(s) apply to this user).
- `Sensitivity-Defaults.md` — user's per-brand/folder tier defaults.
- `Metadata-Tag-Vocabulary.md` (appends user-specific tag values).

**All outputs go through the same never-overwrite-silently posture:** if a user-level file already exists, show a diff and ask for confirmation before overwriting.

Write `Organisation-Setup-Report-[DATE].md` to a location the user picks (default: current working directory or `~/.foldero-config/`): interview answers · research suggestions applied/rejected · files written · setup timestamp.

## No filesystem impact on managed folders

`/organisation-setup` does NOT touch any managed folder's own `CLAUDE.md`, `INDEX.md`, or `_LOGS/`. It writes user-level config only. Existing managed folders keep their own recorded structure per SUITE-CONVENTIONS §11 precedence — the user's new `TAXONOMY-REFERENCE.md` is a fallback for future new folders, not a retroactive override.

`BRAIN.md` (leaf or parent-rollup) is likewise out of scope here — it's created per-target by `/folder-execute`'s first run against a given root or ancestor, not by this global setup pass (SUITE-CONVENTIONS §18).

## References

- `references/Enterprise-Domain-Archetypes.md` — seeds the archetype menu; the user's answers extend it.
- `references/TAXONOMY-REFERENCE.md` — template for the user's decided pillar structure.
- `references/Sensitivity-Classification-Guide.md` — three-tier model; user cannot change tier semantics.
- `references/Sensitivity-Defaults.md` — template for user's per-brand tier mappings.
- `references/Metadata-Tag-Vocabulary.md` — template for tag vocabulary.
- `references/Numbering-Convention-Rules.md` — numbering scheme choices.
- `references/Report-Templates.md` — Organisation-Setup-Report format.
- `docs/runbooks/user-configured-verification.md` — verification of the USER-CONFIGURED marker after plugin updates.

## Cross-references

- Produces: user-level configured versions of the seven reference docs above + Organisation-Setup-Report.
- Downstream consumers: **every skill in the suite** reads user configs where available. The orchestrator conductor (§17) is responsible for propagating current user-config versions to each skill in a multi-skill sequence.
- Interactive; run-lock: yes (writes config files other skills read).

## Tested against

_(fill in after first use: interview completeness, research suggestions accepted, files written, outcome.)_
