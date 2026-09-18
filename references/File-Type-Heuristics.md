# File-Type Heuristics for Classification (Foldero Plugin — references/)

Promoted from project-level resource into the plugin's own `references/` folder so every skill can point to the same heuristics without depending on a document the plugin doesn't formally own. Content carried over unchanged from the version used in the Documents audit; scope note added so it reads correctly as a plugin-portable reference rather than a Documents-specific one.

**Note on dual copies:** a project-level `File-Type-Heuristics.md` may also exist in the File & Folder OS project. Per SUITE-CONVENTIONS §11 precedence, the project-level doc wins for its specific managed root; this plugin-references copy is the built-in fallback when a managed folder has no project-specific heuristics doc.

Rules of thumb for classifying ambiguous items during any audit, inbox, review, or dedupe pass. These are heuristics, not hard rules — if a heuristic conflicts with the ≥90% confidence rule (SUITE-CONVENTIONS §2) or the §2a re-homing exception, defer to `REVIEW-SORT`.

---

## Route to a category or brand folder (high confidence)

- Standard document types with clear naming (invoices, contracts, briefs, style guides) matching a known brand or category in the folder's taxonomy reference (e.g. `Brand-Taxonomy-Reference.md` where the managed folder has one).
- Source code / project folders with a recognisable `package.json`, `.git`, or framework structure tied to a known client or brand project — see Atomic-Unit-Signatures.md before deciding whether to treat as a unit.
- Design files (`.psd`, `.ai`, `.fig`, `.sketch`) with descriptive names matching a brand or project.
- Finished media exports (final images, final audio mixes, published PDFs) clearly labelled as final/deliverable.

## Route to `REVIEW-SORT` (ambiguous, needs human judgement)

- Files or folders with generic/auto-generated names: "Untitled", "New Folder", "Copy of...", "Document1", numeric-only names with no other context.
- Items that plausibly span two categories or two brands.
- Config/environment files sitting alone outside a project structure (`.env`, `.json`, `.yaml`) with no parent project folder nearby — cross-check Sensitivity-Classification-Guide.md, since some of these are actually Tier 2 quarantine cases, not ordinary REVIEW-SORT.
- Anything containing personally sensitive or financial content where you're not confident of the correct destination — flag rather than guess, and don't summarise the sensitive content itself beyond what's needed to route it.
- Folders that are empty or contain only other empty folders (see also SUITE-CONVENTIONS §7 for the empty-folder disposition rule).

## Route to `REVIEW-TRASH` (likely disposable)

- Zero-byte files.
- Temp/lock files: `.tmp`, `~$*`, `.DS_Store`, `.lock`, `Thumbs.db` (also see SUITE-CONVENTIONS §6, OS-metadata cruft).
- Export/cache artifacts from tools with timestamp-only names and no other identifying content (e.g. `export_20260214_final_v3_v2.zip`).
- Exact duplicate filenames with version suffixes where an original still exists elsewhere and the duplicate appears superseded (`file (1).pdf`, `file_copy.docx`) — for systematic duplicate scanning across a whole tree, use `/folder-dedupe` rather than relying on this heuristic alone during a single-pass audit.
- Old installer files, `.dmg`, `.pkg`, or setup files with no other purpose once installed.
- Anything recognisable as leftover scaffolding from an AI tool/skill run (stray prompt logs, tool output dumps not saved into a project) sitting loose at the top level.

## Do-not-guess rule

If an item matches signals from more than one list above, always defer to the more cautious bucket: `REVIEW-SORT` over a category folder, and `REVIEW-SORT` over `REVIEW-TRASH` if there's any doubt it might still be needed.

## Cross-skill application notes

- `/folder-audit`: primary consumer during first-pass inventory.
- `/folder-review`: re-applies these heuristics when a human declines to decide immediately and asks "why was this flagged" — the manifest reason line should trace back to one of the bullets above.
- `/folder-dedupe`: uses the REVIEW-TRASH duplicate-suffix bullet only as a name-pattern signal, not as its confidence source — actual duplicate confidence comes from `/folder-dedupe`'s own hash/size matching per its skill body.
