---
name: folder-audit
description: Chain Step 1 — read-only audit of any folder. Inventories, pre-tags, flags sensitivity, writes an Audit-Report. Trigger on "audit", "map", "analyse", "my folder is a mess".
---

# Foldero — Audit & Map

**Version:** v2.0 · Last modified 2026-09-17
**Role:** Read-only folder analyst. The only file this skill writes is its own Audit-Report (into `_LOGS/`).
**Chain position:** Step 1 of 3. Hands off to `/folder-plan`.
**Shared rules:** `references/SUITE-CONVENTIONS.md`. **Read-only — no run-lock acquired.**

## When to use

Any request to understand, audit, tidy, restructure, or take control of a folder's contents. If files need moving, this skill still runs first — you never plan or move before you have mapped.

## Dependencies & STOP conditions

- Requires read access to a single working folder root. STOP if the root is ambiguous or you can see outside it, the root can't be read, or the request would require deleting/modifying file contents.
- Read any existing `CLAUDE.md` and `INDEX.md` at the root before inferring anything. Never hardcode a path or taxonomy from a prior project.
- If `/organisation-setup` has never been run for this user, note it and continue — the audit is still useful; personalised inference will kick in on the next run.

## Step 0 — Mode selector

If the user (or the invoking chain/router) already supplied a mode, skip this prompt. Otherwise present:

> **Choose your workflow mode:**
> **1. Hands-Off** — audit → plan → execute run automatically; files moved as needed; nothing deleted; full log produced.
> **2. Guided** — pauses at taxonomy sign-off and each ambiguous or sensitive item.
> **3. Manual** — audit and plan only; execution then either scaffolds empty folders or prints a plain-text tree.

Pass the selected mode to Steps 2 and 3.

## Step 1 — Context sweep

Run `enterprise-search` scoped only to this folder's own contents. Do not query outside the root. Fold findings into the domain inference. If unavailable, continue with direct reads.

## Step 2 — Audit objectives, in order

1. **Scope confirmation** — state the exact root; confirm you can read it and cannot see outside it.
2. **Purpose & domain inference** — from name, top-level shape, file types, naming, and any prior CLAUDE.md/INDEX.md: owner type, primary purpose, industry signals. Use `references/Enterprise-Domain-Archetypes.md` domain-signal detection heuristics. Record a confidence per judgement.
3. **Full top-level inventory** — every root item: name, type, approx size, last-modified, one-line purpose. Atomic units are single rows per `references/Atomic-Unit-Signatures.md`. This list is the **conservation baseline** per §8.
4. **Depth & density** — per top-level folder, depth and item count; flag unusually dense/deep structures. Note candidates for a later deep pass.
5. **Mess signals** — loose root files, generic names, suspected duplicates, version-suffix clutter, empty/near-empty folders, mixed-purpose containers, OS-cruft.
6. **Classification pre-tagging** — tag each top-level item `CONFIDENT` / `NEEDS-REVIEW` / `LIKELY-JUNK` / `KEEP-IN-PLACE` per §4, §6, §7. Tags only, no action. Plain folder atomicity ambiguous → `NEEDS-REVIEW`.
7. **Sensitivity flags** — assign one of the three tiers per §5, cross-referenced against the user's `references/Sensitivity-Defaults.md`. Record intended destination for each `SENS:FILE-BY-NAME` and each gated item. Never summarise contents.
8. **Existing convention check** — document numbering/naming/structure already in place; extend rather than override (precedence per SUITE-CONVENTIONS §11, including the user's `TAXONOMY-REFERENCE.md`).
9. **CLAUDE.md / INDEX.md gap report** — what's accurate, stale, missing.
10. **Claude Code project-folder detection** — flag any folder inside the managed tree that carries a Claude Code project **signal** per `references/Claude-Code-Continuity.md` §2: a `.claude/` directory containing `settings.json`, `settings.local.json`, `.mcp.json`, `agents/`, `skills/`, or `commands/`; a `CLAUDE.md` file; or a `.mcp.json` file. Folder-name heuristics ("Claude Code Scripts", "Claude Projects", etc.) are NOT signals — detection reads filesystem contents only. Every flagged folder is tagged `CLAUDE-CODE-PROJECT` in the Audit-Report; the flag propagates forward to `/folder-plan` and `/folder-execute`, which use it to trigger the four-option pre-move decision gate per `Claude-Code-Continuity.md` §4. Detection at audit time is informational only — no action, no state change, no touch of `~/.claude/` or `~/.claude.json` (both are hard-excluded per `Claude-Code-Continuity.md` §1).

## Output

Write `Audit-Report-[FOLDERNAME]-[DATE].md` to `_LOGS/` (create `_LOGS/` if absent) per `references/Report-Templates.md`. End with a **Handoff to Skill 2** block: inferred domain/purpose · selected mode · three-tier sensitivity register with intended destinations · KEEP-IN-PLACE list · conservation baseline · deep-pass candidates · top open questions · cross-brand ambiguity candidates.

## Mode-dependent close

- **Hands-Off:** launch `/folder-plan`.
- **Guided:** present a plain-language summary and ask to confirm before Step 2.
- **Manual:** produce the report and stop; ask whether they want a scaffolded tree or plain-text tree from Step 2.

## References

- `references/File-Type-Heuristics.md` — primary consumer during inventory.
- `references/Atomic-Unit-Signatures.md` — classifying atomic units by name/structure.
- `references/Sensitivity-Classification-Guide.md` — tier assignment during inventory.
- `references/Enterprise-Domain-Archetypes.md` — domain-signal detection.
- `references/Sensitivity-Defaults.md` — user's per-brand tier mappings.
- `references/Report-Templates.md` — Audit-Report column structure.
- `references/Claude-Code-Continuity.md` — signal-based Claude Code project detection (Step 2 item 10) and the four-option remediation gate propagated forward.
- `SENS:RESTRICTED-DOMAIN` sign-off is actioned by `/folder-signoff`, not this skill.

## Cross-references

- Produces: `_LOGS/Audit-Report-…md`, read by `/folder-plan`.
- Related standalone skills: `/folder-inbox`, `/folder-import`, `/folder-deepen`, `/folder-undo`. Front door: `/foldero`.

## Tested against

- 2026-09-15/17 · creative & dev dumps + stress fixtures. Live tested against a managed folder. 31/31 behaviour assertions pass at v1.3; v2.0 adds user-config awareness, Enterprise-Domain-Archetypes reference, Sensitivity-Defaults reference.
