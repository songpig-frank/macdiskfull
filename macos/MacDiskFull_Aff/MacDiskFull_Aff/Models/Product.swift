//
//  Product.swift
//  WebMakr
//
//  MVP Product Model - Simplified for comparison table
//  Compatible with macOS 11.0 (Big Sur) and later
//

import Foundation

/// Type of product - helps categorize for comparison
enum ProductType: String, Codable, CaseIterable {
    case ownProduct = "Featured"       // Your main product
    case amazonAffiliate = "Amazon"    // Amazon affiliate link
    case otherAffiliate = "Partner"    // Other affiliate products
    case competitor = "Comparison"     // Competitors for comparison
}

/// MVP Product - only essential fields for comparison table
struct Product: Identifiable, Codable {
    let id: UUID
    var name: String
    var shortDescription: String
    var price: String              // Display text like "$19.99" or "$89/year"
    var rating: Double             // 1.0 to 5.0
    var affiliateLink: String
    var productType: ProductType
    var isRecommended: Bool        // Shows "Best Choice" badge
    var pros: [String]
    var cons: [String]
    var sortOrder: Int
    
    // Affiliate Link Builder
    var affiliateNetworkId: String?
    var externalId: String?
    var campaignOverride: String?
    
    init(
        id: UUID = UUID(),
        name: String = "New Product",
        shortDescription: String = "",
        price: String = "$0",
        rating: Double = 4.0,
        affiliateLink: String = "",
        productType: ProductType = .otherAffiliate,
        isRecommended: Bool = false,
        pros: [String] = [],
        cons: [String] = [],
        sortOrder: Int = 0,
        affiliateNetworkId: String? = nil,
        externalId: String? = nil,
        campaignOverride: String? = nil
    ) {
        self.id = id
        self.name = name
        self.shortDescription = shortDescription
        self.price = price
        self.rating = rating
        self.affiliateLink = affiliateLink
        self.productType = productType
        self.isRecommended = isRecommended
        self.pros = pros
        self.cons = cons
        self.sortOrder = sortOrder
        self.affiliateNetworkId = affiliateNetworkId
        self.externalId = externalId
        self.campaignOverride = campaignOverride
    }
}

// MARK: - Helpers

extension Product {
    /// Star rating display
    var starRating: String {
        let fullStars = Int(rating)
        let emptyStars = 5 - fullStars
        return String(repeating: "★", count: fullStars) + String(repeating: "☆", count: emptyStars)
    }
}
