//
//  AffiliateProgram.swift
//  WebMakr
//
//  Model for comprehensive affiliate network database
//

import Foundation

enum ProgramCategory: String, Codable, CaseIterable {
    case retail = "Retail & E-Commerce"        // Amazon, Walmart, Shopee
    case software = "Software & AI"            // SaaS, AI Tools, VPNs
    case finance = "Finance & Banking"         // Credit Cards, Banks
    case insurance = "Insurance"
    case hosting = "Web Hosting"
    case other = "General / Other"
}

enum ProgramDifficulty: String, Codable {
    case beginner = "Beginner Friendly"
    case intermediate = "Intermediate"
    case advanced = "Advanced / High Traffic"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

enum ApprovalSpeed: String, Codable {
    case instant = "Instant Access"
    case fast = "Fast (< 24h)"
    case manual = "Manual Review"
    case strict = "Strict Vetting"
}

struct AffiliateProgram: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: ProgramCategory
    var website: String            // Main website
    var signupURL: String          // Where to apply for affiliate program
    var linkPattern: String?       // Template: https://site.com/{id}?ref={affId}
    var idPlaceholder: String      // What is the "Product ID"? (ASIN, SKU, etc)
    var regions: [String]          // ["Global"], ["US"], ["PH", "SG", "MY"]
    var compatibility: String?     // Notes on compatibility
    
    // WebMakr "Insider Info"
    var difficulty: ProgramDifficulty?
    var approvalSpeed: ApprovalSpeed?
    var tips: String?              // "Great for new sites", "Needs 10k visits/mo"
    var bansCloaking: Bool?        // e.g. Amazon bans redirects (ThirstyAffiliates feature)
    
    // For custom/user-added programs
    var isUserDefined: Bool
    
    static func == (lhs: AffiliateProgram, rhs: AffiliateProgram) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Helper to generate a link if pattern exists
    func generateLink(productId: String, affiliateId: String, campaign: String?) -> String? {
        guard let pattern = linkPattern else { return nil }
        
        var link = pattern
            .replacingOccurrences(of: "{pid}", with: productId)
            .replacingOccurrences(of: "{affId}", with: affiliateId)
        
        if let camp = campaign, !camp.isEmpty {
            link = link.replacingOccurrences(of: "{campaign}", with: camp)
        } else {
            // Remove campaign param if empty
            link = link.replacingOccurrences(of: "&sub={campaign}", with: "")
            link = link.replacingOccurrences(of: "?sub={campaign}", with: "")
        }
        
        return link
    }
}
