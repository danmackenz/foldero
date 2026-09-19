# Project Archetype Library

Curated project archetypes for Artifex (`/folder-project-setup`) to match against during its interview phase. Each entry: purpose, typical folder tree and depth, recommended docs, naming/numbering conventions. Generic only — no brand-, client-, or person-specific examples; illustrative paths use bracketed placeholders like `[project-name]`.

Token budget: 120 words per archetype entry (per SUITE-CONVENTIONS token-budget convention, §16).

## Archetype: Claude Code Library

**Purpose:** a reusable Claude Code plugin, skill, or agent package meant for distribution or reuse across projects.

**Typical tree:**
```
[project-name]/
  .claude-plugin/
    plugin.json
    marketplace.json
  skills/
  agents/
  references/
  docs/
  CHANGELOG.md
  CONTRIBUTING.md
  LICENSE
  README.md
```

**Recommended docs:** `README.md` (install/usage), `CHANGELOG.md` (seeded with a `## [0.1.0] - [date]` Unreleased/Initial entry), `CLAUDE.md` (dev-purposed: build/test commands, plugin conventions), `AGENTS.md` (only if the project ships its own sub-agents), no `BLUEPRINT.md` until the project has shipped once (Architectus works from an existing managed structure, not a fresh scaffold).

**Naming/numbering:** kebab-case top-level dirs (`skills/`, `agents/`, `references/`), no numeric prefixes — this archetype follows software-ecosystem convention, not Foldero's own numbered-pillar convention.

## Archetype: SaaS Backend

**Purpose:** a hosted application or API service — source code, infrastructure config, and deployment tooling for a product with ongoing releases.

**Typical tree:**
```
[project-name]/
  src/
  tests/
  migrations/
  infra/
  docs/
  .env.example
  CHANGELOG.md
  README.md
```

**Recommended docs:** `README.md` (setup, run, deploy), `CHANGELOG.md` (release-tracked), `CLAUDE.md` (architecture notes, env vars, local-dev commands), `ARCHITECTURE.md` once the service has more than one deployable component; skip `BLUEPRINT.md` pre-launch.

**Naming/numbering:** kebab-case dirs, no numeric prefixes — follows language/framework ecosystem convention (`src/`, `tests/`, `migrations/`). Environment folders (`infra/staging`, `infra/prod`) named literally, not numbered.

## Archetype: Client Engagement

**Purpose:** a single client's project workspace — deliverables, communications, and contracts for one paid engagement.

**Typical tree:**
```
[client-name]/
  00. Inbox/
  1. Contracts & Agreements/
  2. Briefs & Requirements/
  3. Deliverables/
  4. Communications/
  99. Archive/
```

**Recommended docs:** none required by default — a lightweight `README.md` only if the engagement has multiple contributors who need a status summary; no `CHANGELOG.md` (deliverable versions live in `3. Deliverables/`, not a code-style log); no `BLUEPRINT.md` (too small to need one).

**Naming/numbering:** numbered pillars (`1.`–`N.`, `99.` archive, `00.` inbox) per Foldero's Numbering-Convention-Rules; lives under the parent brand's `Clients/` lifecycle staging (Active/Delivered/Archive) rather than restating lifecycle here.

## Archetype: Photography Studio

**Purpose:** a shoot or ongoing photography practice — raw capture through edited delivery, plus the licensing/release paperwork that accompanies image work.

**Typical tree:**
```
[project-name]/
  00. Inbox/
  1. Raw Captures/
  2. Selects/
  3. Edits/
  4. Deliverables/
  5. Releases & Licensing/
  99. Archive/
```

**Recommended docs:** none required by default; a `README.md` only for multi-shoot or multi-photographer projects noting export presets or delivery specs; model releases and licensing files are `SENS:FILE-BY-NAME` — file by filename into `5. Releases & Licensing/`, not summarised.

**Naming/numbering:** numbered pillars matching the RAW → edited → deliverable pipeline; raw capture folders may sub-number by shoot date (`1.1`, `1.2`) once volume warrants it — deferred to a later deepening pass, not scaffolded upfront.

## Archetype: YouTube Content Pipeline

**Purpose:** recurring video content production — one workspace per channel or series, spanning ideation through publish and analytics review.

**Typical tree:**
```
[project-name]/
  00. Inbox/
  1. Scripts & Ideas/
  2. Footage/
  3. Edits/
  4. Thumbnails & Assets/
  5. Published/
  99. Archive/
```

**Recommended docs:** none required by default; an optional `README.md` for a content calendar or recurring publish cadence if the channel has multiple contributors; no `CHANGELOG.md` — published episodes are dated files in `5. Published/`, not log entries.

**Naming/numbering:** numbered pillars following the production pipeline order; per-episode sub-folders inside `2. Footage/` and `3. Edits/` use `descriptor-version` naming (date-prefixed), not further top-level numbering.

## Archetype: Therapy Practice Admin

**Purpose:** administrative workspace for a clinical or therapy practice — business operations alongside client-facing clinical material.

**Typical tree:**
```
[project-name]/
  00. Inbox/
  1. Business Administration/
  2. Client Records/
  3. Clinical Practice/
  4. Marketing/
  99. Archive/
```

**Recommended docs:** `README.md` only if multiple practitioners share the workspace; no `CHANGELOG.md`; no `BLUEPRINT.md` until an established structure exists to document.

**Naming/numbering:** numbered pillars per standard convention. `2. Client Records/` defaults to Sensitivity Tier 3 (`SENS:RESTRICTED-DOMAIN` per `Sensitivity-Classification-Guide.md`) — gated, sign-off-only handling for any item routed there; this doc does not define new sensitivity mechanics beyond that existing default.

## Archetype: Family Life Admin

**Purpose:** personal/household administration workspace — shared or individual, covering the ordinary paperwork and records of running a household.

**Typical tree:**
```
[project-name]/
  00. Inbox/
  1. Finance/
  2. Health/
  3. Home & Property/
  4. Recreation/
  99. Archive/
```

**Recommended docs:** none required by default; skip `README.md`, `CHANGELOG.md`, and `BLUEPRINT.md` unless the household explicitly wants a shared reference — this archetype is typically too small and informal to need doc scaffolding.

**Naming/numbering:** numbered pillars per standard convention; person-specific sub-folders (where a household has multiple members) are named literally under the relevant pillar rather than numbered separately.
