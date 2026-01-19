//
//  Site.swift
//  WebMakr
//
//  MVP Site Model - Simplified for single-page comparison site
//  Compatible with macOS 11.0 (Big Sur) and later
//

import Foundation
import SwiftUI

/// MVP Theme - just primary color, dark mode only
struct SiteTheme: Codable {
    var primaryColor: String // Hex color
    
    init(primaryColor: String = "#9333ea") {
        self.primaryColor = primaryColor
    }
    
    static let purple = SiteTheme(primaryColor: "#9333ea")
    static let blue = SiteTheme(primaryColor: "#3b82f6")
    static let green = SiteTheme(primaryColor: "#22c55e")
}

/// Supported Affiliate Networks
enum AffiliateNetwork: String, Codable, CaseIterable, Identifiable {
    case custom = "Custom Link"
    case lemonSqueezy = "Lemon Squeezy"
    case impact = "Impact"
    case partnerStack = "PartnerStack"
    case amazon = "Amazon"
    
    var id: String { rawValue }
    
    var placeholder: String {
        switch self {
        case .custom: return "https://example.com"
        case .lemonSqueezy: return "shop-slug" // e.g., "macdiskfull"
        case .impact: return "mpid" // Media Partner ID
        case .partnerStack: return "key"
        case .amazon: return "ASIN"
        }
    }
}

/// Article Status for CMS workflow
enum ArticleStatus: String, Codable, CaseIterable {
    case draft = "Draft"
    case published = "Published"
    case archived = "Archived"
}

/// Blog Article Model
struct Article: Identifiable, Codable {
    var id: UUID
    var title: String
    var slug: String
    var summary: String
    var contentHTML: String // Basic HTML body
    var author: String
    var publishedDate: Date
    var heroImage: String
    
    // CMS Status
    var status: ArticleStatus = .draft
    var redirectURL: String? = nil // If archived, redirect to this URL
    
    // SEO & AI Analysis
    var seoScore: Int?         // 0-100
    var seoKeywords: [String]?
    var seoAnalysis: String?
    var seoRecommendations: [String]?
    var seoConflictResolution: String?
    
    init(id: UUID = UUID(), title: String, slug: String, summary: String, contentHTML: String, author: String = "Editorial Team", publishedDate: Date = Date(), heroImage: String = "assets/blog-hero.jpg", status: ArticleStatus = .draft, redirectURL: String? = nil, seoScore: Int? = nil, seoKeywords: [String]? = nil, seoAnalysis: String? = nil, seoRecommendations: [String]? = nil, seoConflictResolution: String? = nil) {
        self.id = id
        self.title = title
        self.slug = slug
        self.summary = summary
        self.contentHTML = contentHTML
        self.author = author
        self.publishedDate = publishedDate
        self.heroImage = heroImage
        self.status = status
        self.redirectURL = redirectURL
        self.seoScore = seoScore
        self.seoKeywords = seoKeywords
        self.seoAnalysis = seoAnalysis
        self.seoRecommendations = seoRecommendations
        self.seoConflictResolution = seoConflictResolution
    }
}

/// MVP Affiliate Settings
struct AffiliateSettings: Codable {
    var defaultAffiliateDisclosure: String
    var globalAffiliateIds: [String: String] // Network.rawValue -> Affiliate ID
    var defaultCampaign: String
    var geniusLinkTSID: String // For Amazon Localization
    
    init(
        defaultAffiliateDisclosure: String = "We may earn a commission when you buy through links on our site. This helps support our work and does not affect our reviews or recommendations.",
        globalAffiliateIds: [String: String] = [:],
        defaultCampaign: String = "",
        geniusLinkTSID: String = ""
    ) {
        self.defaultAffiliateDisclosure = defaultAffiliateDisclosure
        self.globalAffiliateIds = globalAffiliateIds
        self.defaultCampaign = defaultCampaign
        self.geniusLinkTSID = geniusLinkTSID
    }
}

