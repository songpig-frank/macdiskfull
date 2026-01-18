# WebMakr Roadmap

## Builder-Ready Specification with Acceptance Criteria

**Document Version:** 1.0  
**Created:** January 18, 2026  
**Status:** ACTIVE - Building Phase 1

---

# PHASE 1 — WebMakr v1.0 MVP

**Platform:** macOS only  
**Output:** Single comparison landing page  
**Timeline:** 1-2 weeks  
**Price:** $29.95 (watermark in free trial)

> **Goal:** Ship a polished, paid native app that generates a single comparison landing page.

---

## 1. App Shell + Navigation (4 Screens)

Create the main app window with sidebar navigation containing exactly 4 sections.

### Screens

| Screen | Icon | Purpose |
|--------|------|---------|
| Site Settings | `gearshape` | Basic site configuration |
| Products | `cube.box` | Manage comparison products |
| Preview | `eye` | Live preview of generated site |
| Generate | `arrow.down.doc` | Export to folder |

### Acceptance Criteria

- [ ] App launches without crash on macOS 11.0+
- [ ] Sidebar shows exactly 4 items
- [ ] Clicking each sidebar item shows correct view
- [ ] App opens with preloaded example site (MacDiskFull)
- [ ] User can navigate between all 4 screens
- [ ] Window remembers size on relaunch
- [ ] Minimum window size is enforced (900x600)

---

## 2. Data Model (Minimal)

### Site Model

```swift
struct Site {
    var name: String              // "MacDiskFull.com"
    var tagline: String           // "Is your Mac disk full?"
    var domain: String            // "macdiskfull.com" (display only)
    var primaryColor: String      // "#9333ea" (hex)
    var products: [Product]
    var affiliateDisclosure: String
}
```

### Product Model

```swift
struct Product {
    var id: UUID
    var name: String              // "GetDiskSpace"
    var description: String       // Short description
    var priceText: String         // "$19.99" or "$89/year"
    var rating: Int               // 1-5
    var affiliateURL: String      // Full URL
    var type: ProductType         // .ownProduct, .affiliate, .competitor
    var isRecommended: Bool       // Shows badge
    var pros: [String]            // ["Fast", "Privacy-first"]
    var cons: [String]            // ["No free tier"]
    var sortOrder: Int
}
```

### Acceptance Criteria

- [ ] Site data persists between app launches (UserDefaults)
- [ ] Can create new product
- [ ] Can edit existing product
- [ ] Can delete product (with confirmation)
- [ ] Can drag-reorder products
- [ ] Reorder persists after restart
- [ ] Preloaded example contains 3+ products
- [ ] All product fields save correctly

---

## 3. Site Settings View

Simple form for basic site configuration.

### Fields

| Field | Type | Required |
|-------|------|----------|
| Site Name | TextField | Yes |
| Tagline | TextField | Yes |
| Domain | TextField | No |
| Primary Color | ColorPicker | Yes |
| Affiliate Disclosure | TextEditor | Yes (has default) |

### Acceptance Criteria

- [ ] All fields display current values
- [ ] Changes save automatically (or on blur)
- [ ] Color picker works and shows hex value
- [ ] Domain field accepts any text (display only)
- [ ] Affiliate disclosure has sensible default
- [ ] Empty state shows placeholder text

---

## 4. Products View

Split view: product list on left, editor on right.

### List Features

- Product name
- Rating (stars)
- Recommended badge (if applicable)
- Drag handle for reorder
- Add button (+)
- Delete button (-)

### Editor Features

- All Product model fields
- Pros/Cons as editable lists (add/remove items)
- Product type picker
- Recommended toggle

### Acceptance Criteria

- [ ] List shows all products in sort order
- [ ] Selecting product shows editor
- [ ] Can add new product (appears at bottom)
- [ ] Can delete product (asks confirmation)
- [ ] Can drag to reorder
- [ ] Recommended badge shows in list
- [ ] Rating shows as stars in list
- [ ] Pros list: can add/remove items
- [ ] Cons list: can add/remove items
- [ ] Empty state: "No products yet — add one"
- [ ] Editor disables when no product selected

