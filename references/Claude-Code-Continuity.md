# Claude Code Continuity (Foldero Plugin — references/)

**Version:** v1.0 · Last modified 2026-09-17
**Consumed by:** `/folder-audit` (detection), `/folder-execute` (pre-move decision gate), `/folder-audit-fix-claude` (retroactive scan and remediation), `ORCHESTRATOR.md` (multi-skill sequences that hit a flagged folder mid-chain).

This document establishes when a folder under a managed root qualifies as a Claude Code project folder, what happens to Claude Code's session and project state when such a folder is moved or renamed, and the strictly bounded remediation options the plugin offers.

---

## 1. Global-state boundary — hard exclusion

**Only** the following two paths are hard-excluded from all scanning, classification, mutation, and reference by every skill in this plugin:

- The literal user-level `~/.claude/` root directory.
- The literal `~/.claude.json` file.

These are Claude Code's own global application state. No skill scans them proactively. No skill writes to them without an explicit, per-action user confirmation at the moment of action, plus a dated Report, plus a `reversible:` flag, plus post-action verification.

The hard exclusion is not a blanket permit to touch them under any other conditions. Specifically:

- **`/folder-audit`, `/folder-plan`, `/folder-inbox`, `/folder-review`, `/folder-signoff`, `/folder-import`, `/folder-deepen`, `/folder-dedupe`, `/folder-tag`, `/folder-blueprint`, `/folder-status`, `/folder-lint`, `/folder-changelog`, `/folder-handoff`, `/folder-repo-check`, `/folder-undo`, `/organisation-setup`, `/folder-execute`** — none of these skills reach into `~/.claude/` or `~/.claude.json` for any purpose.
- **`/folder-audit-fix-claude` scan mode** — read-only. May read `~/.claude/projects/` directory names (not their contents) and `~/.claude.json` project-registry entries **only when** the current runtime permits and the user has not declined. If either is unreadable, the skill reports the finding with reduced confidence rather than forcing access. Never enumerates or exposes session transcript contents.
- **`/folder-audit-fix-claude` remediation mode** — the ONLY code path in this plugin that may mutate `~/.claude/` or `~/.claude.json`. Every such mutation is gated on: an explicit per-finding user choice from the four options in §4, a reversible checkpoint or backup, a dated Report, and post-action verification. If any of those cannot be satisfied, the mutation is refused and the finding is left for manual resolution.

## 2. What counts as a Claude Code project folder — signal-based detection only

A folder inside a managed `Documents` tree qualifies as a Claude Code project folder if, and only if, one or more of these actual filesystem signals is present at the folder's root:

- A `.claude/` directory containing any of: `settings.json`, `settings.local.json`, `.mcp.json`, `agents/`, `skills/`, `commands/`.
- A `CLAUDE.md` file.
- A `.mcp.json` file.

**Folder-name heuristics are not signals.** A folder named "Claude Code Scripts", "Claude Projects", "Claude Notes", "Claude Setup", or any similar string does NOT qualify on the strength of its name alone. Detection reads the filesystem contents, not the label.

**Rationale:** the plugin's `/folder-repo-check` v1.0 smoke test surfaced a folder called "Claude Code Scripts/Claude Code.sh/" that is in fact an unrelated `.xcodeproj` plus a shell script, carrying no Claude Code project signals. Name-matching would have false-positived it and put Dan's own state at risk of an unnecessary migration.

## 3. Why moving a Claude Code project folder is not safe by default

Claude Code stores session history and project metadata keyed to the absolute filesystem path of the project folder. The concrete storage locations and the exact encoding of paths into filenames or registry keys are Claude Code implementation details that this plugin does not assume, does not hard-code, and does not verify from cached knowledge — the plugin's own runtime must verify current representations before acting.

What the plugin does treat as established behaviour:

- Moving or renaming a Claude Code project folder does not error inside Claude Code — the move succeeds at the filesystem level.
- After a move, Claude Code may present the project as new at its moved location. The prior session history at the old path is not automatically migrated.
- Silent orphaning of session history is a documented failure mode.
- At least one documented failure mode has seen a stale-path session resume overwrite history with a blank session state.

