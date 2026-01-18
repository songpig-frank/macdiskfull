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

/// MVP Affiliate Settings
struct AffiliateSettings: Codable {
    var defaultAffiliateDisclosure: String
    var globalAffiliateIds: [String: String] // Network.rawValue -> Affiliate ID
    var defaultCampaign: String
    
    init(
        defaultAffiliateDisclosure: String = "We may earn a commission when you buy through links on our site. This helps support our work and does not affect our reviews or recommendations.",
        globalAffiliateIds: [String: String] = [:],
        defaultCampaign: String = ""
    ) {
        self.defaultAffiliateDisclosure = defaultAffiliateDisclosure
        self.globalAffiliateIds = globalAffiliateIds
        self.defaultCampaign = defaultCampaign
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
        ]
    )
}