---

## 5. Generator v1 (Single Page Output)

Generate a complete, self-contained website folder.

### Output Structure

```
output-folder/
├── index.html          # Main comparison page
├── style.css           # All styles
├── robots.txt          # SEO: allow all
├── sitemap.xml         # SEO: homepage only (if domain set)
└── assets/
    ├── og-image.png    # Default OG image (placeholder)
    └── favicon.png     # Default favicon (placeholder)
```

### index.html Sections

1. **Header** - Site name as logo
2. **Hero** - Tagline + "See Comparison" CTA button (anchor to table)
3. **Featured Product** - Only if a product has `isRecommended = true`
4. **Comparison Table** - All products with: name, rating, price, pros, cons, link
5. **Footer** - Copyright + affiliate disclosure

### Acceptance Criteria

- [ ] Generates all files listed above
- [ ] index.html opens correctly in Safari/Chrome/Firefox
- [ ] All internal links work (anchors)
- [ ] All affiliate links open in new tab
- [ ] Table is horizontally scrollable on mobile
- [ ] Footer shows affiliate disclosure
- [ ] Featured product section only appears if one is recommended
- [ ] Products appear in correct sort order
- [ ] Output folder is self-contained (no external dependencies)

---

## 6. Tiny SEO (MVP-Friendly)

Automatic SEO without user configuration.

### Generated in `<head>`

```html
<title>{SiteName} – {Tagline}</title>
<meta name="description" content="{Tagline}. Compare the best tools.">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="canonical" href="https://{domain}/">  <!-- only if domain set -->
<link rel="icon" href="assets/favicon.png">

<!-- Open Graph -->
<meta property="og:title" content="{SiteName}">
<meta property="og:description" content="{Tagline}">
<meta property="og:image" content="assets/og-image.png">
<meta property="og:type" content="website">
<meta property="og:url" content="https://{domain}/">  <!-- only if domain set -->

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{SiteName}">
<meta name="twitter:description" content="{Tagline}">
<meta name="twitter:image" content="assets/og-image.png">
```

### robots.txt

```
User-agent: *
Allow: /
Sitemap: https://{domain}/sitemap.xml
```

