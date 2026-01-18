# WebMakr MVP

## Minimum Viable Product Specification

**Target:** Ship in 2-3 weeks  
**Platform:** macOS only (v1.0)  
**Goal:** Validate core value proposition with real users

---

## 🎯 MVP Philosophy

> **"What is the smallest thing we can ship that proves people will pay for a native website builder?"**

The MVP should:
1. Let users create a simple comparison/affiliate website
2. Generate working static HTML files
3. Be usable without reading documentation
4. Look polished enough to charge $29 for

---

## ✅ MVP Features (Must Have)

### 1. Site Settings (Basic)
- [ ] Site name
- [ ] Tagline
- [ ] Domain (for display only)
- [ ] Primary color picker
- [ ] Dark mode only (skip light mode for MVP)

### 2. Products (Core Feature)
- [ ] Add/edit/delete products
- [ ] Product name
- [ ] Short description
- [ ] Price (text field)
- [ ] Rating (1-5 stars)
- [ ] Affiliate URL
- [ ] Product type: Own Product, Affiliate, Competitor
- [ ] "Recommended" badge toggle
- [ ] Pros list (simple text array)
- [ ] Cons list (simple text array)
- [ ] Drag to reorder

### 3. Preview
- [ ] Live WebView preview of generated site
- [ ] Refresh button
- [ ] Basic responsive preview

### 4. Generate Site
- [ ] Generate static HTML + CSS
- [ ] Choose output folder (NSSavePanel)
- [ ] Open folder after generation
- [ ] Status message (success/error)

### 5. Generated Output
- [ ] Single `index.html` with:
  - Hero section (site name, tagline)
  - Comparison table (all products)
  - Featured product highlight
  - Basic footer with affiliate disclosure
- [ ] Single `style.css` with:
  - Modern dark theme
  - Mobile responsive
  - Comparison table styling

---

## ❌ NOT in MVP (Cut Ruthlessly)

| Feature | Why Cut | Add In |
|---------|---------|--------|
| AI Assistant | Requires API setup, complexity | v1.1 |
| Site Persona | Nice-to-have, not essential | v1.1 |
| Multiple Pages | One page is enough to validate | v1.1 |
| Page Editor | No custom pages in MVP | v1.1 |
| Deployment (rsync) | Users can FTP manually | v1.2 |
| Product Features matrix | Pros/cons is enough | v1.1 |
| Reviews/Testimonials | Not essential for comparison sites | v1.2 |
| FAQ section | Not essential | v1.2 |
| Pricing Tiers | Not essential for affiliate sites | v1.2 |
| Trust Cards | Nice-to-have | v1.1 |
| Custom CSS | Power user feature | v1.2 |
| SEO fields | Basic meta is auto-generated | v1.1 |
| Social Links | Footer link is enough | v1.1 |
| Export/Import JSON | Can add later | v1.1 |
| Windows/Mobile | macOS first | v1.5+ |

---

## 📱 MVP User Flow

```
┌─────────────────────────────────────────────────────────┐
│  1. OPEN APP                                            │
│     → See sample site pre-loaded (MacDiskFull example)  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  2. EDIT SITE SETTINGS                                  │
│     → Change name, tagline, color                       │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  3. MANAGE PRODUCTS                                     │
│     → Add/edit products, set recommended, add pros/cons │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  4. PREVIEW                                             │
│     → See live preview of comparison site               │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  5. GENERATE                                            │
│     → Export to folder → Upload via FTP/hosting panel   │
└─────────────────────────────────────────────────────────┘
```

---

## 🖥️ MVP Sidebar (Simplified)

```
┌──────────────────────┐
│  📍 Site Settings    │  ← Basic settings
│  📦 Products         │  ← Core feature
│  👁️ Preview          │  ← See result
│  📤 Generate         │  ← Export HTML
└──────────────────────┘
```

That's it. 4 sections.

---

## 🎨 MVP Generated Website

### Single Page Output: `index.html`

