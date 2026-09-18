---
name: folder-audit-fix-claude
description: Retroactive Claude Code project-continuity check. Scan mode (default, read-only) finds Claude Code project folders whose session history may have been orphaned by an earlier move. Remediation mode is per-item, gated, and never batches.
---

# Foldero — Claude Code Continuity Fix (Audit + Remediate)

**Version:** v1.0 · Last modified 2026-09-17
**Role:** Detect Claude Code project folders inside a managed tree whose session history at `~/.claude/projects/<encoded-path>/` and registry entries in `~/.claude.json` may have been orphaned by an earlier folder move — including moves the Foldero suite itself performed before this continuity logic existed. Offer four remediation options per finding, one finding at a time. Never batch. Never mutate global Claude state without an explicit per-finding user choice and post-action verification.
**Shared rules:** `references/SUITE-CONVENTIONS.md`, `references/Claude-Code-Continuity.md`.

## Two modes

### Scan mode (default, read-only)

- No run-lock acquired.
- No writes to `~/.claude/`, `~/.claude.json`, or any file outside `_LOGS/` of the managed folder.
- Signals used: `.claude/`, `CLAUDE.md`, `.mcp.json` per `references/Claude-Code-Continuity.md` §2. Folder-name heuristics are not signals.
- **Reading `~/.claude/projects/` and `~/.claude.json` follows the standard consent flow** in `references/Claude-Code-Continuity.md` §8: per-finding, scoped, never blanket, always re-requested per session, always revocable. If the user has not granted per-finding consent for a specific finding, the skill reports that finding with reduced confidence rather than forcing access. Session transcript contents are never enumerated or exposed regardless of consent.
- Produces a `Claude-Continuity-Scan-Report-[DATE].md` in `_LOGS/` per `references/Report-Templates.md`.

### Remediation mode (opt-in, one finding at a time)

- **Requires an explicit user request** to enter remediation mode, referencing a specific scan report as the source of findings. Never auto-entered from scan mode.
- Run-lock acquired (§13). Released at the end.
- Applies the user's per-finding choice from the four options in `references/Claude-Code-Continuity.md` §4.
- **Never batches per-finding execution.** Each finding is presented, one option is chosen, action is executed, action is verified, dated Report entry is written — then the next finding is presented. Bulk triage (a decision-list) may happen up front (see Preflight §c), but execution walks each finding individually.
- **Preconditions verified ONCE per remediation-mode session in a Preflight step** before any finding is walked (see next section). Preflight results are cached on the session's checkpoint file and reused across every finding. This avoids repeating 20+ near-identical capability checks.
- Produces a `Claude-Continuity-Remediation-Report-[DATE].md` in `_LOGS/`, one entry per finding acted on.

## Preflight (runs once per remediation-mode session)

Before walking any findings, the skill performs three capability checks. Each check produces a boolean result that is cached in the session's checkpoint file (`_LOGS/.orchestrator-checkpoint-audit-fix-claude-[timestamp].md`) and referenced by every subsequent per-finding option offer in the same session. **These checks do not run 20 times for 20 findings — they run once, and the result is treated as the capability signal for the whole session.**

### Preflight (a) — Runtime storage-schema verification (gates Option 1)

Verify against the live Claude Code install that the plugin can:
- Locate the current `~/.claude/projects/` directory.
- Read the path-encoding scheme used to name directories under it (do not hard-code from cached knowledge — inspect an actual entry).
- Read `~/.claude.json` and identify the project-registry field structure.
- Perform a copy-based backup of a single project's directory and registry entry, then restore from that backup.

Pass criteria: all four sub-checks succeed against the running system. If any fails, Preflight (a) is `false` and **Option 1 is not offered as executable** for any finding in this session. The failure reason is recorded in the checkpoint and surfaced to the user.

### Preflight (b) — Symlink safety verification (gates Option 2)

Verify against the live filesystem, OS, and Claude Code version that:
- The filesystem where `~/.claude/projects/` lives supports symlinks (write a test symlink in a scratch subdirectory, then remove it).
- Claude Code resolves symlinked project directories correctly on the current version (documented positive behaviour or a small live test that does not touch any real project entry).
- The symlink target format the plugin would use is compatible with the OS (absolute vs relative, path length).

Pass criteria: all three sub-checks pass. If any fails, Preflight (b) is `false` and **Option 2 is not offered as executable** for any finding in this session — regardless of how many findings the user is triaging.

**This is one verification, done once, cached, and referenced for every Option 2 offer in the session.** It is not re-derived per finding.

### Preflight (c) — Bulk triage (optional, user-initiated)

Before walking findings one at a time, offer the user the option to review the full scan-report finding list with the skill's recommended option per finding, and pre-declare an intended choice per finding. The pre-declared choices become the *starting point* for the walk-through — the user can override any individual choice when its finding is presented — but this saves a decision at each of 20+ steps if the recommendations are agreeable.

