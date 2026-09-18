---
name: folder-repo-check
description: Read-only repo hygiene checker. Flags missing .gitignore, misplaced repos, empty worktree containers, suite artifacts inside repos. Never inspects code content. Trigger on "check my repos", "find messy repo folders".
---

# Foldero — Repo Check

**Version:** v1.0 · Last modified 2026-09-17
**Role:** For any folder already identified as a repository atomic unit (per `references/Atomic-Unit-Signatures.md` §1), this skill checks *organisational* hygiene signals only — never code content, never git history internals beyond what's needed for the checks below.
**Shared rules:** `references/SUITE-CONVENTIONS.md`. Exempt from the run-lock (§13) because read-only.

## Explicit non-scope

**This skill never inspects commit history, branch state, uncommitted changes, or any code content.** It checks only whether the repo is organisationally well-placed and whether its container-level structure shows signs the atomic-unit boundary has been violated by a prior pass. This keeps it a folder-organisation skill, not a dev-tooling skill.

## Dependencies & STOP conditions

- Requires the managed folder to have `CLAUDE.md`, `INDEX.md`, `_LOGS/`. STOP if any is missing.
- No run-lock acquired.
- Never modifies any file, including the repos themselves.

## Checks performed

For each atomic-unit repo in the managed folder (identified by `references/Atomic-Unit-Signatures.md` §1 signals):

### 1. `.gitignore` presence
Missing `.gitignore` → flag as Warning. Common cause of accidental `node_modules`/build-output commits.

### 2. Repo placement in the user's taxonomy
Check whether the repo folder sits inside a Repositories pillar (per `references/Enterprise-Domain-Archetypes.md` Technical archetype) or its equivalent in the user's `TAXONOMY-REFERENCE.md`. Scattered outside → flag as Warning.

### 3. Empty worktree containers
`*.worktrees/` folders showing 0 children — atomic in form but functionally empty. Per `references/Atomic-Unit-Signatures.md` §1 edge case: log to `_LOGS/Data-Integrity-Findings.md` (does not auto-delete). This skill flags them so `/folder-review` or the user can decide.

### 4. Suite artifacts inside a repo
`_LOGS/`, `CLAUDE.md`, `INDEX.md` accidentally placed inside a repo folder — a boundary violation (suite logs belong to the managing folder root, never inside an atomic unit). Flag as **Fail** — this indicates a prior-run bug or user error.

### 5. Repo folder name mismatch
Repo name matches the git remote URL basename? If a git remote exists (checked via `git -C <repo> remote -v` — a metadata read, permitted under `references/Atomic-Unit-Signatures.md` §6), name mismatch is a Warning (a scattered rename in one place but not the other).

### 6. Duplicate repo indicator
Multiple folders under the managed root sharing the same repo remote URL → flag as Warning, cross-reference `_LOGS/Data-Integrity-Findings.md`. Common when a repo has been cloned twice or a stale copy remains after a canonicalisation.

## Output

Write `Repo-Check-Report-[DATE].md` to `_LOGS/` per `references/Report-Templates.md`: Per repo — Path | .gitignore Present | In Repositories Pillar | Empty Worktree Flag | Suite Artifacts Inside Flag | Name Match | Duplicate Indicator.

Fixes are **left to `/folder-review` or `/folder-execute`, not performed by this skill directly.** Moving a misplaced repo is a folder-organisation decision that requires user approval and reversibility logging.

## References

- `references/Atomic-Unit-Signatures.md` — §1 repo signals; §6 permitted metadata reads.
- `references/Enterprise-Domain-Archetypes.md` — Technical archetype's Repositories pillar.
- `references/Report-Templates.md` — Repo-Check-Report format.
- `TAXONOMY-REFERENCE.md` (user-configured) — where the user's own Repositories pillar lives.

## Cross-references

- Requires: `CLAUDE.md` + `INDEX.md` + `_LOGS/`; managed folder must contain at least one atomic-unit repo.
- Produces: `_LOGS/Repo-Check-Report-…md`. Never modifies. Findings routed to `/folder-review` or `/folder-execute` for actual fixes.
- **Run-lock exempt** per §13.

## Tested against

- 2026-09-17 · v1.0 live smoke test candidate — a managed folder with ~17 GitHub repos and one empty worktree container. Real live test in §11 pass.