The plugin's job is to make the risk visible before the move, offer the user a choice, and never rewrite Claude Code's internal state without explicit per-action confirmation.

## 4. The four remediation options

Whenever a flagged folder is about to be moved or renamed, or whenever `/folder-audit-fix-claude` surfaces an orphaned-session finding, the user is presented with exactly four options. No option is applied silently. No option is batched. No option is inferred from context.

### Option 1 — Recommended: Claude-integrated migration (requires explicit confirmation and runtime verification)

Perform the folder move, then update the corresponding Claude Code session/project metadata to reference the new path.

**Preconditions before this option is offered as executable:**

- The running environment has verified the current schema and layout of `~/.claude/projects/<encoded-path>/` and `~/.claude.json`'s project registry against the live Claude Code install, not against cached assumptions.
- A reversible checkpoint or backup of the affected `~/.claude/projects/<encoded-old-path>/` directory and the affected `~/.claude.json` entry has been created and verified.
- Post-action verification steps are defined and executable.

If any of the preconditions cannot be met, this option is **not offered as executable** in the current run. The user is told plainly why, and Option 2, 3, or 4 remain available.

### Option 2 — Balanced-safe: reversible compatibility strategy

Use a documented compatibility mechanism that does not rewrite Claude Code's internal state — for example, a symbolic link from the old path to the new location, only where the file system, Claude Code version, and platform have been verified to handle it correctly. The plugin does not assume symlink behaviour preserves Claude history or registry state; verification of that behaviour is part of the option, not a promise made in advance of it.

### Option 3 — Skip continuity remediation

Perform the folder move only. Do not touch Claude Code state. Report clearly that the old session history is orphaned and the project may appear as new at its moved location inside Claude Code.

Used when the user accepts the risk, or when the project's session history is not valuable enough to warrant continuity work, or when Options 1 and 2 both fail their preconditions and the user chooses to proceed anyway.

### Option 4 — Other

User-specified handling. The user describes what they want done; the plugin records the description in the dated Report and executes it only within its usual safety envelope (never deletes, never touches sensitivity Tier 3, never rewrites global state without confirmation).

## 5. Uncertainty and confidence

Every finding surfaced by `/folder-audit-fix-claude` in scan mode carries an explicit confidence and uncertainty statement:

