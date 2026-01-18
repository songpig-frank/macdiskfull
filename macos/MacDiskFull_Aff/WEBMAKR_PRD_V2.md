# PRD: WebMakr v2 — Projects, Templates, Import/Export, Affiliate Link Engine, Seeded Uniqueness, Mobile Editing

## 1) Summary

WebMakr is a SwiftUI macOS (11.0+) app that generates static comparison sites (HTML/CSS + robots/sitemap). This PRD adds a scalable workflow so sites can be created and updated via JSON templates, automatically personalized per affiliate, and edited from a phone without manual data entry.

## 2) Goals

- Create sites in minutes from JSON templates (no repetitive clicking).
- Export/import projects reliably (backup, share, replicate).
- Default affiliate link insertion for GetDiskSpace when affiliate is approved/configured, with opt-out toggles.
- Support multiple affiliate providers (LemonSqueezy today; easily switch later).
- Seeded uniqueness so two affiliates don't generate identical wording unless they copied the same config.
- Mobile edits through iCloud-exported JSON (v1), optional real-time sync later.

## 3) Non-Goals (v1)

- Hosting/publishing pipeline
- Scraping competitors' pricing/features
- AI text generation that invents claims
- Full WYSIWYG editor on mobile

## 4) Current State (confirmed)

| Component | Details |
|-----------|---------|
| **App** | SwiftUI + AppKit (NSOpenPanel etc.) |
| **Project folder** | `/Users/nc/macdiskfull_affiliate/macos/MacDiskFull_Aff/` |
| **Models** | `Site`, `Product` (Codable) |
| **Storage** | UserDefaults key `"WebMakr_CurrentSite"` storing JSON-encoded Site |
| **Generator** | `SiteGenerator.swift` outputs static files to `temporaryDirectory/WebMakr/<domain>/` |
| **Templates** | Single hardcoded template in SiteGenerator.swift |
| **Import/Export** | Methods exist in SiteStore.swift but no UI wiring |

## 5) Users / Personas

| Persona | Description |
|---------|-------------|
| **Admin/Owner (you)** | Creates master templates and defaults; wants GetDiskSpace to win |
| **Affiliate** | Imports a template, inputs affiliate ID, optionally edits copy, generates site |
| **Mobile Editor** | Makes quick edits on phone and re-imports on Mac |

## 6) Product Decisions (locked for v1)

### Decision A: JSON-first "Project" source of truth
- All site state can be represented as a JSON project file.
- UserDefaults becomes optional convenience, not primary storage long-term.

### Decision B: Provider-agnostic affiliate link engine
- Products store canonical URLs.
- Tracked URLs are generated at generate time by configurable provider rules.
- LemonSqueezy is a default provider configuration, not hardcoded behavior.

### Decision C: Mobile editing via iCloud JSON loop (no backend)
- Export project JSON to iCloud Drive
- Edit JSON on phone
- Import back into app
- Optional future cloud sync is reserved for v2.

---

## 7) Functional Requirements

### F1) Multi-Project Support (Project Library)

#### Problem
UserDefaults stores only one active site, limiting templates, iteration, and scale.

#### Requirements

Introduce `Project` concept:
- `projectId`: UUID
- `site`: Site
- `createdAt`, `updatedAt`
- `displayName` (default = site.name)

Store projects as files:
- `~/Library/Application Support/WebMakr/Projects/<projectId>.json`

Add Projects sidebar/list in UI (simple list is fine on macOS 11).

"Current project" is loaded at launch.

#### Migration
On first run after update:
- If UserDefaults contains `"WebMakr_CurrentSite"` and Projects folder is empty:
  - Create a new project file from it
  - Set as current project
  - Keep UserDefaults copy for one version (fallback), then deprecate

#### Acceptance Criteria
- [ ] Create, switch, rename, duplicate, and delete projects.
- [ ] Relaunch preserves library.

---

### F2) JSON Import / Export (In-App File Menu)

#### Requirements

