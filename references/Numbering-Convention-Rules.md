# Numbering Convention Rules (Foldero Plugin — references/)

Promoted into the plugin's own `references/` folder so the plugin is self-contained per SUITE-CONVENTIONS §11's precedence order (live filesystem > the folder's own CLAUDE.md > project Numbering-Convention-Rules > this file as the Folder Structure SOP fallback). Content carried over from the project-level version; this copy is the plugin's built-in fallback when a managed folder has no project-specific numbering doc of its own.

**Note on dual copies and padding:** This plugin-references copy uses **zero-padded prefixes** (`01.`, `02.`, `03.`) as the generic fallback pattern — safer for cross-platform sort stability. The project-level `Numbering-Convention-Rules.md` in the File & Folder OS project uses **non-zero-padded prefixes** (`1.`, `2.`, `3.`) matching Dan's actual Documents root and its four established pillars. **Per SUITE-CONVENTIONS §11 precedence, the project-level doc wins for that specific root.** This file wins when no project-level doc exists for the managed folder.

Apply this to all new or renamed top-level folders during a first pass (`/folder-plan`, `/folder-execute`). The deeper decimal sub-scheme described below is reserved for `/folder-deepen` and is never imposed during a first pass.

---

## Prefix ranges

| Prefix | Purpose |
|---|---|
| `00.` | Inbox / dump zone for unsorted, relocated, or newly arrived items requiring further action. Includes `00. Inbox/REVIEW-SORT` and `00. Inbox/REVIEW-TRASH` (and `00. Inbox/CONFIRMED-TRASH` per SUITE-CONVENTIONS §3). |
| `01.`–`89.` | Active named category and brand folders (shared pool, sequential, non-hierarchical — see assignment rules). |
| `90.`–`94.` | Staging — work drafted but not yet deployed or published. |
| `95.`–`97.` | Production — live or currently deployed items. |
| `98.` | Development — in-progress builds, experiments, prototypes. |
| `99.` | Archive — completed, deprecated, or retired items. |

## Assignment rules

1. Number active categories and brand folders sequentially in the order they're created, starting at `01.`. Do not renumber existing folders that already have a number assigned unless they're being merged or removed.
2. Leave gaps where sensible — this is a flat sequential scheme, not a Dewey-style hierarchical one, so no reserved sub-ranges are needed at the top level.
3. Brand folders and functional category folders share the same `01.`–`89.` numbering pool — never a separate numbering track for brands.
4. A brand only earns its own top-level number if real evidence shows it has identifiable dedicated content — never assume a brand folder should exist by default (per this project's brand-context rule).
5. If two items are judged equally important, order alphabetically within that tier.
6. Never reuse a number retired to Archive (`99.`) — retiring an item does not free its old number for reassignment.

## Sub-numbering within a category (deeper pass only)

- Subfolders inside a numbered top-level category inherit the parent's number as a decimal prefix: `03. Brand Assets` containing `03.1 Logos`, `03.2 Style Guides`.
- Only `/folder-deepen` applies this. The first pass (`/folder-plan`/`/folder-execute`) creates plain, un-numbered functional subfolders freely (`03. Finance/Tax`) but never imposes the decimal sub-scheme.
- When `/folder-deepen` applies the §2a re-homing exception during a deeper pass, the resulting destination must still conform to this decimal sub-numbering — a re-homed item does not get a numbering exception alongside its confidence exception.

## Naming format

- Format: `NN. Title Case Name` (two-digit prefix, period, space, name).
- No special characters other than `&` and `-` where grammatically necessary (`04. Legal & Contracts`).
- Approved abbreviations: `SEO`, `AI`, `DJ`. Do not introduce new abbreviations without checking here first.
- Status/state suffixes may be appended after an em dash: `98. Development — Website Rebuild`.

## Worked examples

- `00. Inbox` (containing `REVIEW-SORT`, `REVIEW-TRASH`, `CONFIRMED-TRASH`)
- `01. Business & Admin`
- `02. Clients & Projects`
- `03. Brand Assets`
- `04. Legal & Contracts`
- `05. [Brand A]` — user's primary brand or persona (populated by `/organisation-setup`)
- `06. [Brand B]` — additional brand
- `07. [Brand C]` — additional brand (may include restricted-tier defaults)
- `08. [Family Brand A]` — brand managed on behalf of another person
- `09. [Family Brand B]` — additional family brand
- `10. Finance`
- `11. Reference & Research`
- `12. Personal`
- `95. Production — Live Sites`
- `98. Development — In Progress Builds`
- `99. Archive`

(These are illustrative — `/organisation-setup` populates real brand names into the user-configured copy of this file.)

## Lifecycle Staging Sub-Scheme (from project-level Section 9, 2026-09-15)

Certain pillars use a **lifecycle staging** sub-scheme distinct from the decimal sub-numbering rules above. This is the recognised convention for pillars whose contents move through activity states over time (client engagements, source repositories):

- **Sub-numbering:** `01. Active/` · `02. Delivered/` (or `02. Paused/` for repos) · `99. Archive/`. Zero-padded because they group at the front of a Finder sort.
- **Applied to:** pillars like `Clients/` and `Repositories/GitHub/` — extendable to other pillars where lifecycle staging fits.
- **Distinct from decimal sub-numbering:** these are lifecycle *stages*, not category sub-pillars. Do not nest decimal categories underneath (`01. Active/1.1 ...`) — the Active/Delivered/Archive layer is terminal; individual client or repo folders sit directly inside it as atomic units.
- **Default state for new items:** `01. Active/`. Movement to `02. Delivered/`/`02. Paused/` and `99. Archive/` is a user decision, not automated.
- **Repos are atomic:** movement between lifecycle folders is whole-folder only. Never descend into a repo, never split a worktree from its parent repo.

## Cross-skill application notes

- `/folder-lint` checks new top-level folders against this file's prefix ranges and naming format, flagging gaps/clashes as suite-output defects (not content-taxonomy issues — that distinction stays with `/folder-audit`).
- `/folder-status` reports whether a managed root's own numbering has drifted from this scheme without re-deriving the rules itself — it defers entirely to this reference.
