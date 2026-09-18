# Sensitivity Classification Guide (Foldero Plugin — references/)

Worked detail expanding SUITE-CONVENTIONS.md §5. Classify by name, file extension, and folder structure only — never open contents to decide a sensitivity tier. A tier, once assigned, overrides whatever pillar the file *type* alone would suggest.

---

## Tier 1 — `SENS:FILE-BY-NAME`

Name confidently states what the document is, AND a clear restricted pillar already exists for it. Filed normally, but logged as sensitive in the activity log.

**Examples:**
- `tax-return-2023.pdf` → Finance/Tax
- `invoice-1001.pdf` → Finance/Invoices
- `model-release-signed.pdf` → Legal
- `passport-scan.jpg` → Personal/ID (if such a pillar exists; otherwise REVIEW-SORT, not guessed)

**Not this tier:** a file that is merely of a sensitive *type* (any PDF in a Finance-sounding folder) without the name itself confirming it. Being financial/legal/PII by type alone does not earn Tier 1 — it must be nameable with confidence.

## Tier 2 — `SENS:QUARANTINE`

Raw credentials, keys, password stores, or seed phrases. Always routed to `REVIEW-SORT/secrets`, never filed as a normal folder, regardless of what type-based pillar might otherwise apply.

**Name/pattern signals:**
- `passwords*.txt`, `*creds*`, `*secrets*`
- `.env`, `.env.*`, `.env.production`, `.env.local`
- Key file extensions: `.pem`, `.key`, `.p12`, `.pfx`
- `seed-phrase*`, `recovery-phrase*`, `wallet-backup*`

**Override example:** `.env.production` inside a project folder that would otherwise be filed under a Config or Dev Tools pillar → still goes to `REVIEW-SORT/secrets`, not Config. The quarantine tier always wins.

## Tier 3 — `SENS:RESTRICTED-DOMAIN`

Clinical, client, or safeguarding records, and adult content. **Gated** — always requires explicit user sign-off before any move, in any skill or mode. No unattended-move posture exists for this tier under any circumstance.

**Handling:**
- Stays in place until signed off.
- An **intended destination** is recorded at classification time (in `INDEX.md`'s `Awaiting sign-off` section) so that sign-off itself is a single, fast move — not a re-classification.
- Only `/folder-signoff` clears an `Awaiting sign-off` entry. No other skill (including `/folder-execute`, `/folder-inbox`, `/folder-review`) may move a Tier 3 item, even if the user asks that skill directly — redirect the user to `/folder-signoff`.
- `/folder-signoff` approves items **individually**, never in batch, regardless of how many are queued.

**Brand-specific defaults:** users may register specific brands / folders as defaulting to Tier 3 by context alone, even where filenames look innocuous, via `/organisation-setup` (populates `references/Sensitivity-Defaults.md`). Classify strictly by metadata / naming / structure only; do not summarise sensitive content beyond what's needed to route it.

## 4. Precedence when signals conflict

If an item could plausibly match more than one tier, apply the **more restrictive** tier — Quarantine over File-by-Name, Restricted-Domain over Quarantine if there's any indication both credentials and restricted-domain content might be co-located (e.g. a client-records export bundled with an API key file: split judgment at the atomic-unit level per Atomic-Unit-Signatures.md, don't force a single tier onto a mixed bundle — flag to REVIEW-SORT with both signals noted).

## 5. Cross-skill application notes

- `/folder-audit` and `/folder-plan`: assign tiers during inventory; record intended destinations for Tier 3 items even though no move happens yet.
- `/folder-execute`: files Tier 1 items normally; never moves Tier 2 or Tier 3 items — routes Tier 2 to `REVIEW-SORT/secrets` and leaves Tier 3 in place pending sign-off.
- `/folder-dedupe`: never opens contents to compare — if a duplicate candidate pair includes a Tier 2 or Tier 3 item, flag the group but do not route it into `REVIEW-SORT/duplicates` automatically; treat the sensitivity tier as taking precedence over dedupe handling.
- `/folder-lint`: checks that every `Awaiting sign-off` entry has a recorded intended destination — flags any that don't as a suite-output defect.