Add menu items:
- **File → New Project**
- **File → Open…** (open a project JSON file)
- **File → Import Site…** (imports a Site JSON into current project)
- **File → Save Project As…** (exports current project JSON)
- **File → Export Site…** (exports current site JSON only)
- **File → Export Template…** (see F3)

#### Import behavior

Validate & normalize:
- Clamp rating 0–5
- URL format validity
- Max 10 pros/cons bullets (truncate with warning)

Upsert products:
- Match on `id` first, else `name` (case-insensitive)

Enforce only one "recommended" product:
- If multiple `recommended = true`, keep first and set others false

User feedback:
- After import, show a modal report:
  - Imported fields count / updated count
  - Warnings list (e.g., truncated bullets)

#### Acceptance Criteria
- [ ] Export → Import round trip produces same generated output (aside from normalization like bullet truncation).
- [ ] Import doesn't crash on bad JSON; it reports errors.

---

### F3) Template Library (JSON Templates)

#### Requirements

Add Templates directory:
- `~/Library/Application Support/WebMakr/Templates/<templateId>.json`

Template object includes:
- `metadata`: templateId, templateName, templateVersion, createdAt
- A `site` block and a `products` block (same schema as site/project, but can include variants)

#### UI
- **New Project** opens a Template Picker (list + preview)
- **"Export Template…"** saves the current site as a template (strip affiliate IDs by default)
- **"Import Template…"** adds a template JSON to library

#### Shipped templates (v1)
1. MacDiskFull Comparison (4 product comparison table)
2. Minimal Single Pick + Alternatives
3. Neutral "Best Tools For Mac Storage" (SEO-friendly headings)

#### Acceptance Criteria
- [ ] New project from template in <15 seconds.
- [ ] Templates persist.

---

### F4) Affiliate System (Default Populate + Opt-Out)

#### Requirements

Add to site:
- `affiliateProfile` (affiliate identity + global toggles)
- `affiliateProviders` (provider configs and per-program rules)

Per-product:
- `affiliateProgramKey` (string)
- `trackingOverride` (inherit|on|off)

#### UX

**In Site Settings → Affiliate:**
- Affiliate ID (string)
- ✅ Use affiliate links when available (default ON if affiliate ID present)
- ✅ Earn commission from GetDiskSpace (default ON)
- ☐ Earn commission from partner products (default OFF)
- UTM defaults (optional fields): source/medium/campaign

**In each Product editor:**
- "Tracking for this product": Inherit / On / Off
- Program Key (dropdown optional; default from template)

#### Acceptance Criteria
- [ ] When affiliate ID exists, GetDiskSpace link becomes tracked by default.
- [ ] User can turn off GetDiskSpace tracking with one toggle and links revert to canonical.
- [ ] Partner tracking stays off by default unless user opts in.

---

### F5) Provider-Agnostic Link Builder (LemonSqueezy now, swap later)

#### Requirements

Products store:
- `canonicalUrl` (always present)
- `affiliateProgramKey` (e.g., "getdiskspace", "daisydisk")
- `affiliateLinkOverride` optional (advanced users)

Site stores provider config:
- `affiliateProviders.activeProvider` default = "lemonsqueezy"
- `affiliateProviders.providers` dictionary
- `affiliateProviders.programs` dictionary mapping programKey → provider + enabledDefault

Provider types supported (v1):
- `query_param` (e.g., `?aff=ID`)
- `path` (e.g., `/ref/ID`)
- `utm_only` (UTM parameters, universal fallback)

#### Link generation rules (generate time):
1. If global tracking off → use canonicalUrl
2. Else resolve provider for programKey
3. If provider requires affiliateId and missing → canonicalUrl + warning
4. Build trackedUrl
5. Append UTMs if configured, never duplicate

#### Acceptance Criteria
- [ ] Changing provider config changes generated tracked links without changing product data.
- [ ] No double-appending of params across re-generations.

---

### F6) Seeded Uniqueness Engine (Deterministic Copy Variants)

#### Requirements

Allow selected text fields to be either a single string or a list of curated variants.

