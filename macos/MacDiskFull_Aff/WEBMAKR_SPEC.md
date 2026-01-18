# WebMakr.app

## Native Website Builder - Product Specification

**Version:** 1.0  
**Last Updated:** January 18, 2026  
**Publisher:** funsoftware.cc

---

## 🎯 Product Overview

| | |
|---|---|
| **Name** | WebMakr.app |
| **Tagline** | Build Beautiful Websites. No Code Required. |
| **Category** | Productivity / Website Builder |
| **License Model** | One-time purchase (no subscription) |
| **Business Model** | Freemium + Paid upgrades |

### Vision Statement

WebMakr empowers everyday people to create professional websites without coding knowledge or expensive monthly subscriptions. Designed for budget-conscious users, affiliate marketers, and small business owners—especially in developing countries where older hardware is common.

---

## 🌐 Platform Strategy

### Desktop (Full Experience)

| Platform | Framework | Min Version | Status |
|----------|-----------|-------------|--------|
| **macOS** | SwiftUI | 11.0 (Big Sur) | ✅ v1.0 |
| **Windows** | .NET MAUI or Electron | Windows 10+ | 🔜 v1.5 |

**Desktop Features:**
- Full site creation & editing
- AI-powered content generation (BYOK)
- Live preview
- Static site generation
- One-click deployment (rsync, FTP, SFTP)
- Export/import site configurations

### Mobile (Maintenance & Quick Edits)

| Platform | Framework | Min Version | Status |
|----------|-----------|-------------|--------|
| **iOS/iPhone** | SwiftUI | iOS 15+ | 🔜 v2.0 |
| **Android** | Kotlin/Jetpack Compose | Android 10+ | 🔜 v2.0 |

**Mobile Features (Lighter Experience):**
- View site status & analytics
- Quick content edits (text, prices, descriptions)
- Product on/off toggles
- Push notifications for site issues
- AI chat for content ideas
- Publish updates to live site
- **NOT included:** Full site generation, theme editing, complex layouts

### Sync Strategy

| Feature | Desktop | Mobile |
|---------|---------|--------|
| Site data sync | ✅ Export/Import JSON | ✅ Cloud sync |
| AI Assistant | ✅ Full | ✅ Chat only |
| Preview | ✅ Full WebView | ✅ Simplified |
| Generate site | ✅ Full HTML/CSS | ❌ Not supported |
| Deploy | ✅ rsync/FTP/SFTP | ✅ Quick publish |
| Offline mode | ✅ Full | ✅ Read + queue edits |

---

## 👥 Target Users

| Audience | Primary Need | Device |
|----------|--------------|--------|
| Affiliate Marketers | Product comparison sites | Desktop |
| Small Business Owners | Landing pages, product showcases | Desktop + Mobile |
| Content Creators | Portfolio sites, link-in-bio pages | Desktop + Mobile |
| Budget-Conscious Users | Avoid monthly website builder fees | Desktop |
| Developing Countries | Business-in-a-box on older hardware | Desktop |
| On-the-go Managers | Quick updates from phone | Mobile |

---

## ✨ Core Features

### 1. Site Configuration
- Site name, tagline, domain
- Logo & favicon upload
- Theme colors (primary, secondary, accent)
- Dark/light mode toggle
- Custom CSS support

### 2. Site Persona & Voice
- Owner avatar (personal or brand voice)
- Site angle/positioning
- Target audience definition
- Tone of voice options:
  - Friendly & Approachable
  - Professional & Authoritative
  - Casual & Conversational
  - Technical & Detailed
  - Enthusiastic & Energetic
  - Trusted Advisor
- Core values & messaging
- Preferred phrases / words to avoid
- **AI automatically uses persona context**

### 3. Product Management
- Unlimited products
- Product types:
  - Own Product (highlight)
  - Amazon Affiliate
  - Other Affiliate
  - Competitor (for comparison)
- Categories: Software, Hardware, Storage, Accessories, Services
- Pricing: One-time, Monthly, Yearly, Free
- 5-star ratings
- Pros & cons lists
- Feature comparison matrix
- Featured/Recommended badges
- Drag-to-reorder

