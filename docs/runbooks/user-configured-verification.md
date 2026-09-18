# Runbook — USER-CONFIGURED Marker Verification (after plugin update)

**Purpose:** Verify that user-configured reference docs (the outputs of `/organisation-setup`) survived a plugin update intact.

**When to run:** After any plugin update — Cowork sync, manual re-install, `.plugin` file replacement — has touched the plugin's `references/` directory.

**Skill involvement:** `/folder-lint` performs the automated part (check 6e); this runbook is what to do if the check flags an issue, and covers manual verification for installers who don't run `/folder-lint` reflexively.

---

## Background

`/organisation-setup` writes user-level configuration into several reference-doc files. Each file it writes carries a header marker:

```
<!-- USER-CONFIGURED — do not overwrite on plugin update -->
```

The plugin's own update process is *expected* to check for this marker before touching any file under `references/` — a marked file is never silently replaced by a new shipped default.

**But this is a convention the plugin declares, not a guarantee the plugin can force.** Whether the actual Cowork / Claude Code sync process honours the marker natively is outside the plugin's control. This runbook exists to give installers a way to verify manually.

## Automated verification (preferred)

Run `/folder-lint` against any managed folder. Check 6e reports:

- **Pass** — every reference-doc file that shows signs of user customization carries the `USER-CONFIGURED` marker.
- **Warning** — a file diverges from the shipped template but is missing the marker. This means either (a) the marker was stripped by an update, or (b) the file was hand-edited without a marker. Either way, the file is now unprotected against future updates.

## Manual verification

If you'd rather check without invoking `/folder-lint`:

1. **Locate the plugin's `references/` directory** — typically under a Cowork / Claude Code plugin cache like `~/.claude/plugins/synced/<installation-id>/foldero/references/`.
2. **Check each of the seven user-configurable files:**
   - `Brand-Taxonomy-Reference.md`
   - `TAXONOMY-REFERENCE.md`
   - `File-Type-Heuristics.md`
   - `Numbering-Convention-Rules.md`
   - `Enterprise-Domain-Archetypes.md`
   - `Sensitivity-Defaults.md`
   - `Metadata-Tag-Vocabulary.md`
3. **For each file, look at the first ~5 lines.** Files you customized should start with (or contain very early) the marker:
   ```
   <!-- USER-CONFIGURED — do not overwrite on plugin update -->
   ```
4. **If the marker is present** — you're fine. The file survived the update.
5. **If the marker is missing on a file you customized** — the update likely reverted the file to the shipped default. See "Recovery" below.

## Recovery

If a user-configured file was overwritten by an update:

1. **Do NOT run `/organisation-setup` immediately.** That would blow away any partial customization that survived and overwrite with fresh interview answers.
2. **Check for a backup.** Cowork / Claude Code plugin sync sometimes preserves the previous version — look in the plugin cache for `.bak` or `previous-version` suffixes, or in a `.trash/` sibling directory.
3. **If a backup exists**, restore it manually (copy back into `references/`, add the marker if it's missing, save).
4. **If no backup exists**, re-run `/organisation-setup` — you'll go through the interview again. Note that the plugin can only re-generate what your answers produce; anything you manually hand-edited on top of `/organisation-setup`'s output needs to be re-applied by hand.
5. **After recovery, verify all seven files have the marker.** Re-run `/folder-lint` check 6e to confirm.

## Preventive measures

- Before applying any plugin update, especially a major-version bump (v1 → v2, v2 → v3), read the update's changelog to see whether reference-doc formats changed. If they did, back up your user-configured files first.
- Consider committing your user-configured reference docs to a personal git repo. That way an update overwrite is trivially recoverable.
- Watch for `/folder-lint` Warnings on check 6e — they're the first signal that a file lost its protection.

## Long-term intent

This runbook exists because the plugin can declare a convention but not enforce Cowork's sync behaviour. Future work may include a native plugin-sync hook that reads the marker before every write. Until then, `/folder-lint` check 6e + this manual procedure is the belt-and-braces approach.