Pre-declared choices are recorded in the checkpoint file. They do not bypass any precondition — if Preflight (a) failed and a finding was pre-declared as Option 1, the walk-through step for that finding surfaces the precondition failure and asks the user to pick a different option.

## Per-finding consent flow (the standard `~/.claude/` read-permission model)

Reading `~/.claude/projects/` and `~/.claude.json` — even in scan mode — follows the standard consent flow documented in `references/Claude-Code-Continuity.md` §8. Summary:

1. **Never blanket.** Consent is granted per finding, not per session. A user granting read for finding #7 does not grant read for finding #8.
2. **Always re-requested per session.** A consent granted in a prior session does not carry over. Every new invocation starts from zero granted-consent state.
3. **Always revocable.** The user can revoke consent for a specific finding mid-session; the skill discards any read state derived from that consent and reduces the finding's confidence accordingly.
4. **Scoped to specifically-named state.** Consent for finding #N grants read of the `~/.claude/projects/<encoded-path>/` directory names and the `~/.claude.json` entry corresponding to that finding's current or candidate prior path — never enumeration of the whole projects directory, never any session transcript contents.
5. **Independent of Preflight.** Preflight (a) verifies capability against the runtime; the per-finding consent flow governs access to specific state. Both must be true before a specific Option 1 execution proceeds.

Full mechanism, prompt shape, and edge cases in `references/Claude-Code-Continuity.md` §8.

## Dependencies & STOP conditions

- Requires the managed folder to have `CLAUDE.md`, `INDEX.md`, `_LOGS/`. STOP if any is missing.
- In remediation mode: STOP if the runtime cannot verify current Claude Code storage schema. Report clearly and offer Options 2, 3, or 4 instead.
- STOP and refuse if any option would delete a file (never-delete invariant, §1) — the plugin's own backup/checkpoint mechanism is copy-based only.
- **Never** silently touches `~/.claude/` or `~/.claude.json`. Every mutation of global state is the direct executable of a user's per-finding choice.

## Scan-mode procedure

1. **Walk the managed tree**, identifying every folder that carries a Claude Code project signal per `Claude-Code-Continuity.md` §2. Record: folder path, signal(s) present, signal confidence (which of the three fired and how strongly).
2. **Cross-reference to Claude Code state** where permitted and readable:
   - List `~/.claude/projects/` directory names (not contents). Record path encodings observed.
   - Read `~/.claude.json` project-registry entries (paths and identifiers only, never session transcripts).
   - Match project entries to the current folder set by comparing decoded paths. Note matches, mismatches, and entries without a corresponding current folder.
3. **Cross-reference to this plugin's own `_LOGS/activity-log.md`** — if a flagged folder appears as the DESTINATION of an earlier move recorded by any plugin skill, record the SOURCE path as a candidate prior-encoded location. This is how the retroactive orphan-detection works: the plugin's own log becomes evidence of what path was in use before the move.
4. **Classify each finding** into one of the following categories, with confidence:
   - **In sync** — flagged folder's current path matches a live Claude Code project entry. No action needed.
   - **Orphaned (high confidence)** — a plugin-log-recorded move brought the folder to its current path, and a corresponding `~/.claude/projects/` entry exists at the OLD encoded path but not the new one.
   - **Orphaned (medium confidence)** — the folder is flagged, an unmatched `~/.claude/projects/` entry exists, and its decoded path plausibly corresponds to a prior location, but the plugin's own log does not record the move (moved before plugin was installed, or moved outside the plugin).
   - **Ambiguous** — two or more plausible mappings exist, or the runtime could not read the necessary state to disambiguate.
   - **New / no history** — flagged folder has no matching Claude Code project entry, past or present. Nothing to reconnect. Informational only.
5. **Report** every finding with signal, current path, confidence category, evidence, uncertainty, and the four remediation options available (or, for a specific option, why it is not offered as executable in this run).

## Scan report format

`_LOGS/Claude-Continuity-Scan-Report-[DATE].md`, per `references/Report-Templates.md`:

- Summary — total findings by category.
- Per-finding block:
  - Folder path (current).
  - Signals present (which of `.claude/` / `CLAUDE.md` / `.mcp.json`; details).
  - Signal confidence.
  - Category (in-sync / orphaned-high / orphaned-medium / ambiguous / new).
  - Evidence — specific entries in `~/.claude/projects/`, `~/.claude.json`, and `_LOGS/activity-log.md` that the classification rests on.
  - Uncertainty — what is not known, what the runtime could not read.
  - Four options available (Option 1 / Option 2 / Option 3 / Option 4), with a note on which are offered as executable given the current runtime's verification results, and which are not.
- Concluding line: how to enter remediation mode for a specific finding.

## Remediation-mode procedure