### 4. Page Management
- Page types:
  - Home
  - Comparison
  - Review
  - Features
  - Download
  - Pricing
  - Blog Post
  - About
  - Contact
  - Support
  - Legal
- Markdown/HTML content editor
- Published/Draft status
- Navigation visibility toggle
- Per-page SEO settings

### 5. Content Blocks
- Hero section with CTAs
- Trust/benefit cards
- Customer testimonials
- FAQ with categories
- Pricing tiers
- Auto-generated comparison tables

### 6. SEO & Analytics
- Meta description & keywords
- Open Graph settings
- Twitter Card settings
- Canonical URLs
- Google Analytics
- Google Tag Manager
- Facebook Pixel
- Indexing control

### 7. Navigation & Footer
- Configurable header navigation
- Multi-column footer
- Social media links:
  - Twitter/X, Facebook, Instagram
  - YouTube, TikTok, LinkedIn
  - Reddit, GitHub, Threads, Bluesky
- Affiliate disclosure (FTC compliant)

---

## 🤖 AI Assistant (BYOK - Bring Your Own Key)

### Supported Providers

| Provider | Models | API Key Required |
|----------|--------|------------------|
| **OpenAI** | GPT-4o, GPT-4o-mini, GPT-4-turbo, GPT-3.5-turbo | Yes |
| **OpenRouter** | 100+ models (GPT, Claude, Gemini, Llama) | Yes |
| **Anthropic** | Claude 3.5 Sonnet, Claude 3 Opus, Claude 3 Haiku | Yes |
| **Ollama** | Llama 3.2, Mistral, CodeLlama, Phi3 | No (local) |

### AI Features

| Feature | Desktop | Mobile |
|---------|---------|--------|
| Persona-aware generation | ✅ | ✅ |
| Quick action templates | ✅ | ✅ |
| Custom prompts | ✅ | ✅ |
| Product description writer | ✅ | ✅ |
| SEO meta generator | ✅ | ✅ |
| Comparison article intros | ✅ | ❌ |
| Blog outline generator | ✅ | ❌ |
| Affiliate disclosure writer | ✅ | ✅ |

### Template Categories
1. **Content Writing** - Blog outlines, disclosures
2. **SEO Optimization** - Meta descriptions, keywords
3. **Product Descriptions** - Compelling product copy
4. **Comparisons** - Article intros, summaries

---

## 🚀 Deployment

### Desktop Deployment Options

| Method | Description | Status |
|--------|-------------|--------|
| **rsync** | SSH-based sync (recommended) | ✅ |
| **scp** | Secure copy | ✅ |
| **SFTP** | Secure FTP | ✅ |
| **FTP** | Standard FTP | 🔜 |
| **Local** | Copy to folder | ✅ |
| **Git** | Push to repo | 🔜 v1.2 |

### Environment Management
- Multiple environments (Dev, Staging, Production)
- Per-environment settings
- Last deployment tracking
- Real-time deployment logs

### Mobile Quick Publish
- One-tap publish to production
- Status notifications
- Rollback capability (future)

---

## 💾 Data Management

| Feature | Description |
|---------|-------------|
| Auto-save | Changes saved automatically |
| Export Config | Full site as JSON file |
| Import Config | Load site from JSON |
| Local Storage | macOS: UserDefaults, Windows: AppData |
| Cloud Sync | Optional (future) for mobile |
| Offline Mode | Full offline capability |

---

## 🎨 Generated Website

### Output Format
- Pure static HTML + CSS
- No JavaScript dependencies (basic version)
- Mobile-responsive design
- Modern CSS (flexbox, grid, variables)
- SEO-optimized semantic HTML

### Generated Files
```
output/
├── index.html              # Home page
├── style.css               # All styles
├── review/
│   ├── product-1.html      # Product review pages
│   └── product-2.html
├── about.html              # Content pages
├── privacy.html
├── contact.html
└── assets/
    └── images/             # Uploaded images
```

### Design Features
- Modern dark theme (default)
- Gradient accents
- Glassmorphism effects
- Smooth hover animations
- Mobile-first responsive
- Custom theme support

---

## 🔧 Technical Specifications

### macOS App