### sitemap.xml (only if domain is set)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://{domain}/</loc>
    <lastmod>{today's date}</lastmod>
    <priority>1.0</priority>
  </url>
</urlset>
```

### Acceptance Criteria

- [ ] `<title>` contains site name and tagline
- [ ] Meta description is auto-generated
- [ ] Viewport meta is present
- [ ] Favicon link is correct
- [ ] OG tags are present
- [ ] Twitter card tags are present
- [ ] If domain exists: canonical URL is correct
- [ ] If domain exists: OG url is correct
- [ ] If domain missing: canonical/og:url are omitted (no broken URLs)
- [ ] robots.txt exists and allows all
- [ ] If domain exists: sitemap.xml is generated
- [ ] If domain missing: sitemap.xml is skipped

---

## 7. Preview View (WebKit)

Live preview of the generated site.

### Features

- WebView displaying generated HTML
- Refresh button
- Responsive toggle (Desktop / Mobile widths)

### Acceptance Criteria

- [ ] Preview loads generated HTML
- [ ] Refresh button regenerates and reloads
- [ ] Desktop view shows at ~1200px width
- [ ] Mobile view shows at ~375px width
- [ ] Toggle switches between Desktop/Mobile
- [ ] Scrolling works
- [ ] Links are clickable (open in browser)
- [ ] Preview updates after editing products (on refresh)

---

## 8. Generate View

Export the site to a user-chosen folder.

### Features

- Summary of what will be generated
- "Generate Site" button
- Folder picker (NSSavePanel)
- Progress/status message
- "Open Folder" button (after success)

### Acceptance Criteria

- [ ] Summary shows: site name, product count, files to generate
- [ ] Clicking "Generate" opens folder picker
- [ ] After selecting folder, files are written
- [ ] Success message appears with folder path
- [ ] Error message appears if generation fails
- [ ] "Open Folder" button reveals folder in Finder
- [ ] Can generate multiple times without issues
- [ ] Overwrites existing files in same folder

---

## 9. Generated CSS (Polish)

The generated `style.css` must be production-quality.

### Requirements

- Modern dark theme (purple/dark gradient)
- Mobile-first responsive
- Comparison table scrolls horizontally on mobile (THIS IS CRUCIAL)
- Button styles are consistent
- Hover effects on interactive elements
- Clean typography (system fonts or Google Fonts)
- Glassmorphism or modern styling touches

### Acceptance Criteria

- [ ] Site looks professional on desktop (1200px+)
- [ ] Site looks professional on mobile (375px)
- [ ] Table scrolls horizontally on small screens
- [ ] Buttons have hover states
- [ ] Links are clearly styled
- [ ] Featured product block stands out visually
- [ ] Recommended badge is prominent
- [ ] Rating stars are clear
- [ ] Footer is appropriately styled
- [ ] No horizontal page scroll (only table scrolls)

---

## 10. Release Checklist (macOS)

### App Polish

- [ ] App icon designed and included
- [ ] About window with version info
- [ ] App name is "WebMakr"
- [ ] Bundle ID is `cc.funsoftware.webmakr`
- [ ] Version is 1.0.0

### Distribution

- [ ] Builds for Intel + Apple Silicon (Universal)
- [ ] Code signing configured
- [ ] Notarization plan (or disabled for dev testing)
- [ ] DMG or ZIP for distribution

### Trial/Paid Gating

- [ ] Free trial has watermark in generated footer
- [ ] Paid version removes watermark
- [ ] License check mechanism (or honor system for v1)

### Final Test

- [ ] A stranger can generate a working affiliate comparison page in <10 minutes
- [ ] Output site works when uploaded to any static host
- [ ] Mobile layout is usable

---

## Phase 1 Dogfood Test

> **Do NOT try to build FunSoftware partner portal with v1.0** — v1.0 is single-page only.

### Dogfood With:

1. **MacDiskFull affiliate site**
   - GetDiskSpace vs CleanMyMac vs DaisyDisk vs OmniDiskSweeper
   - Generate with WebMakr
   - Upload to any host manually

2. **Validate:**
   - [ ] Mobile table scrolls correctly
   - [ ] Affiliate links work
   - [ ] OG preview works when shared on Twitter/Discord
   - [ ] Site loads fast
   - [ ] Site looks professional

**This validates the core promise:** *"Native tool → produces a real affiliate page."*

---

# PHASE 2 — WebMakr v1.1

**Goal:** Add multi-page + blocks so we can build the FunSoftware partner site.

---

## 2.1 Multi-Page Support

### Features

- [ ] Page list in sidebar
- [ ] Add page (types: Home, About, Contact, Rules, FAQ, Blog Index, Blog Post)
- [ ] Page editor (title, slug, content)
- [ ] Published/Draft toggle
- [ ] Show in Navigation toggle
- [ ] Navigation auto-builds from pages

### Acceptance Criteria

- [ ] Can create multiple pages
- [ ] Each page generates as `{slug}.html`
- [ ] Navigation shows all "Show in Nav" pages
- [ ] Blog posts generate in `/blog/{slug}.html`
- [ ] Blog index page lists all posts

---

## 2.2 Content Blocks (Minimum Set)

| Block | Description |
|-------|-------------|
| Hero | Headline, subheadline, CTA buttons |
| Benefits Cards | 3-4 cards with icon/title/text |
| Alternating Media Rows | Image left/right on desktop, stacked on mobile |
| FAQ | Accordion-style Q&A |
| CTA Banner | Full-width call to action |
| YouTube Embed | Responsive video embed |
| Related Links | List of internal links |
| Comparison Table | From v1.0 |

### Acceptance Criteria

- [ ] Each block type can be added to any page
- [ ] Blocks can be reordered
- [ ] Blocks render correctly on desktop
- [ ] Blocks render correctly on mobile
- [ ] YouTube embeds are responsive

---

## 2.3 Full SEO Outputs

- [ ] sitemap.xml includes all published pages + blog posts
- [ ] robots.txt points to sitemap
- [ ] Per-page title/description/OG can be customized
- [ ] Blog posts have proper meta tags

---

## 2.4 Internal Linking (Non-AI)

- [ ] Blog posts include "Related" section
- [ ] 1 chosen "money page" link (configurable, defaults to Home)
- [ ] 2 related posts (same category/tag)

---

## Phase 2 Dogfood Test

### Build:

**FunSoftware Partner Landing Site**

Pages:
- Home
- Apply to Partner Program
- Partner Rules
- Promo Kit
- FAQ
- Blog (with 2-3 posts)

Blocks used:
- Hero
- Alternating media rows ("How it works")
- YouTube embed (welcome video)
- FAQ block
- Comparison table ("Partner vs Non-partner benefits")
- CTA Banner

### Validate:

- [ ] sitemap.xml contains all pages and posts
- [ ] OG tags show correct preview when shared
- [ ] Mobile layout is clean
- [ ] Navigation works on all pages
- [ ] Blog index lists all posts

---

# PHASE 3 — WebMakr v1.2

**Goal:** Wire in FunSoftware "spine" without bloating the core app.

---

## 3.1 Affiliate Mode (Manifest-Driven)

- [ ] Sign-in with token paste (or account login)
- [ ] Fetch manifest JSON from FunSoftware API
- [ ] Shows only approved offers
- [ ] One-click import: assets, descriptions, affiliate links
- [ ] Offers displayed in dedicated "Offers" tab

---

## 3.2 Share Kit Export

For each page/post, generate:

- [ ] `/share-kit/{page-slug}/`
- [ ] `twitter.txt` - Tweet text + link
- [ ] `facebook.txt` - FB post text
- [ ] `instagram.txt` - IG caption (no link in body)
- [ ] `tiktok.txt` - TikTok caption
- [ ] `og-image.png` - Copy of OG image

---

## 3.3 WebMakr Cloud (Optional)

Keep in spec but do NOT block v1.0/v1.1 shipping.

| Service | Status |
|---------|--------|
| WebMakr Sync | Future |
| Preview Links | Future |
| Hosting | Future |
| Templates Store | Future |

---

# Summary: What To Build Now

## Immediate Priority (v1.0 MVP)

```
1. Simplify to 4-screen sidebar
2. Simplify Site model (remove persona, pages, etc.)
3. Perfect ProductsView (CRUD, drag, pros/cons)
4. Build SiteGenerator (single index.html + style.css)
5. Add Tiny SEO (meta tags, robots.txt, sitemap.xml)
6. PreviewView with responsive toggle
7. GenerateView with folder export
8. Polish generated CSS (mobile table scroll!)
9. App icon + About
10. Test with MacDiskFull site
```

## Do NOT Build Yet

- AI Assistant
- Site Persona
- Multiple pages
- Deployment (rsync)
- Reviews/FAQ/Pricing blocks
- Custom CSS input
- SEO fields (auto-generated is fine)
- Export/Import JSON
- Windows/iOS/Android

---

# Builder Sign-Off

By proceeding with this spec, the builder agrees to:

1. Build exactly what is specified in Phase 1
2. Not add features beyond Phase 1 scope
3. Get all acceptance criteria checked before moving to Phase 2
4. Dogfood with MacDiskFull before declaring "done"

---

**Document Location:** `/Users/nc/macdiskfull_affiliate/macos/MacDiskFull_Aff/WEBMAKR_ROADMAP.md`

**Start Date:** January 18, 2026  
**Target Completion (Phase 1):** February 1, 2026

---

*Ship it. Get feedback. Iterate.*
