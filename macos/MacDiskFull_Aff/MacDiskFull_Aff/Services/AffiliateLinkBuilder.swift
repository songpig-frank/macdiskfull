//
//  AffiliateLinkBuilder.swift
//  WebMakr
//
//  Helper to generate affiliate links for various networks
//  Compatible with macOS 11.0 (Big Sur) and later
//

import Foundation

class AffiliateLinkBuilder {
    
    /// Build a final affiliate link based on network parameters
    /// - Parameters:
    ///   - network: The affiliate network
    ///   - productId: The product identifier (ASIN, Variant ID, or partial URL path)
    ///   - affiliateId: The user's affiliate ID for that network
    ///   - campaign: Optional campaign/subId tracking parameter
    /// - Returns: Fully formed URL string
    static func buildLink(
        networkName: String,
        productId: String,
        affiliateId: String,
        campaign: String = ""
    ) -> String {
        
        // Clean inputs
        let pid = productId.trimmingCharacters(in: .whitespacesAndNewlines)
        let aid = affiliateId.trimmingCharacters(in: .whitespacesAndNewlines)
        let cmp = campaign.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if networkName == "Custom Link" { return pid }
        
        // 1. Try to find in dynamic database
        if let program = AffiliateDatabase.shared.programs.first(where: { $0.name == networkName }) {
            if let link = program.generateLink(productId: pid, affiliateId: aid, campaign: cmp) {
                return link
            }
        }
        
        // 2. Fallback for hardcoded/legacy types if DB lookup fails
        if let network = AffiliateNetwork(rawValue: networkName) {
            switch network {
            case .amazon:
                return "https://www.amazon.com/dp/\(pid)?tag=\(aid)"
            case .lemonSqueezy:
                if pid.contains("lemonsqueezy.com") {
                     let separator = pid.contains("?") ? "&" : "?"
                     return "\(pid)\(separator)aff=\(aid)"
                }
                return "https://checkout.lemonsqueezy.com/buy/\(pid)?aff=\(aid)"
            default:
                break
            }
        }

        return pid
    }
    
    /// Get help text for what to enter in "Product ID" field
    static func placeholder(for networkName: String) -> String {
        if let program = AffiliateDatabase.shared.programs.first(where: { $0.name == networkName }) {
            return program.idPlaceholder
        }
        return "Product ID / URL"
    }
}
