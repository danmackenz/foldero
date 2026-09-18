# Orchestrator Layer — Foldero Plugin

**Status:** Architectural contract. Not a skill. Not a filesystem operator.
**Implemented by:** the conductor sub-agent at `agents/decurion.md`.

This document is the rulebook. The conductor sub-agent is the implementation that is bound by it. Do not merge them, and do not treat the conductor as "the orchestrator renamed." The separation between rule layer and acting agent is deliberate: the rule layer describes what orchestration is *allowed and required to do*; the conductor is what *does it*, strictly within these rules.

---

## 1. Purpose

The router (`foldero`) resolves a user request to one skill. But some requests genuinely span multiple skills — "clean up and dedupe this folder", "set me up and then organise my Downloads", "review the queue then run a lint pass". The router alone cannot hold multi-step intent across skill boundaries.

The orchestration layer exists to hold that intent, sequence skill invocations, arbitrate the run-lock across a sequence, and ensure every skill in the sequence reads the same current user configuration. It is coordination, not filesystem work.

Simple single-skill requests continue to route directly through the router with no orchestrator involvement. The orchestrator activates only when a request genuinely spans multiple skills or requires cross-run state awareness.

## 2. Responsibilities (what the conductor MUST do)

### 2.1 Multi-skill sequencing
When a user's request implies a chain the router cannot resolve into one skill call, the conductor:
- Holds the multi-step plan.
- Invokes each skill in turn.
- Passes forward the outputs each next skill needs (mode selection, prior report paths, mid-run decisions).
- Does not require the user to re-specify context between steps.

### 2.2 Run-lock arbitration across a sequence
Rather than each mutating skill independently checking `_LOGS/.run-lock` in isolation, the conductor:
- Acquires a sequence-level marker `_LOGS/.orchestrator-lock` for the duration of the sequence.
- Blocks concurrent single-skill invocations that would interleave mid-sequence.
- Releases the sequence-level marker at the end of the chain (successful or aborted).
- Individual skills keep their own §13 lock-check logic when invoked directly (not through the conductor) — this is additive, not a replacement.

### 2.3 Configuration propagation
After `/organisation-setup` runs (or re-runs) and produces/updates the user's personalised reference docs, the conductor is responsible for confirming every skill invoked afterward reads the current versions of:

- `Brand-Taxonomy-Reference.md` (user-configured)
- `TAXONOMY-REFERENCE.md`
- `File-Type-Heuristics.md` (user-appended patterns)
- `Numbering-Convention-Rules.md` (if overridden)
- `Enterprise-Domain-Archetypes.md` (user extension)
- `Sensitivity-Defaults.md`
- `Metadata-Tag-Vocabulary.md` (user extension)

This is a consistency guarantee, not a filesystem operation. If a stale cached assumption is detected, the conductor re-reads and passes fresh content to the next skill invocation.

### 2.4 Cross-skill state resolution
Example: if `/folder-dedupe` finds a group that overlaps with an unresolved `REVIEW-SORT` item from a *different* prior run, resolving that overlap sensibly is an orchestration-level judgement call. The conductor:
- Recognises the cross-skill state (dedupe finding + open REVIEW-SORT item).
- Surfaces both to the user in one presentation.
- Coordinates the resolution across the affected skills, rather than either skill deciding alone.

### 2.5 Mid-chain escalation
When a chain hits an ambiguous or gated situation mid-sequence (e.g. a Tier-3 item surfaces during an audit→plan→execute chain), the conductor:
- Pauses the chain.
- Surfaces the decision to the user.
- On user response, resumes only the remaining steps — it does not restart the whole chain.

### 2.6 Claude Code project continuity (mid-chain)
When an audit→plan→execute chain reaches a folder flagged `CLAUDE-CODE-PROJECT` by `/folder-audit` (per `references/Claude-Code-Continuity.md` §2 signals), the conductor pauses `/folder-execute` at Phase C-Claude, writes a checkpoint recording which flagged folder is pending, presents the four options from `Claude-Code-Continuity.md` §4 to the user, and resumes `/folder-execute` only after the user selects an option. The conductor does not choose the option, does not override `/folder-execute`'s precondition checks, and never touches `~/.claude/` or `~/.claude.json` itself — those boundaries belong to `/folder-execute` (mid-chain remediation) and `/folder-audit-fix-claude` (retroactive scan/remediation) alone. Standalone runs of `/folder-audit-fix-claude` do not require the conductor.