### Session start
1. Run **Preflight (a)** and **Preflight (b)** once. Cache results in `_LOGS/.orchestrator-checkpoint-audit-fix-claude-[timestamp].md`. If both fail, the only executable options in this session are 3 and 4 — say so plainly.
2. Offer **Preflight (c)** bulk-triage: present the full finding list with the skill's recommended option per finding. User pre-declares choices or opts to decide live per finding. Pre-declared choices are recorded but do not bypass per-finding consent (§per-finding consent flow above) or per-option preconditions.

### Per finding, one at a time
1. **Fetch the finding** from the referenced scan report. STOP if the scan report is missing or older than the folder's most recent mutating pass — the finding may be stale; re-scan first.
2. **Present the finding and the four options** to the user. For each option, show whether it is offered as executable given the cached Preflight results (a for Option 1, b for Option 2) and note the pre-declared choice from Preflight (c) if one exists.
3. **Request per-finding consent** to read the `~/.claude/projects/<encoded-path>/` entries and `~/.claude.json` fields specific to this finding, per the standard consent flow above. Consent granted for this finding only, revocable, never carried over.
4. **Wait for the user's choice** — either confirm the pre-declared choice, or override with a new one. Do not proceed without an explicit answer.
5. **Execute the chosen option:**
   - **Option 1** (Claude-integrated migration): only if Preflight (a) passed AND per-finding consent granted. Create backup/checkpoint of `~/.claude/projects/<encoded-old-path>/` and the `~/.claude.json` entry (using the runtime-verified mechanism from Preflight (a)). Perform the metadata migration. Verify post-action state. If verification fails, roll back from the backup and record the outcome as `remediation-failed: <reason>`.
   - **Option 2** (Balanced-safe compatibility strategy): only if Preflight (b) passed. Consent for reading state is still per-finding — a symlink is being created that references specific state, so the user must consent to the plugin having seen that state. Create the compatibility artifact. Verify. If verification fails, undo the compatibility artifact and record `remediation-failed: <reason>`.
   - **Option 3** (Skip): record the finding as `skipped: user-choice, orphan-accepted`. No consent required; no state read.
   - **Option 4** (Other): capture the user's description verbatim. Consent scope depends on what the description asks for and is negotiated at that point. Execute only within the plugin's safety envelope. Verify. Record outcome.
6. **Write the dated report entry** in `Claude-Continuity-Remediation-Report-[DATE].md` with: finding reference, chosen option, executed actions, verification outcome, `reversible:` flag per `references/Undo-Rules.md` §2, and any residual state the user should know about.
7. **Prompt for the next finding** or exit remediation mode.

## Reversibility

Every remediation action writes a `reversible:` flag:

- **Option 1** — `reversible: conditional` (reverses via the backup created before the migration, subject to the same runtime-verification bar).
- **Option 2** — `reversible: yes` (removing the symlink or other compatibility artifact returns to the pre-action state).
- **Option 3** — `reversible: no` (nothing was done; there is nothing to reverse).
- **Option 4** — determined by the specific action; the user is told the flag value before execution.

## Trigger phrases

- "fix my claude projects"
- "check for orphaned claude sessions"
- "reconnect claude code history after a move"
- "audit-fix-claude"

## Cross-references

- `references/Claude-Code-Continuity.md` — the full mechanism, hard-exclusion boundary, and four-option model.
- `references/Atomic-Unit-Signatures.md` — a Claude Code project folder is atomic for the duration of the move; no internal reorganisation of `.claude/` during Option 1 or Option 2.
- `references/Undo-Rules.md` — `reversible:` flag per action.
- `references/Report-Templates.md` — Claude-Continuity-Scan-Report and Claude-Continuity-Remediation-Report shapes.
- `ORCHESTRATOR.md` §6 — a multi-skill chain (e.g. audit→plan→execute) that encounters a Claude Code project folder mid-sequence pauses via the orchestrator conductor; the conductor presents the four options via checkpoint and resumes after the user chooses.

## Cross-references (skill relationships)

- **Requires:** `CLAUDE.md` + `INDEX.md` + `_LOGS/`. Signals from `Claude-Code-Continuity.md` §2 on at least one folder to be interesting.
- **Produces:** `_LOGS/Claude-Continuity-Scan-Report-…md` (scan mode); `_LOGS/Claude-Continuity-Remediation-Report-…md` (remediation mode).
- **Complements:** `/folder-audit` (which propagates the initial detection flag forward), `/folder-execute` (which enforces the four-option gate at move time on new work).
- **Classification:** standalone skill. Read-only in scan mode (run-lock exempt). Mutating in remediation mode (run-lock required; writes may reach `~/.claude/` per user choice).

## Tested against

- 2026-09-17 · v1.0 scan-mode live smoke test against a managed folder containing 20+ real repositories under a Repositories pillar and multiple project folders carrying `.claude/`, `CLAUDE.md`, or `.mcp.json` signals. Verified signal-based detection did not false-positive on a folder named "Claude Code Scripts" that lacked the actual signals.