| Spec | Value |
|------|-------|
| Language | Swift 5.5+ |
| Framework | SwiftUI |
| Min macOS | 11.0 (Big Sur) |
| Architecture | Universal (Intel + Apple Silicon) |
| Sandbox | App Sandbox compatible |
| Notarization | Yes |
| Dependencies | None (pure Apple frameworks) |

### Windows App (Planned)

| Spec | Value |
|------|-------|
| Framework | .NET MAUI or Electron |
| Min Windows | Windows 10 (build 1903+) |
| Architecture | x64 + ARM64 |

### iOS App (Planned)

| Spec | Value |
|------|-------|
| Language | Swift |
| Framework | SwiftUI |
| Min iOS | iOS 15+ |
| Features | Maintenance mode |

### Android App (Planned)

| Spec | Value |
|------|-------|
| Language | Kotlin |
| Framework | Jetpack Compose |
| Min Android | Android 10 (API 29) |
| Features | Maintenance mode |

---

## 📁 Project Structure (macOS)

```
WebMakr.app/
├── Models/
│   ├── Site.swift              # Main site configuration
│   ├── Product.swift           # Product data model
│   ├── SitePersona.swift       # Persona, deployment, content
│   ├── SiteStore.swift         # Observable data store
│   └── AISettings.swift        # AI provider configuration
├── Views/
│   ├── ContentView.swift       # Main navigation shell
│   ├── SiteSettingsView.swift  # Basic site settings
│   ├── PersonaView.swift       # Persona & voice editor
│   ├── ProductsView.swift      # Product management
│   ├── PagesView.swift         # Page management
│   ├── PreviewView.swift       # Live site preview
│   ├── GenerateView.swift      # Generate static site
│   ├── DeployView.swift        # Deploy to server
│   ├── AIAssistantView.swift   # AI content helper
│   └── SettingsView.swift      # App settings
├── Services/
│   ├── SiteGenerator.swift     # HTML/CSS generation
│   └── AIService.swift         # AI API integration
└── WebMakrApp.swift            # App entry point
```

---

## 💰 Pricing Model

### Desktop (macOS, Windows)

| Tier | Price | Devices | Updates |
|------|-------|---------|---------|
| **Starter** | Free | 1 | Limited features |
| **Personal** | $29.95 | 1 | Lifetime v1.x |
| **Family** | $49.95 | 5 | Lifetime v1.x |
| **Business** | $99.95 | Unlimited | Lifetime v1.x + priority support |

### Mobile (iOS, Android)

| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0 | View-only, limited edits |
| **Pro** | $4.99/mo or $29.95/yr | Full maintenance mode |

### Feature Comparison

| Feature | Free | Personal | Family | Business |
|---------|------|----------|--------|----------|
| Products | 3 | Unlimited | Unlimited | Unlimited |
| Pages | 5 | Unlimited | Unlimited | Unlimited |
| AI Assistant | ❌ | ✅ | ✅ | ✅ |
| Deploy | ❌ | ✅ | ✅ | ✅ |
| Custom CSS | ❌ | ✅ | ✅ | ✅ |
| Export/Import | ✅ | ✅ | ✅ | ✅ |
| Priority Support | ❌ | ❌ | ❌ | ✅ |

---

## 🗺️ Roadmap

### Phase 1: macOS Launch (v1.0) ✅
- [x] Core website builder
- [x] Product comparison engine
- [x] AI assistant (BYOK)
- [x] Site persona & voice
- [x] Static site generation
- [x] rsync deployment

### Phase 2: Enhancement (v1.1-1.2)
- [ ] Image asset manager
- [ ] Blog post templates
- [ ] Additional themes
- [ ] FTP with progress bar
- [ ] Git deployment
- [ ] Backup/restore

### Phase 3: Windows (v1.5)
- [ ] Windows desktop app
- [ ] Feature parity with macOS
- [ ] Windows-specific deployment options

### Phase 4: Mobile (v2.0)
- [ ] iOS maintenance app
- [ ] Android maintenance app
- [ ] Cloud sync between devices
- [ ] Push notifications
- [ ] Quick publish

### Phase 5: Ecosystem (v3.0)
- [ ] Template marketplace
- [ ] Plugin/extension system
- [ ] Multi-site management
- [ ] Team collaboration
- [ ] White-label option

---

## ☁️ WebMakr Cloud (Optional Add-On)