/// MVP Site Configuration
struct Site: Identifiable, Codable {
    let id: UUID
    var name: String
    var tagline: String
    var domain: String           // For SEO canonical URLs (optional)
    var logoURL: String?         // Site logo image URL
    var faviconURL: String?      // Favicon image URL
    var theme: SiteTheme
    var affiliateSettings: AffiliateSettings
    var products: [Product]
    var articles: [Article] // New: Blog Articles
    var optimizationRules: String = "Focus on E-E-A-T (Experience, Expertise, Authoritativeness, and Trustworthiness). Prioritize answer targets for AI search."
    
    // Pro Features
    var usePrettyLinks: Bool
    var generateLegalPages: Bool
    var aiProvider: String = "OpenAI" // "OpenAI", "OpenRouter", "Anthropic", "Gemini", "Ollama"
    var aiModel: String = "gpt-4o"
    var openAIKey: String = ""
    var anthropicKey: String = ""
    var geminiKey: String = ""
    var ollamaURL: String = "http://localhost:11434"
    
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String = "My Comparison Site",
        tagline: String = "Compare the best options",
        domain: String = "",
        theme: SiteTheme = .purple,
        affiliateSettings: AffiliateSettings = AffiliateSettings(),
        products: [Product] = [],
        articles: [Article] = [],
        optimizationRules: String = "Focus on E-E-A-T (Experience, Expertise, Authoritativeness, and Trustworthiness). Prioritize answer targets for AI search.",
        usePrettyLinks: Bool = true,
        generateLegalPages: Bool = true,
        aiProvider: String = "OpenAI",
        aiModel: String = "gpt-4o",
        openAIKey: String = "",
        anthropicKey: String = "",
        geminiKey: String = "",
        ollamaURL: String = "http://localhost:11434",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.domain = domain
        self.theme = theme
        self.affiliateSettings = affiliateSettings
        self.products = products
        self.articles = articles
        self.optimizationRules = optimizationRules
        self.usePrettyLinks = usePrettyLinks
        self.generateLegalPages = generateLegalPages
        self.aiProvider = aiProvider
        self.aiModel = aiModel
        self.openAIKey = openAIKey
        self.anthropicKey = anthropicKey
        self.geminiKey = geminiKey
        self.ollamaURL = ollamaURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Sample Data

extension Site {
    /// Preloaded example site for MVP - a model affiliate comparison site
    static let sampleMacDiskFull = Site(
        name: "MacDiskFull.com",
        tagline: "Is your Mac startup disk almost full?",
        domain: "macdiskfull.com",
        theme: .purple,
        products: [
            Product(
                name: "GetDiskSpace",
                shortDescription: "Privacy-first Mac disk cleaner with innovative SpaceSwipe cleanup.",
                price: "$19.95",
                rating: 4.9,
                affiliateLink: "https://getdiskspace.com",
                productType: .ownProduct,  // This is YOUR product you're promoting
                isRecommended: true,
                pros: ["One-time purchase (no subscription)", "100% private - data stays on your Mac", "SpaceSwipe makes cleanup fun", "Native Apple Silicon support"],
                cons: ["No free version available"],
                sortOrder: 1
            ),
            Product(
                name: "CleanMyMac X",
                shortDescription: "Popular all-in-one Mac maintenance tool from MacPaw.",
                price: "$89/year",
                rating: 4.5,
                affiliateLink: "https://macpaw.com/cleanmymac",
                productType: .otherAffiliate,  // You earn commission promoting this
                isRecommended: false,
                pros: ["Well-known brand", "Many features", "Good user interface"],
                cons: ["Requires yearly subscription", "Expensive over time", "Sends usage data to servers"],
                sortOrder: 2
            ),
            Product(
                name: "DaisyDisk",
                shortDescription: "Visual disk analyzer with beautiful sunburst visualization.",
                price: "$9.99",
                rating: 4.3,
                affiliateLink: "https://daisydiskapp.com",
                productType: .otherAffiliate,
                isRecommended: false,
                pros: ["Affordable one-time price", "Beautiful visualization", "Quick disk scanning"],
                cons: ["Only shows disk usage", "No automatic cleanup", "Limited feature set"],
                sortOrder: 3
            ),
            Product(
                name: "OmniDiskSweeper",
                shortDescription: "Free, simple disk analyzer from The Omni Group.",
                price: "Free",
                rating: 3.8,
                affiliateLink: "https://www.omnigroup.com/more",
                productType: .competitor,  // Listed for comparison, not earning from this
                isRecommended: false,
                pros: ["Completely free", "Simple interface", "Trusted developer"],
                cons: ["Very basic features", "Outdated interface", "No cleanup automation"],
                sortOrder: 4
            )
        ],
        articles: [
            Article(
                title: "Mac Disk Full? Do This First (Fast Checklist That Works)",
                slug: "mac-disk-full-do-this-first",
                summary: "If your Mac says “Your disk is almost full,” don’t panic. Follow this checklist to reclaim space in 10–30 minutes without breaking macOS.",
                contentHTML: """
                    <p><em>Last updated: January 2026</em></p>
                    <p>If your Mac says “Your disk is almost full,” don’t panic and don’t start randomly deleting things. The fastest way to fix a full drive is to follow a short checklist in the right order—so you reclaim space quickly <em>without breaking anything important</em>.</p>
                    <p>This guide gives you a safe “do this first” process. Most people can free up space in 10–30 minutes, even if they’re not techy.</p>
                    <p><em>Disclosure: Some links may be affiliate links. If you buy through them, we may earn a commission at no extra cost to you.</em></p>
                    <hr>
                    <h2>The 60-second plan (do these in order)</h2>
                    <ol>
                    <li>Check what’s actually using space (built-in Storage view)</li>
                    <li>Empty Trash (and delete old installers)</li>
                    <li>Clear the biggest easy wins (Downloads, videos, DMGs, ZIPs)</li>
                    <li>Find and remove large files <em>safely</em> (preview-first)</li>
                    <li>If you’re still tight: deal with “System Data” and pro-app caches</li>
                    <li>Move large libraries to an external drive (optional)</li>
                    </ol>
                    <p>Then, if you want to make this easier next time, use a <em>visual</em> disk cleanup tool that helps you spot the junk faster than Finder.</p>
                    <hr>
                    <h2>Step 1: Confirm how much space you actually have</h2>
                    <p>Before deleting anything, check your current free space so you know what “success” looks like.</p>
                    <h3>macOS Ventura / Sonoma / Sequoia (modern macOS)</h3>
                    <ol>
                    <li>Open <em>System Settings</em></li>
                    <li>Click <em>General</em></li>
                    <li>Click <em>Storage</em></li>
                    </ol>
                    <p>You’ll see categories like Applications, Documents, Photos, System Data, etc.</p>
                    <h3>Older macOS</h3>
                    <ol>
                    <li>Click the Apple menu</li>
                    <li>Choose <em>About This Mac</em></li>
                    <li>Click <em>Storage</em></li>
                    </ol>
                    <p><em>Goal:</em> If you can get back to at least <strong>15–25 GB free</strong>, your Mac will behave better (updates, swaps, performance).</p>
                    <hr>
                    <h2>Step 2: Empty Trash (and remove the “fake deletes”)</h2>
                    <p>This is obvious, but it matters: moving files to Trash doesn’t free space until you empty it.</p>
                    <ol>
                    <li>Right-click <em>Trash</em> (Dock)</li>
                    <li>Click <em>Empty Trash</em></li>
                    </ol>
                    <p>Now do this too (it’s the hidden “why is my disk still full?” issue):</p>
                    <h3>Delete big installers you don’t need</h3>
                    <p>Common space hogs:</p>
                    <ul>
                    <li><code>.dmg</code> installer files (apps you already installed)</li>
                    <li><code>.pkg</code> installers</li>
                    <li><code>.zip</code> archives</li>
                    <li>iOS firmware files you downloaded</li>
                    <li>old “Photos Library copy” files</li>
                    </ul>
                    <p>Where they usually live:</p>
                    <ul>
                    <li><em>Downloads</em></li>
                    <li><em>Desktop</em></li>
                    <li>random folders named “Installers”</li>
                    </ul>
                    <p><em>Tip:</em> If you see a DMG you installed weeks ago, you can usually delete it.</p>
                    <hr>
                    <h2>Step 3: Clear the biggest “easy win” folders first</h2>
                    <p>These are the places that fill up on almost every Mac:</p>
                    <h3>A) Downloads</h3>
                    <p>Open Finder → <em>Downloads</em>. Then sort by size:</p>
                    <ol>
                    <li>In Finder, open <em>Downloads</em></li>
                    <li>Click the “list view” icon (four lines)</li>
                    <li>Choose <em>View → Show View Options</em></li>
                    <li>Turn on <em>Calculate all sizes</em> (if available)</li>
                    <li>Click the <em>Size</em> column to sort</li>
                    </ol>
                    <p>Delete:</p>
                    <ul>
                    <li>old DMGs / ZIPs</li>
                    <li>videos you no longer need</li>
                    <li>duplicates (“file (1).zip”, “file (2).zip”)</li>
                    </ul>
                    <h3>B) Desktop</h3>
                    <p>People forget the Desktop counts as real storage. Remove:</p>
                    <ul>
                    <li>duplicate images</li>
                    <li>screen recordings</li>
                    <li>old work exports</li>
                    <li>long ZIPs and DMGs</li>
                    </ul>
                    <h3>C) Your Movies folder (especially screen recordings)</h3>
                    <p>Finder → <em>Movies</em>. Look for:</p>
                    <ul>
                    <li>Screen recordings</li>
                    <li>Old exports from video editors</li>
                    <li>Huge clips you already uploaded</li>
                    </ul>
                    <h3>D) Messages attachments (if you get lots of photos/videos)</h3>
                    <p>This can get huge. In Storage, look for “Messages” if it appears and review attachments.</p>
                    <hr>
                    <h2>Step 4: Find large files safely (without deleting system stuff)</h2>
                    <p>If your Mac is truly full, you need to locate the largest files and confirm what they are before deleting.</p>
                    <h3>The safe method (Finder search)</h3>
                    <ol>
                    <li>Open Finder</li>
                    <li>Press <code>Command + F</code></li>
                    <li>Set search to “This Mac”</li>
                    <li>Add a filter like <em>File Size is greater than 500 MB</em> (or 1 GB)</li>
                    </ol>
                    <p>Then review large items one by one.</p>
                    <p><em>What to delete safely:</em></p>
                    <ul>
                    <li>Old exported videos you don’t need</li>
                    <li>Duplicate downloads</li>
                    <li>Old installers (DMG/PKG)</li>
                    <li>ISO files</li>
                    <li>Old project exports you already backed up</li>
                    </ul>
                    <p><em>What NOT to delete if you’re not sure:</em></p>
                    <ul>
                    <li>Anything in <em>System</em> folders</li>
                    <li>Random folders you don’t recognize inside Library</li>
                    <li>Anything labeled as macOS-related</li>
                    </ul>
                    <p>If you’re unsure, move it to a “To Review” folder first instead of deleting.</p>
                    <hr>
                    <h2>Step 5: The big culprits most people miss</h2>
                    <p>These categories are where space mysteriously disappears.</p>
                    <h3>A) “System Data” is huge</h3>
                    <p>System Data includes caches, logs, app support files, and more. It’s not all “bad”—but it can grow out of control.</p>
                    <p>If System Data is huge:</p>
                    <ul>
                    <li>Restart your Mac (yes, really)</li>
                    <li>Empty Trash</li>
                    <li>Clear obvious app caches (see below)</li>
                    <li>Remove old iPhone backups (if you have them)</li>
                    <li>For creators: clear pro-app caches carefully</li>
                    </ul>
                    <h3>B) iPhone / iPad backups</h3>
                    <p>If you back up devices locally, backups can take 5–50 GB each.</p>
                    <p>Where to check: Finder → click your iPhone in the sidebar → Manage Backups (varies by macOS).</p>
                    <h3>C) Photo library and duplicates</h3>
                    <p>Photos can be massive. If you use iCloud Photos, your Mac may still store a lot locally.</p>
                    <p>A simple choice: If your library is huge and you trust iCloud, set Photos to <em>Optimize Mac Storage</em>.</p>
                    <h3>D) Pro apps (video and audio) cache files</h3>
                    <p>Typical offenders: Video editor render files, Proxy media, Audio sample libraries.</p>
                    <p>If you’re a creator and you’re constantly full, skip ahead to the “Creator quick wins” section below.</p>
                    <hr>
                    <h2>Step 6: Creator quick wins (Final Cut, DaVinci, Premiere, Logic, plugins)</h2>
                    <p>If you do audio/video work, your SSD gets eaten by “invisible” files.</p>
                    <h3>Video editing: common space hogs</h3>
                    <ul>
                    <li>Render files</li>
                    <li>Cache files</li>
                    <li>Proxy media</li>
                    <li>Optimized media</li>
                    <li>Old project exports</li>
                    </ul>
                    <p><em>Safe idea:</em> Clear cache inside the app’s settings (preferred) rather than digging through Library folders manually.</p>
                    <h3>Audio production: common space hogs</h3>
                    <ul>
                    <li>Sample libraries</li>
                    <li>Plugin installers</li>
                    <li>Project backups</li>
                    <li>Duplicate takes</li>
                    </ul>
                    <p><em>Best practice:</em> Put sample libraries on an external SSD and keep only active projects on the internal drive.</p>
                    <hr>
                    <h2>Step 7: Move large libraries to an external drive (the long-term fix)</h2>
                    <p>If your Mac has a small internal drive, cleanup alone may not be enough long-term.</p>
                    <p>Good candidates to move:</p>
                    <ul>
                    <li>Photos Library (advanced users only; do carefully)</li>
                    <li>iMovie / Final Cut Libraries</li>
                    <li>DAW sample libraries</li>
                    <li>Large video project folders</li>
                    <li>Old archives</li>
                    </ul>
                    <p>Use a fast external SSD for best results.</p>
                    <p><em>Important:</em> Don’t move random system folders. Stick to your own files and libraries.</p>
                    <hr>
                    <h2>When Finder feels too slow: use a visual cleanup tool (optional)</h2>
                    <p>Finder works, but it can be slow and tedious when you’re stressed and low on space. A good visual disk tool can help you:</p>
                    <ul>
                    <li>see big files instantly</li>
                    <li>find duplicates and junk faster</li>
                    <li>safely preview what you’re deleting</li>
                    <li>avoid deleting the wrong thing</li>
                    </ul>
                    <p>If you want a <em>no-subscription</em> option, GetDiskSpace is designed for quick “what is taking space?” answers plus a preview-first cleanup flow. (Disclosure: we may earn a commission if you purchase through our link.)</p>
                    <p><em>Important:</em> Whatever tool you use, the key is <em>preview-first</em> and <em>non-destructive workflows</em>.</p>
                    """,
                author: "MacDiskFull Team"
            ),
            Article(
                title: "Why the 256GB Mac Mini M4 is a Storage Trap (And How to Fix It)",
                slug: "mac-mini-m4-storage-problem",
                summary: "Apple's base model storage hasn't budged, but your file sizes have. Here is why the 256GB Mac Mini M4 is a bottleneck for performance and longevity.",
                contentHTML: """
                <p>The M4 Mac Mini is arguably the best value computer Apple has ever made. Ideally paired with a Studio Display, it punches way above its weight class. <strong>But there is a catch.</strong></p>
                <h3>The 256GB Storage Trap</h3>
                <p>In 2026, 256GB is not just "small"—it is functionally obsolete for a "Pro" machine. Here is the math regarding why this configuration fails most power users:</p>
                <ul>
                <li><strong>macOS Sequoia System Files:</strong> ~35GB (including reserved space)</li>
                <li><strong>Swap File Overhead:</strong> ~10-15GB (vital for 8GB/16GB Unified Memory models)</li>
                <li><strong>One Modern Game (e.g., Cyberpunk, Death Stranding):</strong> ~70GB</li>
                <li><strong>Basic App Suite (Office, Creative Cloud, Xcode):</strong> ~40GB</li>
                </ul>
                <p>Before you even save a single personal photo or 4K video project, you are down to less than 100GB of usable space.</p>
                <h3>The "Modular" Mirage</h3>
                <p>When the M4 Mac Mini launched, teardowns revealed a surprise: <strong>The storage is not soldered.</strong> It sits on a removable proprietary module, similar to the Mac Studio.</p>
                <p>So, can you just buy a 2TB stick and upgrade? <strong>No.</strong></p>
                <p>Apple's storage controller is built into the M4 chip, not the drive. The module is just raw NAND flash. This means:</p>
                <ul>
                <li><strong>No Third-Party Drives:</strong> You cannot use standard NVMe SSDs (Samsung, WD, etc).</li>
                <li><strong>Serialization Lock:</strong> Swapping modules requires a "DFU Restore" using a second Mac to pair the new NAND to the M4 chip.</li>
                <li><strong>Scarcity:</strong> Apple does not sell these modules. You can only get them from other Mac Minis or the grey market.</li>
                </ul>
                <h3>The "Swap" Penalty</h3>
                <p>The real danger isn't just running out of space—it is performance degradation. When your Unified Memory fills up, macOS writes to the SSD (Swap). If your SSD is near capacity, this process slows to a crawl, and—worse—it drastically reduces the lifespan of the soldered NAND chips.</p>
                <blockquote>"Buying the base storage model is borrowing time against your SSD's longevity." — Tech Analysis</blockquote>
                <h3>Is the "Slow SSD" Issue Fixed on M4?</h3>
                <p>On the M2 Base model, Apple famously used a single 256GB NAND chip, cutting speeds in half (1500MB/s vs 3000MB/s). While the M4 architecture improves controller efficiency, the base model still lacks the parallelism of the 512GB and 1TB versions.</p>
                <h3>The Verdict</h3>
                <p>If you buy the 256GB Mac Mini M4, <strong>do not use it as your boot drive for large creative apps.</strong> You must offload libraries. The good news? Thunderbolt 4 is fast enough to make external drives feel internal.</p>
                """,
                author: "MacDiskFull Team"
            ),
            Article(
                title: "The Best External SSDs for Mac Mini M4: Thunderbolt 4 vs USB-C",
                slug: "best-ssd-mac-mini-m4",
                summary: "Don't overpay for Apple storage. We tested the top external drives from Samsung, SanDisk, and Crucial to find the perfect match for the M4.",
                contentHTML: """
                <p>So you bought the base Mac Mini M4. Smart financial move, as long as you refuse to pay Apple's "Gold Pricing" for storage upgrades ($200 for 256GB!).</p>
                <p>We tested the top external storage solutions that take advantage of the M4's Thunderbolt 4 / USB 4 ports.</p>

                <h2>1. The "Speed King" DIY Method (Recommended)</h2>
                <p><strong>The Setup:</strong> <a href="https://www.acasis.com/">Acasis 40Gbps NVMe Enclosure</a> + <a href="https://amazon.com/dp/B08GLX7TNT">Samsung 980 PRO 2TB</a>.</p>
                <ul>
                <li><strong>Real World Speed:</strong> ~2,800 MB/s Read/Write.</li>
                <li><strong>Cost vs Apple:</strong> ~50% Cheaper for 2TB.</li>
                <li><strong>Why it wins:</strong> It uses the full bandwidth of Thunderbolt 3/4. It feels native. You can edit 8K RAW footage directly off this drive.</li>
                </ul>

                <h2>2. The Best "Plug & Play" option: Samsung T7 Shield</h2>
                <p><a href="https://amazon.com/dp/B09VLK9W3S">Samsung T7 Shield 4TB</a></p>
                <p>If you don't want to build a drive, the T7 Shield is the industry standard for creators.</p>
                <ul>
                <li><strong>Speed:</strong> ~1,050 MB/s (USB 3.2 Gen 2 limit).</li>
                <li><strong>Durability:</strong> IP65 Water/Dust resistant. Rubberized shell.</li>
                <li><strong>Verdict:</strong> Perfect for Time Machine backups and general file storage. Not quite fast enough for heavyweight 8K editing, but fine for 4K.</li>
                </ul>

                <h2>3. The Premium Choice: SanDisk Professional PRO-G40</h2>
                <p><a href="https://amazon.com/dp/B0B6ZCL29M">SanDisk PRO-G40</a></p>
                <p>This is one of the few native Thunderbolt 3 drives on the market. It runs cool and hits nearly 3,000 MB/s, but you pay a premium for the brand.</p>

                <h3>Summary Table</h3>
                <table style="width:100%; border-collapse: collapse; margin: 2rem 0; font-size: 0.9em;">
                <tr style="border-bottom: 2px solid #555;">
                  <th style="padding: 10px; text-align: left;">Drive</th>
                  <th style="padding: 10px; text-align: center;">Connection</th>
                  <th style="padding: 10px; text-align: center;">Speed</th>
                  <th style="padding: 10px; text-align: center;">Best For</th>
                </tr>
                <tr style="border-bottom: 1px solid #333;">
                  <td style="padding: 10px;">DIY Acasis</td>
                  <td style="padding: 10px; text-align: center;">Thunderbolt 4</td>
                  <td style="padding: 10px; text-align: center; color: #4ade80;">2,800 MB/s</td>
                  <td style="padding: 10px; text-align: center;">OS Boot / Pro Apps</td>
                </tr>
                <tr style="border-bottom: 1px solid #333;">
                  <td style="padding: 10px;">SanDisk PRO-G40</td>
                  <td style="padding: 10px; text-align: center;">Thunderbolt 3</td>
                  <td style="padding: 10px; text-align: center; color: #4ade80;">2,700 MB/s</td>
                  <td style="padding: 10px; text-align: center;">Video Production</td>
                </tr>
                <tr>
                  <td style="padding: 10px;">Samsung T7</td>
                  <td style="padding: 10px; text-align: center;">USB 3.2</td>
                  <td style="padding: 10px; text-align: center;">1,000 MB/s</td>
                  <td style="padding: 10px; text-align: center;">Backups / General</td>
                </tr>
                </table>
                """,
                author: "Storage Expert"
            ),
            Article(
                title: "Upgrading Mac Mini M4 Internal Storage: The Dangerous Truth",
                slug: "upgrade-mac-mini-m4-ssd",
                summary: "Think you can solder your way to more storage? Here is why upgrading the M4 internal SSD is nearly impossible and dangerous.",
                contentHTML: """
                <p>The "Right to Repair" movement has made strides, but the Mac Mini M4 remains a fortress. Can you upgrade the internal storage? The short answer is <strong>No</strong>. The long answer is <strong>"Yes, but you will regret it."</strong></p>

                <h3>The Proprietary Modular Architecture</h3>
                <p>Unlike the M1/M2 Mac Minis which had soldered storage, the M4 uses a <strong>removable storage daughterboard</strong>. This has led many to ask: "Can I swap it?"</p>

                <h3>The "Swap" Process (It's Complicated)</h3>
                <p>Upgrading isn't as simple as plugging in a drive. The process requires:</p>
                <ol>
                <li><strong>Sourcing a Module:</strong> Since Apple doesn't sell them, you rely on salvaged parts or expensive aftermarket "blanks" that require programming.</li>
                <li><strong>Physical Install:</strong> Opening the chassis (which is easier on M4 than M2).</li>
                <li><strong>DFU Restore:</strong> The critical step. You absolutely <strong>MUST</strong> have a second Mac running Apple Configurator. You connect the M4 Mini via USB-C, put it in DFU mode, and "Revive/Restore" the firmware.</li>
                </ol>

                <h3>Why this fails for 99% of Users</h3>
                <p>If you don't have a second Mac, you are stuck. If the DFU restore fails (common with mismatched NAND), you have a brick. And most importantly: <strong>It wipes all data.</strong> You cannot upgrade without erasing everything.</p>
                <p>Compared to this headache, a fast Thunderbolt drive is a dream.</p>

                <h3>The Better Way: Permanent External Boot</h3>
                <p>Instead of risking a $600+ machine, you can simply velcro a small NVMe drive to the back of the Mini.</p>
                <p><strong>Pro Tip:</strong> Use 3M Command Strips to mount a Samsung T7 or Acasis enclosure under your desk or on the back of the Studio Display. It is invisible, upgradeable, and 100% safe.</p>
                """,
                author: "Tech Breakdown"
            )
        ]
    )
}
