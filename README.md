# Foldero — Cowork / Claude Code plugin

![version](https://img.shields.io/badge/version-2.1.3-blue) ![license](https://img.shields.io/badge/license-MIT-green) ![platform](https://img.shields.io/badge/platform-macOS%20tested-lightgrey) ![skills](https://img.shields.io/badge/skills-20-orange)

![Foldero](https://raw.githubusercontent.com/danmackenz/foldero/main/brand/foldero-wordmark.png)

**A general-purpose folder-organisation system for anyone with a messy folder tree** — a chaotic `~/Downloads`, a whole `Documents` root, a shared drive, an external backup disk. It's not built around any one profession, industry, or prior setup: it hardcodes no path, brand, or taxonomy from any specific installation, and adapts to whatever you run it on. A student, a freelancer, a small business, a large team's shared drive — if it's a folder tree that's gotten away from you, this plugin is for it.

**Public v2.1 release.** Twenty skills, fourteen reference docs, an orchestration layer, and a dedicated conductor sub-agent. Personal defaults are stripped from every shipped file; the plugin ships as an empty template that adapts to each installing user via `/organisation-setup`. This release adds a signal-based Claude Code project-continuity capability (detection at audit time, a four-option gate at execute time, and a dedicated retroactive scan/remediation skill).

## Contents

- [Installation](#installation)
- [Quickstart](#quickstart)
- [Plugin design principle — description length](#plugin-design-principle--description-length)
- [Configuration safety](#configuration-safety)
- [The twenty skills](#the-twenty-skills)
- [Guarantees (every skill)](#guarantees-every-skill)
- [Reference docs](#reference-docs-in-references)
- [Typical flows](#typical-flows)
- [Privacy and safety](#privacy-and-safety)
- [Feature notes](#feature-notes)
- [OS support disclaimer](#os-support-disclaimer)
- [Runbooks](#runbooks-in-docsrunbooks)
- [Version](#version)
- [License](#license)

## Installation

**Recommended: add the marketplace.** This repo ships its own `.claude-plugin/marketplace.json`, so Claude Desktop can install and auto-update it directly from GitHub:

1. Claude Desktop → Settings → Plugins → Add → Add Marketplace → Add from a repository.
2. Paste `https://github.com/danmackenz/foldero`.
3. Toggle "Sync automatically" on, then click "Sync".
4. Install **foldero** from the marketplace list.

**Alternative: manual / local install.** If you're not using Claude Desktop's marketplace flow:

1. Install the plugin into Claude Code / Cowork the normal way for your setup (local plugin directory, `--plugin-dir`, or however your environment loads Claude Code plugins).
2. That's it for installation — there's no separate build step or external dependency to configure. Every skill in this plugin reads and writes plain files inside the folder you point it at, plus its own `references/` directory.

## Quickstart

**Run `/organisation-setup` first, before anything else.** This is not optional busywork — every other skill in this plugin reads the configuration it produces, and skipping it means every skill falls back to generic defaults instead of your actual preferences.

1. **Run `/organisation-setup`** (or `/organisation-init` — same skill). It's a short interview covering your intended use, industry/niche, brands or categories, taxonomy preferences, and sensitivity defaults. It produces user-level configuration files that every other skill reads — nothing is hardcoded from a template author's own setup.
2. **Run `/foldero` on any folder you want organised.** The router figures out what you're asking for and either picks the right single skill or hands off to the orchestrator conductor for a multi-skill chain (e.g. "audit this and then clean it up" runs audit → plan → execute automatically).
3. **Anything sensitive stays gated.** Content the plugin can't confidently classify, or that you've told it is restricted, is never moved without your explicit per-item sign-off.

If you only remember one thing: **`/organisation-setup` before anything else.**

## Plugin design principle — description length

Skill descriptions in this plugin are kept concise (typically under 200 characters, never over 250) to minimise the plugin's footprint on any account's shared skill-listing budget. A few skills necessarily carry longer descriptions where routing clarity would suffer from trimming further — those exceptions are called out in the skill body's own trigger-phrase section rather than the frontmatter.

## Configuration safety

Every file `/organisation-setup` writes into `references/` carries an `<!-- USER-CONFIGURED — do not overwrite on plugin update -->` header marker. The plugin's own update process is expected to check for this marker before touching any file — a marked file is never silently replaced by a new shipped default.

**This is a convention the plugin declares, not a guarantee the plugin can force** — a Cowork/Claude Code plugin sync process may or may not honour the marker natively. The plugin's `/folder-lint` skill verifies that any diverged-from-template file carries the marker, and `docs/runbooks/user-configured-verification.md` documents the manual verification procedure. Anyone with real folder data should read that runbook before applying a plugin update.

## The twenty skills

### Router (1)
| Skill | Role |
|---|---|
| `/foldero` | Front-door router. Routes vague/open-ended requests, hands off to the orchestrator conductor for multi-skill chains, explains the suite. |

### Orchestration layer (not a skill)
| Component | Role |
|---|---|
| `ORCHESTRATOR.md` | Architectural contract for the orchestration layer. |
| `agents/orchestrator-conductor.md` | The sub-agent that implements the contract. Invoked by the router for multi-skill chains. Sequences skill invocations, arbitrates the sequence-level run-lock, propagates user config, pauses/resumes on mid-chain escalation (including the Claude Code project four-option gate at `/folder-execute` Phase C-Claude). Not counted among the 20 skills. Never touches `~/.claude/` or `~/.claude.json` itself. |

### Chain-linked trio (3)
| Skill | Role |
|---|---|
| `/folder-audit` | Step 1 — read-only audit & map. Inventories, pre-tags, flags sensitivity. |
| `/folder-plan` | Step 2 — designs the taxonomy, routing table, and tailored CLAUDE.md + INDEX.md. Applies cross-brand ambiguity resolution. |
| `/folder-execute` | Step 3 — scaffolds, writes docs, moves files with verified reversible `mv`, logs. |

### Standalone mutating (10)
| Skill | Role |
|---|---|
| `/organisation-setup` | Interview + user-configuration generation. First-time setup and reconfiguration. |
| `/folder-inbox` | Sorts new files in the folder's own `00. Inbox`. |
| `/folder-import` | Brings content in from an external folder/drive/attachment; verified copy-then-remove. |
| `/folder-deepen` | Builds the deep multi-tier decimal sub-structure (SOP-scale) under approval. Carries the §2a re-homing exception. |
| `/folder-undo` | Reverses the last logged run per `references/Undo-Rules.md`. Treats pre-schema entries as `reversible: unknown` and requires per-entry confirmation. |
| `/folder-dedupe` | Full-tree duplicate scanner. ≥90% groups routed WHOLE to `REVIEW-SORT/duplicates/`. Never merges. |
| `/folder-signoff` | Sole authority to clear the `Awaiting sign-off` queue for Tier 3 items. Per-item approval, never batch. |
| `/folder-review` | Interactive REVIEW-SORT / REVIEW-TRASH resolver. Routes confirmed junk to `CONFIRMED-TRASH` (still never `rm`'d). |
| `/folder-tag` | Reads and writes EXIF/IPTC keyword tags on image files. Never writes Tier 3 brand names to portable metadata. |
| `/folder-audit-fix-claude` | Retroactive Claude Code project-continuity scan (default, read-only) and per-finding remediation (opt-in, gated). The ONLY skill authorised to touch `~/.claude/` or `~/.claude.json`, and only under the four-option per-finding gate with runtime-verified preconditions. |

### Standalone read-only (6) — run-lock exempt
| Skill | Role |
|---|---|
| `/folder-lint` | Validator of suite output against SUITE-CONVENTIONS. |
| `/folder-status` | Multi-root health dashboard. |
| `/folder-changelog` | Human-readable narrative changelog of the folder's history. |
| `/folder-blueprint` | Formats the folder as a shareable SOP/blueprint. |
| `/folder-repo-check` | Repo hygiene checker for atomic-unit repos. Never inspects code content. |
| `/folder-handoff` | Packages current open state for handoff to another person/tool. |

## Guarantees (every skill)

- **Never deletes.** Junk → `REVIEW-TRASH`; user-confirmed junk → `CONFIRMED-TRASH`; the suite never `rm`'s.
- **Never opens sensitive contents.** Classification is by name / metadata / structure only.
- **≥90% confidence to file.** Below that → `REVIEW-SORT`. The §2a re-homing exception narrows to ≥85% when the destination sub-pillar name is identical or a trivial variant of the item's own name, exactly one such destination exists.
- **Atomic units move whole.** Repos, application packages, and markerless self-contained folders are never split.
- **Every move is verified.** Source gone + destination present.
- **Run-lock blocks concurrent runs.** Read-only skills (lint, status, changelog, blueprint, repo-check, handoff) are exempt.
- **Sequence-level lock** — the orchestrator conductor arbitrates across multi-skill chains.
- **Suite logs live in `_LOGS/`, not in CLAUDE.md.** Every mutating pass writes a dated Report — no exceptions, including supplementary/correction/revert passes.

The full shared rule-set is in `references/SUITE-CONVENTIONS.md` — the single source of truth every skill points to.

## Reference docs (in `references/`)

| Reference doc | Purpose |
|---|---|
| `SUITE-CONVENTIONS.md` | Canonical shared rule-set. |
| `Atomic-Unit-Signatures.md` | Full atomic-unit signature list expanding §4. |
| `Sensitivity-Classification-Guide.md` | Worked tier-classification examples expanding §5. |
| `File-Type-Heuristics.md` | Classification heuristics (plugin-portable). |
| `Report-Templates.md` | Standardised column structure for every dated report + supplementary-pass shape + Data-Integrity-Findings template. |
| `Numbering-Convention-Rules.md` | Plugin's built-in numbering fallback (zero-padded), decimal sub-numbering, Lifecycle Staging Sub-Scheme. |
| `Undo-Rules.md` | What makes an activity-log entry reversible; skip reasons; partial-undo behaviour. |
| `Migration-CSV-Schema.md` | Standard columns and `action` vocabulary for every migration CSV. |
| `Collision-Handling.md` | Per-context suffix conventions and REVIEW-SORT fallbacks. |
| `Enterprise-Domain-Archetypes.md` | Domain-signal → archetype → typical-pillars table. Seed content for `/organisation-setup`. |
| `TAXONOMY-REFERENCE.md` | Template for the user's own decided pillar skeleton. Populated by `/organisation-setup`. |
| `Metadata-Tag-Vocabulary.md` | Tag vocabulary for `/folder-tag`. Extended per-user. |
| `Sensitivity-Defaults.md` | Template for the user's per-brand/folder tier mappings. Populated by `/organisation-setup`. |
| `Claude-Code-Continuity.md` | Signal-based Claude Code project detection, the four-option pre-move/remediation model, the hard-exclusion boundary for `~/.claude/` and `~/.claude.json`, and the runtime-verification requirements for Option 1. |

## Typical flows

- **New user:** `/organisation-setup` → then anything.
- **New/messy folder:** `/foldero` → audit → plan → execute (chain, mode-inheriting).
- **Keep it tidy:** drop into `00. Inbox`, run `/folder-inbox`.
- **Bring in a drive:** `/folder-import` (Move/Copy, Improve/keep-names, migration CSV).
- **Go deep (SOP-scale):** `/folder-deepen` after a first pass exists.
- **Reverse a run:** `/folder-undo`.
- **Find duplicates:** `/folder-dedupe` (routes groups whole to `REVIEW-SORT/duplicates/`).
- **Clear restricted sign-off:** `/folder-signoff` (per-item approval).
- **Work the review backlog:** `/folder-review` (routes confirmed junk to `CONFIRMED-TRASH`).
- **Validate:** `/folder-lint`.
- **Check state across all folders:** `/folder-status`.
- **Tag images:** `/folder-tag`.
- **Get a narrative history:** `/folder-changelog`.
- **Export system SOP:** `/folder-blueprint`.
- **Check repos:** `/folder-repo-check`.
- **Hand off to someone else:** `/folder-handoff`.
- **Retroactively check for orphaned Claude Code sessions after past moves:** `/folder-audit-fix-claude` (scan-only by default).
- **Multi-skill chain** ("audit and dedupe", "set up then organise"): router hands off to the **orchestrator conductor** which sequences the chain.

## Privacy and safety

This plugin is designed to be safe with sensitive content, but the safety comes from strict rules — read them before trusting it with anything you care about:

- **Contents are never opened.** All classification is by name, extension, folder structure, and (for images, with your explicit configuration) EXIF metadata fields. The plugin never reads text out of your documents, images, or archives.
- **Nothing is deleted.** Even items confirmed as trash go to `CONFIRMED-TRASH`, not to `rm`. You delete manually from Finder/Terminal, or leave them.
- **Restricted content is gated.** Any content classified `SENS:RESTRICTED-DOMAIN` stays in place until you personally sign off per-item via `/folder-signoff`. No automation moves it.
- **Tag writes never leak sensitivity.** `/folder-tag` will never write a specific Tier 3 brand name into EXIF/IPTC keyword fields, since metadata travels with the file.
- **Global Claude state is hard-excluded.** `~/.claude/` and `~/.claude.json` are never scanned, classified, or written to by any skill except `/folder-audit-fix-claude`, and only under the four-option per-finding gate with an explicit user choice, verified preconditions, a reversible checkpoint, and post-action verification. Session transcript contents are never read.

## Feature notes

- **Hybrid archetype detection.** `/folder-status` and `/folder-audit` classify managed folders using signal-based heuristics from `Enterprise-Domain-Archetypes.md`. Where more than one archetype's signals fire strongly, the classification is reported as a hybrid — for instance, a folder that mixes creative-freelance work with software development might classify as "Creative Professional × Technical" (**illustrative example only** — the archetype list covers many domains, this is not the only combination or the typical one). This is intentional: many real folders don't fit one archetype cleanly, and the plugin doesn't force a single label where two apply. Downstream skills that consume the archetype (`/organisation-setup` for taxonomy seeding, `/folder-plan` for pillar suggestions) treat a hybrid classification as two signal sources rather than a single one.
- **Signal-based Claude Code project detection.** The plugin detects Claude Code project folders by their actual filesystem signals (`.claude/`, `CLAUDE.md`, or `.mcp.json`), never by folder-name heuristics. A folder named "Claude Code Scripts" without those signals is not classified as a Claude Code project. Full detection rules in `references/Claude-Code-Continuity.md`.

## OS support disclaimer

**Developed and tested on macOS. Windows/Linux path and permission behaviour is untested** — issues and PRs welcome. The plugin uses macOS/Unix path and `mv` semantics (case-sensitivity, `.DS_Store` cruft, `rm`-refusal on some mounts), which may not translate directly to other platforms.

## Possible future integrations (not implemented)

- **Anthropic document-skills plugin integration** — deferred pending an architecture decision. Conflicts with the current "no MCP, no external plugin deps" design principle. May revisit.

## Runbooks (in `docs/runbooks/`)

- `marker-rotation.md` — how to consolidate accumulated `.run-lock.released-*` markers once they exceed the threshold.
- `user-configured-verification.md` — how to verify user-configured reference docs survived a plugin update.

## Version

**v2.1.3 · 2026-09-18**

See `CHANGELOG.md` for the full version history.

## License

MIT. See `LICENSE`.
