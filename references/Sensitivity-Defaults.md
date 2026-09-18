<!-- TEMPLATE — the shipped default. `/organisation-setup` copies this into the user's config location and applies the USER-CONFIGURED marker. Do NOT edit this shipped template directly at runtime; edit the user-configured copy instead. -->

# Sensitivity Defaults — [User's Own Tier Mapping]

**Status:** Template (unconfigured). Run `/organisation-setup` to populate with your own brand/tier mappings.

**Complements:** `references/Sensitivity-Classification-Guide.md`. That file defines the three-tier model (FILE-BY-NAME / QUARANTINE / RESTRICTED-DOMAIN); this one records **which of the user's own brands, folders, or content types default to which tier**.

**Precedence:** the shipped three-tier model is a suite invariant — the user cannot change tier semantics, only which of their own content maps to which tier.

---

## 1. Tier 3 (`SENS:RESTRICTED-DOMAIN`) — user's own defaults

*Populated by `/organisation-setup`. Empty in the shipped template.*

Example populated entry (illustrative — replace on setup):

```
- Brand or folder: [Brand X]
  Rule: any content under `[path to Brand X]/` defaults to Tier 3 unless the filename itself is explicitly non-restricted.
  Reason: [User's own reason — e.g. adult content, clinical records, safeguarding data.]
```

## 2. Tier 2 (`SENS:QUARANTINE`) — extensions

The shipped Sensitivity-Classification-Guide.md Tier 2 patterns (`.env`, `passwords*.txt`, key files, seed phrases) are always active. The user may add additional Tier 2 patterns here specific to their setup.

*Empty in the shipped template.*

## 3. Tier 1 (`SENS:FILE-BY-NAME`) — user's restricted pillar map

Tier 1 items file normally but are logged sensitive. The user can register which of their pillars are their "restricted" destinations for named-legal / named-financial / named-PII content.

*Empty in the shipped template.*

## 4. Cross-brand precedence

Per the cross-brand ambiguity resolver in `/folder-plan` and `/folder-review`: if an item's name/structure signals match two or more registered brands with comparable confidence, and one candidate is Tier 3 while another isn't, treat the item as **Tier 3 pending human resolution** (safer default). This rule is invariant regardless of what this file records.

## 5. Tagging constraint reminder

Nothing recorded in this file changes the rule in `references/Metadata-Tag-Vocabulary.md` §3: specific Tier 3 brand names are **never** written to portable file metadata by `/folder-tag`. Tier 3 content receives the generic `restricted` marker only, if tagging at all.

---

*This shipped template contains no user data. When populated by `/organisation-setup`, the resulting file carries the `USER-CONFIGURED` header marker and is protected from silent plugin-update overwrite per `SUITE-CONVENTIONS.md` §16.*
