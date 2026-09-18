# Enterprise Domain Archetypes (Foldero Plugin — references/)

Extracted from `/folder-plan`'s inline domain-signal → archetype → typical-pillars table so `/organisation-setup` can read from and *extend* it per-user, and so the router and `/folder-status` can reason about "what kind of folder is this" without duplicating the mapping.

Consumed by: `/organisation-setup` (seeds the interview archetype menu), `/folder-plan` (primary consumer during taxonomy design), `/foldero` (router — recognises archetype signals in requests), `/folder-status` (per-folder archetype indicator in the dashboard).

---

## 1. Shipped archetypes

Each archetype is a starting point, not a straitjacket. `/organisation-setup` presents these as menu options and lets the user pick, extend, or override.

### Creative Professional
- **Domain signals:** solo creator, photography/video/design, client-project language, mixed brand + client work, recognisable asset-workflow structures (RAW → edited → deliverable).
- **Typical pillars:** Inbox · Clients · Brands · Assets · Finance · Admin · Archive.
- **Extends with:** Portfolio pillar for curated showcase (separate from active Assets).

### Business / Service Practice
- **Domain signals:** small-business operations, service delivery to named clients, invoices/contracts/policies as first-class content, non-creative deliverables.
- **Typical pillars:** Inbox · Operations · Clients · Finance · Marketing · Legal · Admin · Archive.

### Technical / Software / Dev
- **Domain signals:** git repos as top-level items, `package.json` / language-specific project files, code-review artefacts, deployment configs.
- **Typical pillars:** Inbox · Repositories · Docs · Assets · Config · Archive.
- **Repositories are atomic units** per `references/Atomic-Unit-Signatures.md` — never restructured internally by any skill.

### Family / Household
- **Domain signals:** person-name folders, mixed personal admin (finance, health, home), no commercial content, recreation/hobby folders.
- **Typical pillars:** Inbox · People [by name] · Finance · Health · Home · Recreation · Archive.

### Content Creator
- **Domain signals:** platform-specific folders (Instagram/YouTube/TikTok), asset production workflows, collab folders, brand deals as recurring content.
- **Typical pillars:** Inbox · Platforms · Content · Assets · Collab · Finance · Archive.

### Clinical / Professional Records
- **Domain signals:** client files with regulated retention requirements, session notes, safeguarding material, professional-registration paperwork.
- **Typical pillars:** Inbox · Client Records (RESTRICTED) · Clinical Practice · Business Admin · Professional Development · Marketing · Archive.
- **Restricted-domain by default** — all client-record content defaults to Tier 3 sensitivity per `references/Sensitivity-Classification-Guide.md`. Only `/folder-signoff` moves items from this pillar.

### Mixed / Unknown / Generalised
- **Domain signals:** no dominant pattern, or too little content to infer.
- **Typical pillars:** flat numbered scheme per `references/Numbering-Convention-Rules.md` — Inbox, several active named categories starting at `01.`, Archive at `99.`. User names the categories via `/organisation-setup`.

## 2. Cross-cutting pillars (add if evidence supports)

Independent of the archetype above, these pillars appear when content justifies:

- **Staging / Production / Development** (`90.` / `95.` / `98.`) — when there's a versioned live-vs-draft distinction (e.g. a site export, a product release pipeline).
- **Reference / Research** — reusable non-project reference material accumulating across projects.
- **Tools** — software installers, plugin configs, workflow templates independent of any single project.

## 3. Domain-signal detection heuristics (for `/folder-audit`)

When inferring the archetype during audit:

1. **File-extension distribution** — heavy `.psd` / `.raw` / `.tiff` / `.lrcat` → Creative. Heavy `.py` / `.js` / `.git` / `node_modules` → Technical. Heavy `.pdf` invoice/contract patterns → Business.
2. **Top-level folder-name patterns** — "Clients/", "Projects/", "Brands/" → Creative or Business. "Repositories/", "src/", "apps/" → Technical. Person-name folders at top level → Family or Clinical.
3. **README / manifest presence** — `package.json` at root → Technical. `INDEX.md` / `CLAUDE.md` prior artifacts → previously-managed by this suite; honour existing taxonomy over archetype default (§11 precedence).
4. **Confidence rule:** if two archetypes match at comparable confidence (both ≥60%), flag it during `/folder-audit` — do not pick silently. `/folder-plan` then asks the user or (if under `/organisation-setup`) records both archetypes as applicable.

## 4. Extension by `/organisation-setup`

`/organisation-setup` writes the user's chosen archetype(s) into `Enterprise-Domain-Archetypes.md` at the user's config level (not this shipped file), adds any custom archetypes the user defines, and applies the `<!-- USER-CONFIGURED — do not overwrite on plugin update -->` marker per `SUITE-CONVENTIONS.md` §16 (upgrade-safety rule).

Do not silently modify this shipped file — it is the plugin's fallback and stays generic.

## 5. Cross-skill application notes

- `/folder-plan` reads this file, checks for a user-configured extension via `/organisation-setup`, and blends the two: user-configured wins on any pillar the user overrode; shipped defaults fill in the rest.
- `/folder-status` reports the detected archetype per managed folder as a signal, not a fixed classification — a folder can shift archetype as its content evolves.
- `/foldero` (router) uses archetype signals in the request phrasing to disambiguate multi-plausible routes.