### 2.7 BRAIN.md reading rule
The Decurion and Praeco read only a managed folder's `BRAIN.md` INDEX section by default when starting a new request against that root — for a parent-level `BRAIN.md`, the child-rollup table is normally sufficient for routing; full dated history (the child's own `BRAIN.md`) is pulled in only when a skill specifically needs historical context (e.g. Arbiter reviewing a recurring miscategorization pattern flagged in a child's open-flags count). See `references/SUITE-CONVENTIONS.md` §18.

## 3. Hard boundaries (what the conductor MUST NOT do)

### 3.1 Never bypass a skill's own gating
The conductor sequences and arbitrates. It never overrides:
- Confidence thresholds (§2, §2a).
- Sensitivity tiers (§5).
- Atomic-unit rules (§4).
- Run-lock semantics (§13).

If a skill it invoked refuses to proceed because a rule blocks it, the conductor honours the refusal and either escalates to the user (§2.5) or aborts the chain.

### 3.2 Never perform filesystem operations directly
Every actual `mv`, `mkdir`, `mv -n`, verify-source-gone check goes through the relevant skill. The conductor holds plans and state — it does not touch the filesystem.

### 3.3 Never silently skip a skill's report-writing requirement
Every skill the conductor invokes still writes its own dated Report per `references/Report-Templates.md`, sequence or no sequence. If a skill in a chain would produce a supplementary/correction report, that report is still written. §9 has no exceptions.

### 3.4 Never be the single point of failure for simple requests
The router continues to handle single-skill requests directly, without conductor involvement. If the conductor is unavailable or fails, single-skill invocations still work.

### 3.5 Never count itself as a skill
The conductor is not among the 20 skills. It has no `/folder-*` slash command, no SKILL.md, no run-lock exemption category. It is a sub-agent artefact under `agents/`, invoked by the router when multi-skill sequencing is needed.

### 3.6 Never touch global Claude state
The conductor never reads, writes, backs up, or restores anything under `~/.claude/` or `~/.claude.json`. The mid-chain Claude-Code-continuity pause (§2.6) is a coordination-only responsibility — the actual filesystem work, backup, verification, and metadata update belong to `/folder-execute` (for a move happening now) or `/folder-audit-fix-claude` (for retroactive remediation). The conductor never bypasses either skill's own preconditions.

## 4. When the router hands off to the conductor

The router hands off to the conductor when:
- The user's request contains two or more skill triggers in one phrasing ("audit and dedupe this folder", "set up then organise").
- The request implies a state-aware decision requiring information from more than one skill ("what should I run next given the current state" → conductor sequences `/folder-status` → recommendation → skill).
- The user's phrasing is deliberately open-ended ("get this folder in order end-to-end").

The router hands off directly (no conductor) when:
- The request maps to exactly one skill trigger.
- The user explicitly names a single skill.
- The router's own routing table resolves the request unambiguously.

## 5. Sequence-level lock semantics

The conductor's `_LOGS/.orchestrator-lock` marker:
- Written at sequence start with content `{conductor-id, sequence-plan-summary, timestamp}`.
- Checked by every mutating skill on invocation: if the current skill is being invoked as part of the sequence identified by `conductor-id`, the skill proceeds without acquiring its own `.run-lock`; if the invocation is unrelated, the skill treats the presence of the marker as "another run in progress" and blocks or waits.
- Released at sequence end. If the sequence is aborted, released with an abort reason.
- 6h freshness rule (§13) still applies — a stale orchestrator lock is overwritten with a warning.

## 6. Escalation and pause/resume

On mid-chain escalation:
- The conductor writes a checkpoint file `_LOGS/.orchestrator-checkpoint-[timestamp].md` recording: which skills have completed, which are pending, what state the pause was triggered by, what user decision is awaited.
- User answers via the surface the router provided (chat, or via re-invoking `/foldero` with the resume phrasing).
- The conductor reads the checkpoint, applies the user's decision, and resumes from the next pending skill.
- Checkpoint files are cleaned up automatically on successful sequence completion; unresolved checkpoints > 24h old are surfaced by `/folder-lint` as a Warning.

## 7. Reporting

Every conductor-driven sequence writes an `Orchestrator-Sequence-Report-[DATE].md` to `_LOGS/` summarising:
- Sequence plan.
- Skills invoked and their reports.
- Mid-chain escalations and their resolutions.
- Cross-skill state resolutions.
- Sequence outcome (completed, aborted, paused-checkpoint-pending).

This is in addition to each individual skill's own dated Report — the sequence report cross-links them, it does not replace them.

## 8. Non-scope

The conductor does NOT:
- Watch the filesystem for changes.
- Run on a schedule.
- Maintain persistent state between sessions beyond the checkpoint files.
- Depend on any external network or MCP.
- Modify SUITE-CONVENTIONS or the reference docs.

## 9. Cross-references

- Implemented by: `agents/decurion.md`.
- Documented in: `README.md` (architecture line + Configuration safety section).
- Referenced by: `SUITE-CONVENTIONS.md` §17 (orchestrator architectural layer).
- Consumes: every skill's report format per `references/Report-Templates.md`; user configs per `/organisation-setup` outputs; `references/Claude-Code-Continuity.md` (four-option gate propagation).
- Interacts with: the router (`foldero`) for hand-off; every mutating skill for sequence-level lock coordination; `/folder-execute` and `/folder-audit-fix-claude` for Claude Code project continuity flows.
