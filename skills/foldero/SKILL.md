---
name: foldero
description: Front-door router for the Foldero suite. Routes vague or open-ended folder-organisation requests to the right skill, hands off to the orchestrator conductor for multi-skill chains, and explains the suite when asked.
---

# Foldero — Front Door & Router

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Route an organisation request to the right skill or the orchestrator conductor. Explain the suite. This skill decides and hands off; it performs no filesystem changes itself.
**Shared rules:** `references/SUITE-CONVENTIONS.md`.

## When to use

Any folder-organisation request that doesn't obviously name one skill — vague ("sort out my Downloads"), broad ("get me organised"), or a "what can you do here" question. If the user already named the operation, invoke that skill directly instead of routing.

## First-time user check

If the user has never run `/organisation-setup`, route them to it before any other mutating skill. Reference-doc user configs (`TAXONOMY-REFERENCE.md`, `Sensitivity-Defaults.md`, etc.) drive nearly everything else — without them, the plugin falls back to generic defaults that are less useful than the personalised version.

## Routing table

Establish two things first: (a) does the target folder already have `CLAUDE.md` + `INDEX.md`? (b) what does the user actually want?

| Situation / phrasing | Route to |
|---|---|
| First-time user; no `/organisation-setup` run yet | **`/organisation-setup`** (interview + user-config generation) |
| New, messy, never-organised folder; "organise / clean up / restructure / map this" | **`/folder-audit`** (starts the audit → plan → execute chain) |
| Folder already set up; "file these", "sort my inbox", "clear 00. Inbox" | **`/folder-inbox`** |
| External content coming in; "import", "migrate this drive in" | **`/folder-import`** |
| First pass done; "go deeper", "SOP-scale" | **`/folder-deepen`** |
| "undo", "reverse that", "put it back" | **`/folder-undo`** |
| "find duplicates", "dedupe", "consolidate copies" | **`/folder-dedupe`** |
| "sign off", "approve gated items", "clear sign-off queue" | **`/folder-signoff`** |
| "review the sort queue", "process REVIEW-SORT", "clear the review backlog" | **`/folder-review`** |
| "lint this folder", "validate suite output", "is the folder well-formed?" | **`/folder-lint`** |
| "status of my folders", "all my managed folders", "health check across folders" | **`/folder-status`** |
| "tag my photos", "add metadata to images", "label these by brand" | **`/folder-tag`** |
| "summarise what's happened", "give me a changelog", "history of this folder" | **`/folder-changelog`** |
| "document my folder structure", "make an SOP", "create a blueprint I can share" | **`/folder-blueprint`** |
| "check my repos are tidy", "find messy repo folders" | **`/folder-repo-check`** |
| "prepare a handoff", "brief someone else on this folder's state" | **`/folder-handoff`** |
| "fix my claude projects", "check for orphaned claude sessions", "reconnect claude code history after a move", "audit-fix-claude" | **`/folder-audit-fix-claude`** |
| Multi-skill intent ("audit and dedupe", "set up then organise", "end-to-end tidy-up") | **orchestrator conductor** (`agents/orchestrator-conductor.md`) |
| "what can you do here", "how does this work" | explain the suite (below) |

**Precedence & guards:**

- No `CLAUDE.md`/`INDEX.md` → the only routes that work on an unmanaged folder are `/folder-audit` (starts the trio), `/folder-status` (skips unmanaged folders with a note), and `/organisation-setup` (writes user config, not folder artifacts).
- Ambiguous scope (multiple folders, unclear root) → STOP and ask. Never guess.
- Two routes plausibly fit → ask one short clarifying question rather than assume.
- **§15 disambiguation:** "sort these files" — ask whether the user means *new arrivals* in `00. Inbox` (→ `/folder-inbox`) or the *already-flagged backlog* in REVIEW-SORT/REVIEW-TRASH (→ `/folder-review`).
- **Tier-3 content:** any restricted-domain sign-off request → `/folder-signoff` only.
- **Multi-skill intent:** hand off to the orchestrator conductor. Do not chain skills yourself.

## Orchestrator conductor hand-off

When a user request contains two or more skill triggers in one phrasing, implies a state-aware decision requiring information from more than one skill, or is deliberately open-ended ("get this folder in order end-to-end"), invoke the conductor sub-agent at `agents/orchestrator-conductor.md`. Pass the user's raw request plus any resolved scope.

The conductor is bound by `ORCHESTRATOR.md` and every SUITE-CONVENTIONS guarantee. It sequences skill invocations, arbitrates the sequence-level lock, propagates user config, and pauses on mid-chain escalation. It is not a skill and has no slash command.

For single-skill requests, hand off directly — do not involve the conductor.

## Mode hand-off (trio only)

When routing into the trio, capture the workflow mode up front if the user implies one ("just do it" → Hands-Off; "let me approve each step" → Guided; "just show me the structure" → Manual) and pass it so `/folder-audit` skips its mode prompt.

## Explaining the suite

Summarise in plain language:

- The **audit → plan → execute trio** takes control of a messy folder and builds a tailored structure with a `CLAUDE.md` rulebook and `INDEX.md` map.
- **`/folder-inbox`** files new arrivals from `00. Inbox`; **`/folder-import`** brings in outside content; **`/folder-deepen`** builds deep multi-tier structure; **`/folder-undo`** reverses the last run.
- **`/folder-dedupe`** finds duplicate groups without merging; **`/folder-signoff`** clears the restricted-domain sign-off queue one item at a time; **`/folder-review`** walks the REVIEW-SORT/REVIEW-TRASH backlogs.
- **`/folder-lint`** and **`/folder-status`** are read-only diagnostics.
- **`/folder-tag`** manages image-file metadata; **`/folder-changelog`** narrates history; **`/folder-blueprint`** exports the folder as a shareable SOP; **`/folder-repo-check`** checks repo hygiene; **`/folder-handoff`** packages current state; **`/folder-audit-fix-claude`** retroactively finds Claude Code project folders whose session history may have been orphaned by an earlier move and offers a per-finding four-option remediation gate.
- **`/organisation-setup`** is the first thing to run on a new install — it captures the user's own taxonomy, brands, and preferences.
- Nothing is ever deleted, sensitive contents are never opened, and every move is verified.

Then ask which fits.

## References

- `references/SUITE-CONVENTIONS.md` — the shared rule-set every route lands in.
- `references/Sensitivity-Classification-Guide.md` — §15 disambiguation, Tier-3 redirect logic.
- `references/Enterprise-Domain-Archetypes.md` — archetype signals used to disambiguate multi-plausible routes.
- `ORCHESTRATOR.md` (plugin root) — when to hand off to the conductor.

## Cross-references

- Routes to (directly): `/organisation-setup`, `/folder-audit`, `/folder-inbox`, `/folder-import`, `/folder-deepen`, `/folder-undo`, `/folder-dedupe`, `/folder-signoff`, `/folder-review`, `/folder-lint`, `/folder-status`, `/folder-tag`, `/folder-changelog`, `/folder-blueprint`, `/folder-repo-check`, `/folder-handoff`, `/folder-audit-fix-claude`.
- Routes to (chain-linked downstream of `/folder-audit`, not directly): `/folder-plan`, `/folder-execute` — invoked by the trio's own mode-dependent close, not by the router.
- Routes to (orchestration layer, not a skill): the conductor sub-agent for multi-skill requests.
- Performs no changes itself; all guarantees are enforced by the skill or conductor it hands off to.

## Tested against

- 2026-09-17 · v2.0 smoke test suite: single-skill routing, multi-skill hand-off to conductor, §15 disambiguation, first-time-user route to `/organisation-setup`.
