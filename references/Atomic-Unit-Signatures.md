# Atomic Unit Signatures (Foldero Plugin — references/)

Detailed lookup reference expanding SUITE-CONVENTIONS.md §4. Used by `/folder-audit`, `/folder-review`, `/folder-dedupe`, and `/folder-lint` whenever a decision depends on whether something is an atomic unit. Classify by name/structure only — never open file contents to decide.

**Core rule (unchanged from §4):** an atomic unit is never inspected, split, or restructured internally — it moves whole, or it doesn't move.

---

## 1. Repositories

Treat as atomic if the folder contains any of:

- `.git` (any depth inside the candidate folder, not just root)
- `package.json`, `pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`
- `node_modules`
- Build output directories: `dist`, `build`, `.output`
- Framework directories: `.next`, `.astro`, `.turbo`, `.wrangler`, `.vercel`
- `worktrees/` or `*.worktrees/` subfolders (git worktree containers)

**Edge case — empty worktree containers:** a `*.worktrees/` folder showing 0 children is still atomic in form but functionally empty. Do not delete or auto-resolve. Log to `Data-Integrity-Findings.md` (e.g. `<repo-name>.worktrees/ empty container`) and leave for the user's manual decision.

## 2. Application packages

Treat as atomic by extension alone — these are bundle formats, not folders of loose files, even though Finder may show them as navigable:

`.pages`, `.key`, `.numbers`, `.logicx`, `.musiclibrary`, `.lrlibrary`, `.lrcat`, `.djayMediaLibrary`, `.photoslibrary`, `.rtfd`, `.xcodeproj`

Never descend into any of these regardless of how large or how old.

## 3. Markerless self-contained folders

No extension or fixed file marks these — judge structurally. A folder is atomic when **two or more** of the following hold:

- A root entry/index/manifest file: `index.html`, `manifest.json`, or a `report.md`/`README` that sibling assets clearly serve.
- Sibling structural folders: `assets`, `css`, `js`, `img`, `images`, `fonts`.
- A version-suffixed folder name: `site-export-v3`, `build_final_v2`.
- Sequential or paired asset naming inside (e.g. `slide-01.png` … `slide-24.png`, or `track01.wav` + `track01.mid`).

## 4. NOT atomic — the override

A **generically-named container** always beats atomic-suspicion, even if it happens to contain some of the signals above:

`misc stuff`, `New Folder`, `stuff`, `to sort`, `temp`, `old files`

These are never atomic. Treat their contents as loose items for normal classification, not as a unit to preserve whole.

## 5. Ambiguity fallback

If a plain folder could genuinely be read either way (e.g. it has one structural signal but a generic name), do not descend and scatter it, and do not freeze the whole run over it. Route the **whole folder** to `REVIEW-SORT` with a one-line reason citing which signal was present and which was missing.

## 6. Cross-skill application notes

- `/folder-dedupe`: when comparing two atomic units for duplicate detection, compare by name + size + structure signature only — never diff internal contents.
- `/folder-lint`: flag (don't fix) any case in `_LOGS/` reports where a prior run appears to have split or partially moved an atomic unit — this indicates a prior-run bug, not a new decision to make.
- `/folder-review`: an atomic unit sitting in REVIEW-SORT is resolved as a single move decision — never partially filed.
