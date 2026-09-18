<!-- TEMPLATE — the shipped default. `/organisation-setup` copies this into the user's config location and applies the USER-CONFIGURED marker. Do NOT edit this shipped template directly at runtime; edit the user-configured copy instead. -->

# Taxonomy Reference — [User's Own Decided Pillar Skeleton]

**Status:** Template (unconfigured). Run `/organisation-setup` to populate with your own pillar decisions.

**Distinct from `Brand-Taxonomy-Reference.md`:** this file records the user's own top-level pillar structure (names, purpose, numbering). `Brand-Taxonomy-Reference.md` maps brand/entity *signals* to classification. Both are consumed by `/folder-plan` — this one for pillar structure, that one for brand identification within pillars.

**Precedence** (per `references/SUITE-CONVENTIONS.md` §11):
`live filesystem > the folder's own CLAUDE.md > this file (if /organisation-setup has been run) > project Numbering-Convention-Rules > the Folder Structure SOP fallback`.

If a specific managed folder's own `CLAUDE.md` recorded a taxonomy decision **before** this file existed for the user, that folder's `CLAUDE.md` continues to win. This file never silently overrides an already-established structure — it is a default/starting point for new or unstructured folders.

---

## 1. Preferred pillar skeleton

*Populated by `/organisation-setup`. Empty in the shipped template.*

Example populated shape (illustrative — replace on setup):

```
00. Inbox                          — Sole intake; drop-now-file-later
01. [Category A]                   — [User's own one-line description]
02. [Category B]                   — [User's own one-line description]
…
99. Archive                        — Retired items
```

## 2. Numbering scheme

*Zero-padded (`01.`) or non-zero-padded (`1.`) — captured from `/organisation-setup`'s interview per `references/Numbering-Convention-Rules.md`. Empty in the shipped template.*

## 3. Reserved prefixes

- `00.` — Inbox / staging (contains `REVIEW-SORT/`, `REVIEW-TRASH/`, `CONFIRMED-TRASH/`).
- `99.` — Archive at every level.
- `90.`–`98.` — Staging / Production / Development (added only when the user's work has a versioned live-vs-draft distinction).

## 4. Archetype(s) applied

*Populated by `/organisation-setup` from `Enterprise-Domain-Archetypes.md`. Empty in the shipped template.*

## 5. Overrides and custom pillars

*Any pillar the user overrode from the archetype default, plus any custom pillars they added. Empty in the shipped template.*

---

*This shipped template contains no user data. When populated by `/organisation-setup`, the resulting file carries the `USER-CONFIGURED` header marker and is protected from silent plugin-update overwrite per `SUITE-CONVENTIONS.md` §16.*