```
┌─────────────────────────────────────────────────────────┐
│  HEADER                                                 │
│  Logo/Site Name                                         │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  HERO                                                   │
│  "Is Your Mac Disk Full?"                              │
│  Compare the best disk cleaning tools                   │
│  [See Comparison ↓]                                     │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  FEATURED PRODUCT (if one is marked recommended)        │
│  ⭐ Our Top Pick: GetDiskSpace                         │
│  Rating: ★★★★★                                         │
│  Price: $19.99                                          │
│  [Visit Site →]                                         │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  COMPARISON TABLE                                       │
│  ┌────────┬───────┬───────┬────────┬────────┐         │
│  │Product │Rating │ Price │  Pros  │  Cons  │  Link   │
│  ├────────┼───────┼───────┼────────┼────────┤         │
│  │GetDisk │ ★★★★★ │$19.99 │ Fast   │ None   │ [Get]   │
│  │CleanMy │ ★★★★☆ │$89/yr │ UI     │ Pricey │ [Get]   │
│  │DaisyD  │ ★★★☆☆ │ Free  │ Free   │ Limited│ [Get]   │
│  └────────┴───────┴───────┴────────┴────────┴─────────┘│
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│  FOOTER                                                 │
│  © 2026 SiteName                                       │
│  Affiliate Disclosure: We may earn commissions...      │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 MVP File Structure

```
WebMakr.app/
├── Models/
│   ├── Site.swift           # Simplified (no persona, no pages)
│   ├── Product.swift        # Full (already done)
│   └── SiteStore.swift      # Simplified
├── Views/
│   ├── ContentView.swift    # 4-section sidebar
│   ├── SiteSettingsView.swift  # Name, tagline, color only
│   ├── ProductsView.swift   # Full (already done)
│   ├── PreviewView.swift    # Simplified
│   └── GenerateView.swift   # Simplified (no deploy)
├── Services/
│   └── SiteGenerator.swift  # Generates single index.html
└── WebMakrApp.swift
```

**Total files: ~10**

---

## ⏱️ MVP Development Timeline

| Day | Task | Hours |
|-----|------|-------|
| 1 | Simplify Site model, remove unused fields | 2h |
| 1 | Simplify ContentView to 4 sections | 1h |
| 1 | Simplify SiteSettingsView (name, tagline, color) | 2h |
| 2 | Ensure ProductsView works perfectly | 3h |
| 2 | Build simple comparison table generator | 3h |
| 3 | Build PreviewView with WebKit | 3h |
| 3 | Build GenerateView with folder export | 2h |
| 4 | Polish generated HTML/CSS output | 4h |
| 5 | Testing, bug fixes, polish | 4h |
| 6 | App icon, About screen, final touches | 2h |

**Total: ~26 hours = 1 person, 1 week focused work**

---

## 💰 MVP Pricing

| Tier | Price | What You Get |
|------|-------|--------------|
| **Free Trial** | $0 | Full app, watermark on generated sites |
| **Personal** | $29.95 | Remove watermark, lifetime v1.x updates |

That's it. One paid tier. Simple.

---

## 🚀 MVP Launch Checklist

- [ ] App works on macOS 11.0+
- [ ] Sample site pre-loaded
- [ ] Can add/edit/delete products
- [ ] Preview shows real output
- [ ] Generate creates working HTML
- [ ] Generated site looks professional
- [ ] App icon designed
- [ ] Notarized for macOS
- [ ] Landing page at webmakr.app
- [ ] Payment via Gumroad or LemonSqueezy
- [ ] Post on Product Hunt / Twitter / Reddit

---

## 🎯 MVP Success Metrics

| Metric | Target |
|--------|--------|
| Downloads (free trial) | 100 in first week |
| Paid conversions | 10 in first month |
| User feedback | 5 detailed responses |
| Refund rate | < 10% |

---

## 📝 What We Learn From MVP

1. **Do people want a native website builder?**
2. **Is $29.95 the right price point?**
3. **What features do they ask for first?**
4. **Who is our actual customer?** (affiliate marketers? small biz? other?)

Based on answers, we decide:
- Add AI features?
- Add deployment?
- Build for Windows?
- Raise/lower price?

---

## Summary: MVP = 4 Screens

| Screen | Purpose |
|--------|---------|
| **Site Settings** | Name, tagline, color |
| **Products** | Add/edit comparison products |
| **Preview** | See the generated site |
| **Generate** | Export HTML to folder |

**Ship this. Get feedback. Iterate.**

---

*"If you're not embarrassed by the first version of your product, you've launched too late." — Reid Hoffman*
