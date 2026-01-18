//
//  AffiliateDatabase.swift
//  WebMakr
//
//  Seeded database of global affiliate programs
//

import Foundation

class AffiliateDatabase: ObservableObject {
    static let shared = AffiliateDatabase()
    
    // The master list of programs
    @Published var programs: [AffiliateProgram]
    
    // Remote source
    static let masterDatabaseURL = URL(string: "https://api.webmakr.app/updates/affiliates.json")!
    @Published var isSyncing = false
    @Published var lastSyncDate: Date? // Should persist this
    
    private init() {
        self.programs = AffiliateDatabase.seedData()
    }
    
    static func seedData() -> [AffiliateProgram] {
        return [
            // MARK: - Retail & Asian Markets
            AffiliateProgram(
                id: UUID(),
                name: "Amazon Associates",
                category: .retail,
                website: "https://amazon.com",
                signupURL: "https://affiliate-program.amazon.com/",
                linkPattern: "https://www.amazon.com/dp/{pid}?tag={affId}",
                idPlaceholder: "ASIN",
                regions: ["Global"],
                difficulty: .intermediate,
                approvalSpeed: .strict,
                tips: "Must make 3 sales in 180 days to stay approved. Great conversion, low commission.",
                bansCloaking: true,
                isUserDefined: false
            ),
            AffiliateProgram(
                id: UUID(),
                name: "Shopee Philippines",
                category: .retail,
                website: "https://shopee.ph",
                signupURL: "https://shopee.ph/affiliate",
                linkPattern: "https://shopee.ph/product/{pid}?ref={affId}",
                idPlaceholder: "ShopID/ProductID",
                regions: ["PH"],
                difficulty: .beginner,
                approvalSpeed: .fast,
                tips: "Very popular in Philippines. Easy to promote on social media.",
                isUserDefined: false
            ),
            AffiliateProgram(
                id: UUID(),
                name: "Lazada",
                category: .retail,
                website: "https://lazada.com",
                signupURL: "https://www.lazada.com/affiliate",
                linkPattern: nil, // Complex deep linking
                idPlaceholder: "Product URL",
                regions: ["PH", "SG", "MY", "TH", "VN", "ID"],
                difficulty: .beginner,
                approvalSpeed: .fast,
                tips: "Direct competitor to Shopee. Good for electronics reviews.",
                isUserDefined: false
            ),
            AffiliateProgram(
                id: UUID(),
                name: "Walmart",
                category: .retail,
                website: "https://walmart.com",
                signupURL: "https://affiliates.walmart.com/",
                linkPattern: "https://www.walmart.com/ip/{pid}?aff={affId}",
                idPlaceholder: "Item ID",
                regions: ["US"],
                difficulty: .intermediate,
                approvalSpeed: .manual,
                tips: "Good alternative to Amazon for US traffic.",
                isUserDefined: false
            ),
            
            // MARK: - Software & AI
            AffiliateProgram(
                id: UUID(),
                name: "Lemon Squeezy",
                category: .software,
                website: "https://lemonsqueezy.com",
                signupURL: "https://lemonsqueezy.com/affiliates",
                linkPattern: "https://{pid}.lemonsqueezy.com/checkout/buy?aff={affId}",
                idPlaceholder: "Store Slug",
                regions: ["Global"],
                difficulty: .beginner,
                approvalSpeed: .instant,
                tips: "Instant approval for many products. Great for selling digital goods and software.",
                isUserDefined: false
            ),
            AffiliateProgram(
                id: UUID(),
                name: "PartnerStack",
                category: .software,
                website: "https://partnerstack.com",
                signupURL: "https://partnerstack.com",
                linkPattern: "https://{pid}.partnerlinks.io/{affId}",
                idPlaceholder: "Program Slug",
                regions: ["Global"],
                difficulty: .advanced,
                approvalSpeed: .manual,
                tips: "Marketplace for top-tier SaaS (Notion, etc). Approvals can be strict.",
                isUserDefined: false
            ),
            AffiliateProgram(
                id: UUID(),
                name: "Jasper AI",
                category: .software,
                website: "https://jasper.ai",
                signupURL: "https://jasper.ai/partners",
                linkPattern: "https://jasper.ai?fpr={affId}",
                idPlaceholder: "N/A (Site-wide)",
                regions: ["Global"],
                difficulty: .intermediate,
                approvalSpeed: .manual,
                tips: "High commission AI tool. Needs quality content to get approved.",
                isUserDefined: false
            ),
            AffiliateProgram(
                id: UUID(),
                name: "CleanMyMac (Impact)",
                category: .software,
                website: "https://macpaw.com",
                signupURL: "https://macpaw.com/affiliate",
                linkPattern: "https://macpaw.pxf.io/c/{affId}/{pid}/123456",
                idPlaceholder: "Campaign ID",
                regions: ["Global"],
                difficulty: .beginner,
                approvalSpeed: .manual,
                tips: "High converting Mac utility. Good for tech blogs.",
                isUserDefined: false
            ),
            
            // MARK: - Financial
            AffiliateProgram(
                id: UUID(),
                name: "Chase Bank",
                category: .finance,
                website: "https://chase.com",
                signupURL: "https://chase.com/referafriend",
                linkPattern: nil,
                idPlaceholder: "Referral Link",
                regions: ["US"],
                difficulty: .beginner,
                approvalSpeed: .instant,
                tips: "Refer-a-friend program is easy to start. Capped yearly rewards.",
                isUserDefined: false
            ),
            AffiliateProgram(
                id: UUID(),
                name: "Wise (TransferWise)",
                category: .finance,
                website: "https://wise.com",
                signupURL: "https://wise.com/affiliate",
                linkPattern: "https://wise.com/invite/u/{affId}",
                idPlaceholder: "Username",
                regions: ["Global"],
                difficulty: .beginner,
                approvalSpeed: .instant,
                tips: "Great for travel/expat audiences. Easy to get link.",
                isUserDefined: false
            ),
            
            // MARK: - Insurance
            AffiliateProgram(
                id: UUID(),
                name: "Lemonade Insurance",
                category: .insurance,
                website: "https://lemonade.com",
                signupURL: "https://lemonade.com/affiliates",
                linkPattern: nil,
                idPlaceholder: "Tracking Link",
                regions: ["US", "EU"],
                difficulty: .intermediate,
                approvalSpeed: .manual,
                tips: "Modern insurance. Converts well with younger audience.",
                isUserDefined: false
            )
        ]
    }
    
    // MARK: - Sync Capabilities
    
    /// The remote source of truth
    static let masterDatabaseURL = URL(string: "https://funsoftware.cc/api/affiliates.json")!
    
    /// Sync with remote database to get new programs
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    
    /// Fetch updates from the external master list
    func checkForUpdates(completion: @escaping (Result<Int, Error>) -> Void) {
        guard !isSyncing else { return }
        isSyncing = true
        
        let task = URLSession.shared.dataTask(with: AffiliateDatabase.masterDatabaseURL) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isSyncing = false
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "WebMakr", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let newPrograms = try decoder.decode([AffiliateProgram].self, from: data)
                    let addedCount = self?.mergePrograms(newPrograms) ?? 0
                    self?.lastSyncDate = Date()
                    completion(.success(addedCount))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    /// Merge remote programs with local ones (avoiding duplicates)
    private func mergePrograms(_ remotePrograms: [AffiliateProgram]) -> Int {
        var added = 0
        for program in remotePrograms {
            // Check for duplicates by ID or Name
            if !programs.contains(where: { $0.id == program.id || $0.name == program.name }) {
                programs.append(program)
                added += 1
            }
        }
        return added
    }
}

