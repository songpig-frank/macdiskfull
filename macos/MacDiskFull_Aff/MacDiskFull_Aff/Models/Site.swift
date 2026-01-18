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
                title: "Mac Mini M4: Why 256GB is a Joke in 2026",
                slug: "mac-mini-m4-storage-problem",
                summary: "Apple's base model storage hasn't budged, but your file sizes have. Here is why the 256GB Mac Mini M4 is a trap.",
                contentHTML: """
                <p>The M4 Mac Mini is a marvel of engineering—tiny footprint, massive performance. But there is one glaring issue that reviewers like <strong>Marques Brownlee</strong> and <strong>Snazzy Labs</strong> have pointed out: the base 256GB storage.</p>
                <h3>The "Soldered" Problem</h3>
                <p>Unlike the good old days, you cannot simply open your Mac Mini and pop in a new drive. The NAND chips are soldered directly to the board. This means the storage you buy today is the storage you live with forever... or is it?</p>
                <p>If you fill up that 256GB with Xcode caches, 4K footage, or modern AAA games, you are going to hit a wall. macOS itself takes up 20GB+. Then add apps.</p>
                <h3>The Solution?</h3>
                <p>You have two choices: Pay Apple's "Gold" prices for an upgrade ($200 for 256GB extra!), or look at external solutions that are faster and cheaper.</p>
                """,
                author: "MacDiskFull Team"
            ),
            Article(
                title: "External SSD Shootout: Best Drives for Mac Mini M4",
                slug: "best-ssd-mac-mini-m4",
                summary: "Don't overpay for Apple storage. We tested the top external drives from Samsung, SanDisk, and Crucial.",
                contentHTML: """
                <p>So you bought the 256GB model. Smart move—if you plan to expand externally. We've tested the top contenders.</p>
                <h3>1. Samsung T7 Shield (The Reliable Choice)</h3>
                <p>Rugged, fast, and consistent. The T7 Shield sustains high write speeds even during long transfers.</p>
                <p><a href="https://amazon.com/dp/B09VLK9W3S" class="btn btn-sm">Check Price on Amazon</a></p>
                <h3>2. SanDisk Extreme Pro (The Speed Demon)</h3>
                <p>If you need 2000MB/s speeds for video editing, this is the beast you want. Just be aware of the price premium.</p>
                <p><a href="https://amazon.com/dp/B08GV9BLRF" class="btn btn-sm">Check Price on Amazon</a></p>
                <h3>3. DIY NVMe Enclosure (The Pro Choice)</h3>
                <p>For the brave, buying a generic NVMe drive and an <strong>Acasis 40Gbps Enclosure</strong> can actually outperform off-the-shelf drives.</p>
                """,
                author: "Storage Expert"
            ),
            Article(
                title: "Can You Upgrade Mac Mini M4 Storage? (Spoiler: Risky)",
                slug: "upgrade-mac-mini-m4-ssd",
                summary: "Some YouTubers have tried unsoldering chips. Here is why you absolutely should not try this at home.",
                contentHTML: """
                <p>We've all seen the videos. A guy with a heat gun, a microscope, and steady hands swapping NAND chips on a Mac Studio or Mini.</p>
                <h3>Is it upgrading possible?</h3>
                <p>Technically, yes. Channels like <strong>Luke Miani</strong> have explored the modularity (or lack thereof) in Apple Silicon Macs.</p>
                <h3>The Risks</h3>
                <ul>
                    <li><strong>Voiding Warranty:</strong> Instantly gone.</li>
                    <li><strong>Bricking the Device:</strong> One slip and the M4 chip is dead.</li>
                    <li><strong>DFU Mode:</strong> You need a second Mac to revive the firmware.</li>
                </ul>
                <p>For 99.9% of users, the answer is simple: <strong>Get a Thunderbolt Dock or External SSD.</strong> It's cheaper, safer, and portable.</p>
                """,
                author: "Tech Breakdown"
            )
        ]
    )
}
