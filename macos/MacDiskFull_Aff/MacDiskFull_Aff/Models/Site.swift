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
    
    init(id: UUID = UUID(), title: String, slug: String, summary: String, contentHTML: String, author: String = "Editorial Team", publishedDate: Date = Date(), heroImage: String = "assets/blog-hero.jpg") {
        self.id = id
        self.title = title
        self.slug = slug
        self.summary = summary
        self.contentHTML = contentHTML
        self.author = author
        self.publishedDate = publishedDate
        self.heroImage = heroImage
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
    var theme: SiteTheme
    var affiliateSettings: AffiliateSettings
    var products: [Product]
    var articles: [Article] // New: Blog Articles
    
    // Pro Features
    var usePrettyLinks: Bool
    var generateLegalPages: Bool
    var openAIKey: String = "" // For AI features
    
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
        usePrettyLinks: Bool = true,
        generateLegalPages: Bool = true,
        openAIKey: String = "",
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
        self.usePrettyLinks = usePrettyLinks
        self.generateLegalPages = generateLegalPages
        self.openAIKey = openAIKey
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