> **Philosophy:** WebMakr is native-first and works 100% offline. Cloud features are **optional add-ons** for users who want extra convenience. The core app never requires an account or internet connection.

### Why Not Full SaaS?

| SaaS Problem | Our Solution |
|--------------|--------------|
| Monthly subscription fatigue | One-time purchase for core features |
| Requires internet | Works 100% offline |
| Data on someone else's server | Data stays on your device |
| Competes with Wix/Squarespace | Unique native-first positioning |
| Server costs eat into margin | No per-user infrastructure cost |

### Optional Cloud Services (Future)

| Service | Price | Description |
|---------|-------|-------------|
| **WebMakr Sync** | $2/mo | Sync site data between Mac, Windows, iOS, Android |
| **Preview Links** | Free (7 days) | Share a temporary preview URL with clients |
| **WebMakr Hosting** | $5/mo | Host your site at `yoursite.webmakr.app` |
| **Custom Domain Hosting** | $8/mo | Host at your own domain with SSL |
| **Template Store** | Pay per template | Premium templates from designers |
| **Team Sync** | $10/mo | Collaborate with team members |

### Cloud Architecture (Planned)

```
┌─────────────────────────────────────────────────────────┐
│                    WebMakr Cloud                        │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Sync API   │  │   Hosting   │  │  Templates  │     │
│  │  (Optional) │  │  (Optional) │  │   (Store)   │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
├─────────────────────────────────────────────────────────┤
│                    Authentication                        │
│              (Only if using cloud features)             │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   Native Apps                           │
├──────────┬──────────┬──────────┬───────────────────────┤
│  macOS   │ Windows  │   iOS    │       Android         │
│  (Full)  │  (Full)  │ (Maint.) │       (Maint.)        │
├──────────┴──────────┴──────────┴───────────────────────┤
│              100% Offline Capable                       │
│           No Account Required for Core Use              │
└─────────────────────────────────────────────────────────┘
```

### Cloud Pricing Bundles

| Bundle | Price | Includes |
|--------|-------|----------|
| **Sync Only** | $2/mo or $20/yr | Multi-device sync |
| **Creator** | $8/mo or $79/yr | Sync + Hosting (custom domain) |
| **Team** | $19/mo or $179/yr | Sync + Hosting + Team (3 seats) |
| **Agency** | $49/mo or $479/yr | Everything + 10 sites + White-label |

### Revenue Model Comparison

| Model | Pros | Cons |
|-------|------|------|
| **One-time (Core)** | Simple, user-friendly | Lower LTV |
| **Optional Cloud** | Recurring revenue from power users | Requires infrastructure |
| **Hybrid (Our Choice)** | Best of both worlds | More complexity |

### Implementation Priority

1. **v3.0** - WebMakr Sync (device sync)
2. **v3.1** - Preview Links (shareable previews)
3. **v3.2** - WebMakr Hosting (subdomain)
4. **v3.5** - Custom Domain Hosting
5. **v4.0** - Template Marketplace
6. **v4.5** - Team Collaboration

---

## 🔐 Privacy & Security

| Aspect | Approach |
|--------|----------|
| **Data Storage** | All data stored locally on device |
| **AI Keys** | Stored locally, never transmitted to us |
| **Analytics** | Optional, privacy-respecting |
| **Network** | Only for AI calls (optional) and deployment |
| **No Account Required** | Use without creating an account |
| **No Cloud Dependency** | Works 100% offline |

---

## 📞 Support & Resources

| Resource | URL |
|----------|-----|
| Website | https://webmakr.app |
| Documentation | https://docs.webmakr.app |
| Support Email | support@webmakr.app |
| Twitter/X | @webmakrapp |
| Publisher | funsoftware.cc |

---

## 📜 Legal

- **EULA:** Standard software license
- **Privacy Policy:** No data collection by default
- **Affiliate Disclosure:** Built-in FTC-compliant generator
- **Trademarks:** WebMakr is a trademark of funsoftware.cc

---

## 🤝 Contributing

WebMakr is currently closed-source. For partnership inquiries:
- Email: partners@funsoftware.cc

---

*Built with ❤️ for creators who want beautiful websites without the monthly tax.*

**© 2026 funsoftware.cc. All rights reserved.**