- **Signal confidence** — which of the three §2 signals fired, and how strongly (e.g. a `.claude/` folder with populated `settings.local.json` is a stronger signal than a bare `CLAUDE.md` that could equally be a coding-style instruction for a non-Claude-Code tool).
- **Path-continuity confidence** — whether an old-path mapping is available (from this plugin's own `_LOGS/activity-log.md`, if the plugin was involved in the move) and whether the corresponding Claude Code project state is currently readable.
- **Ambiguity** — if the mapping is uncertain (e.g. two candidate old paths, or a Claude Code project entry that could belong to a different current folder), the finding is marked ambiguous and the report says so plainly. Remediation of ambiguous findings is not offered until the user disambiguates.

Never present a finding as "definitely orphaned, safe to migrate" when the evidence is partial. Say what you know, say what you don't, and let the user decide.

## 6. What this plugin does not do

- Does not maintain its own copy of Claude Code's session data.
- Does not attempt to reconstruct session history from other sources.
- Does not hard-code path encoding, filename schemes, or registry field names — those are inspected at runtime and verified before use.
- Does not run remediation across multiple findings without per-item confirmation.
- Does not offer "restore all sessions" or "migrate everything" batch actions.

## 8. Standard consent flow for reading `~/.claude/` state

Reading Claude Code global state — even to classify a finding without mutating anything — requires the user's explicit consent every time. This section defines the consent mechanism as a first-class part of the plugin, not a per-installation exception. Every skill that reads or writes `~/.claude/projects/` or `~/.claude.json` (currently: `/folder-audit-fix-claude`, and `/folder-execute` at Phase C-Claude) follows this flow.

### 8.1 Per-finding scope

Consent is granted per finding, not per session, plugin, or user.

- A user granting read for finding #7 does NOT grant read for finding #8.
- A user granting read for finding #7's *current path* does NOT grant read for finding #7's *candidate prior path* — the plugin requests both explicitly if it needs both.
- A user granting read does NOT grant write. Read consent gates classification and Option 2 preparation; write consent (Option 1's metadata migration) is a separate ask.

### 8.2 Never blanket

The plugin never offers "grant read for all findings", "grant read for all future sessions", or "always allow" checkboxes. Batch consent defeats the point — the user is being asked to authorise access to specifically-named state.

### 8.3 Always re-requested per session

Consent granted in a prior session does NOT carry over to a new one. Every new remediation-mode invocation starts from zero granted-consent state. This is intentional — the state Claude Code holds may have changed between sessions, and the user's judgement about whether reading a specific entry is appropriate may have changed too.

### 8.4 Always revocable

The user can revoke consent for a specific finding mid-session by any means (naming the finding, using a per-finding revoke prompt, or exiting remediation mode). When revoked:

- The plugin discards any state derived from that finding's read.
- The finding's confidence classification is reduced accordingly (usually back to "ambiguous, cross-reference suppressed").
- If Option 1 or Option 2 was mid-execution against that finding, the plugin rolls back what it can (per the option's own reversibility flag) and records the outcome as `remediation-aborted: consent-revoked`.

### 8.5 Scoped to specifically-named state

Consent for finding #N grants read of:

- The `~/.claude/projects/<encoded-current-path>/` directory names (not contents) at the finding's current path.
- The `~/.claude/projects/<encoded-candidate-prior-path>/` directory names (not contents) at any candidate prior path the plugin has evidence for.
- The `~/.claude.json` project-registry entries corresponding to those paths.

Consent for finding #N never grants:

- Enumeration of the whole `~/.claude/projects/` directory.
- Read of any session transcript file inside a project directory.
- Read of any `~/.claude/` file not in the two categories above.

### 8.6 Prompt shape

Every consent prompt names:

- The specific finding (by scan-report row number and current path).
- The specific state to be read (paths and fields).
- What the plugin will do with the read (classify the finding, prepare a specific option).
- The user's choices: **Grant for this finding only** / **Skip this finding (fall back to Option 3)** / **Cancel remediation mode**.

The prompt never says "grant to continue" — Skip is always a first-class choice, and Skip does not end remediation mode, it moves to the next finding.

### 8.7 Independent of Preflight

Preflight §Preflight (a) and §Preflight (b) verify the plugin's *capability* against the current runtime. The consent flow governs *access to specific state*. Both must be true before a specific Option 1 or Option 2 execution proceeds:

- Preflight (a) passed AND per-finding read consent granted → Option 1 executable.
- Preflight (b) passed AND per-finding read consent granted → Option 2 executable.
- Preflight passed AND consent declined → the finding falls back to Option 3 (skip) or Option 4 (other).

### 8.8 Not specific to any user

This consent model is a plugin-level design, not a per-installation exception. Any user running `/folder-audit-fix-claude` in remediation mode hits the same scoped, per-finding, revocable, never-blanket flow. There is no "trusted user" mode. There is no configuration flag to weaken it. Making consent explicit and per-finding is how the plugin makes the `~/.claude/` hard-exclusion §1 boundary compatible with genuine remediation work.

## 9. Cross-references

- `SUITE-CONVENTIONS.md` §1 (never-delete), §9 (Reports required), §13 (run-lock in remediation mode), §17 (orchestrator layer).
- `Undo-Rules.md` §2 (`reversible:` flag on every mutating action, including Options 1 and 2 above), §5a (`reversible: unknown` handling).
- `Atomic-Unit-Signatures.md` — a Claude Code project folder is treated as an atomic unit for the duration of the move; internal reorganisation of `.claude/` contents during a move is forbidden.
- `Sensitivity-Classification-Guide.md` — Claude Code project folders inherit the tier of their containing pillar; `.claude/settings.local.json` is not treated as Tier 2 by default because it does not match the shipped `.env`/`passwords*` patterns, but a user-configured Sensitivity-Defaults.md may elevate it.