**Supported fields (v1):**
- `site.tagline`
- `product.shortDescription`

**Optional (v2, leave hooks):**
- heroHeadline, heroSubhead
- CTA labels
- FAQ items
- Section headings

#### Seed source:
`affiliateProfile.affiliateId`

#### Algorithm:
SHA-256(affiliateId + appSalt) → deterministic RNG

#### Selection:
For each variant field, pick one variant index using RNG

Save "chosen variants" into site on import OR apply at generate-time.

**Recommended approach:**
Apply at import-time and store the resolved text in the project, so what you see in UI matches output.

#### Guardrails:
- Variants are curated; do not change facts (prices/features)
- No competitor accusations or privacy claims without citations

#### Acceptance Criteria
- [ ] Affiliate A and B produce different taglines/shortDescriptions from the same template.
- [ ] Same affiliate ID produces the same wording every time.
- [ ] If someone copies JSON, they get identical wording (desired).

---

### F7) Mobile Editing v1 (iCloud JSON Loop)

#### Requirements

Add two actions:
- **File → Export for Mobile Editing…**
  - Saves Project JSON to iCloud Drive folder (default suggestion `iCloud Drive/WebMakr/`)
- **File → Re-import from Mobile…**
  - Opens NSOpenPanel pointed to that folder

Export format:
- Pretty printed
- Stable ordering where possible
- Includes a `notes` field with quick edit instructions (valid JSON field)

#### Mobile workflow:
1. Export to iCloud
2. Edit JSON on phone (Files app)
3. Re-import on Mac
4. Regenerate

#### Acceptance Criteria
- [ ] A user can edit tagline/pros/cons on phone and regenerate within 2 minutes.

---

## 8) Data Schema

### Project JSON (v1)
```json
{
  "version": 1,
  "projectId": "UUID",
  "displayName": "MacDiskFull",
  "createdAt": "ISO-8601",
  "updatedAt": "ISO-8601",
  "site": { ...Site... }
}
```

### Site JSON (v1)

Fields include existing + new:
- `name`, `tagline`, `domain`, `theme`, `products`
- `affiliateDisclosure`
- `affiliateProfile`
- `affiliateProviders`

**Text fields:**
- Support `String` OR `String[]` in templates
- Project stores resolved `String` for UI clarity (recommended)

---

## 9) Technical Requirements

### macOS 11 compatibility
- No NavigationSplitView
- Use NavigationView + List sidebar style or custom layout

### File Storage
- Use `FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)`
- Create `WebMakr/Projects` and `WebMakr/Templates`

### Error handling
- JSON decoding errors show a user-friendly message with exact field if possible.

---

## 10) Success Metrics

| Metric | Target |
|--------|--------|
| Time to create a new 4-product site from template | < 60 seconds |
| % of sites using template import vs manual | > 80% |
| Reduction in manual editing clicks | > 70% |

---

## 11) Phased Delivery Plan

| Phase | Scope |
|-------|-------|
| **Phase 1 (must-have)** | Projects + File menu Import/Export + migration |
| **Phase 2** | Template library + New Project from Template |
| **Phase 3** | Affiliate profile + provider-agnostic link builder + defaults/toggles |
| **Phase 4** | Seeded uniqueness for tagline + shortDescription |
| **Phase 5** | iCloud mobile edit helper actions |

---

## 12) Open Items (safe defaults if unanswered)

### LemonSqueezy link pattern
Default to `query_param` provider with param `"aff"` and UTMs. If later LemonSqueezy uses a different pattern, update provider config only.

### Partner affiliate programs
Default OFF for partner tracking. Allow users to enable per program/product.

---

## Immediate Next Step

**"Implement Phase 1 + Phase 2 exactly as written, then Phase 3 with provider-agnostic link builder. LemonSqueezy is config, not hardcoded."**

---

## Deliverables (Optional)

- [ ] Complete MacDiskFull template JSON (with variant pools)
- [ ] Safe curated variant pack (20 taglines, 20 short descriptions)
