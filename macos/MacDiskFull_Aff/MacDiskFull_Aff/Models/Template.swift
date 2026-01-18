//
//  Template.swift
//  WebMakr
//
//  Template model for reusable site configurations
//  Compatible with macOS 11.0 (Big Sur) and later
//

import Foundation

/// A reusable site template
struct Template: Identifiable, Codable {
    let templateId: UUID
    var templateName: String
    var templateVersion: String
    var description: String
    var category: TemplateCategory
    var site: Site
    var createdAt: Date
    var updatedAt: Date
    
    // Built-in template flag (can't be deleted)
    var isBuiltIn: Bool
    
    var id: UUID { templateId }
    
    init(
        templateId: UUID = UUID(),
        templateName: String = "New Template",
        templateVersion: String = "1.0.0",
        description: String = "",
        category: TemplateCategory = .comparison,
        site: Site = Site(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isBuiltIn: Bool = false
    ) {
        self.templateId = templateId
        self.templateName = templateName
        self.templateVersion = templateVersion
        self.description = description
        self.category = category
        self.site = site
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isBuiltIn = isBuiltIn
    }
    
    /// Create template from existing site
    static func from(site: Site, name: String, description: String = "") -> Template {
        Template(
            templateName: name,
            description: description,
            site: site
        )
    }
}

// MARK: - Template Category

enum TemplateCategory: String, Codable, CaseIterable {
    case comparison = "Comparison"
    case singleProduct = "Single Product"
    case review = "Review"
    case landing = "Landing Page"
    case blank = "Blank"
    
    var icon: String {
        switch self {
        case .comparison: return "list.bullet.rectangle"
        case .singleProduct: return "star.fill"
        case .review: return "text.quote"
        case .landing: return "doc.richtext"
        case .blank: return "doc"
        }
    }
}

// MARK: - Template Summary (for list display)

struct TemplateSummary: Identifiable {
    let templateId: UUID
    let templateName: String
    let description: String
    let category: TemplateCategory
    let productCount: Int
    let isBuiltIn: Bool
    
    var id: UUID { templateId }
}

// MARK: - Template Storage Extension

extension ProjectStorage {
    
    /// List all available templates
    func listTemplates() -> [TemplateSummary] {
        var summaries: [TemplateSummary] = []
        
        // Add built-in templates first
        summaries.append(contentsOf: builtInTemplateSummaries())
        
        // Add user templates
        guard let contents = try? fileManager.contentsOfDirectory(at: templatesDirectory, includingPropertiesForKeys: nil) else {
            return summaries
        }
        
        for url in contents where url.pathExtension == "json" {
            if let template = loadTemplate(from: url) {
                summaries.append(TemplateSummary(
                    templateId: template.templateId,
                    templateName: template.templateName,
                    description: template.description,
                    category: template.category,
                    productCount: template.site.products.count,
                    isBuiltIn: template.isBuiltIn
                ))
            }
        }
        
        return summaries
    }
    
    /// Load full template by ID
    func loadTemplate(id: UUID) -> Template? {
        // Check built-in templates first
        if let builtIn = builtInTemplates().first(where: { $0.templateId == id }) {
            return builtIn
        }
        
        // Check user templates
        let path = templatesDirectory.appendingPathComponent("\(id.uuidString).json")
        return loadTemplate(from: path)
    }
    
    /// Load template from file
    private func loadTemplate(from url: URL) -> Template? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Template.self, from: data)
    }
    
    /// Save a user template
    func saveTemplate(_ template: Template) throws {
        var templateToSave = template
        templateToSave.updatedAt = Date()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(templateToSave)
        let path = templatesDirectory.appendingPathComponent("\(template.templateId.uuidString).json")
        try data.write(to: path)
    }
    
    /// Delete a user template (built-in templates can't be deleted)
    func deleteTemplate(id: UUID) throws {
        let path = templatesDirectory.appendingPathComponent("\(id.uuidString).json")
        try fileManager.removeItem(at: path)
    }
    
    /// Export template to external URL
    func exportTemplate(_ template: Template, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(template)
        try data.write(to: url)
    }
    
    /// Import template from external URL
    func importTemplate(from url: URL) throws -> Template {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        var template = try decoder.decode(Template.self, from: data)
        
        // Assign new ID to avoid conflicts
        template = Template(
            templateId: UUID(),
            templateName: template.templateName,
            templateVersion: template.templateVersion,
            description: template.description,
            category: template.category,
            site: template.site,
            isBuiltIn: false  // Imported templates are never built-in
        )
        
        try saveTemplate(template)
        return template
    }
    
    // MARK: - Built-in Templates
    
    private func builtInTemplateSummaries() -> [TemplateSummary] {
        builtInTemplates().map { template in
            TemplateSummary(
                templateId: template.templateId,
                templateName: template.templateName,
                description: template.description,
                category: template.category,
                productCount: template.site.products.count,
                isBuiltIn: true
            )
        }
    }
    
    func builtInTemplates() -> [Template] {
        [
            Template.macDiskFullComparison,
            Template.minimalSinglePick,
            Template.blankStarter
        ]
    }
}

// MARK: - Built-in Template Definitions

extension Template {
    
    /// Full 4-product comparison template (MacDiskFull style)
    static let macDiskFullComparison = Template(
        templateId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        templateName: "Mac Disk Cleaner Comparison",
        templateVersion: "1.0.0",
        description: "4-product comparison site for Mac disk cleaners with GetDiskSpace as featured pick",
        category: .comparison,
        site: Site.sampleMacDiskFull,
        isBuiltIn: true
    )
    
    /// Minimal single product recommendation
    static let minimalSinglePick = Template(
        templateId: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        templateName: "Minimal Single Pick",
        templateVersion: "1.0.0",
        description: "Clean single-product recommendation with brief competitor mentions",
        category: .singleProduct,
        site: Site(
            name: "Best [Product Type]",
            tagline: "Looking for the best [product type]?",
            products: [
                Product(
                    name: "Your Product",
                    shortDescription: "The best solution for [problem].",
                    price: "$XX.XX",
                    rating: 4.8,
                    affiliateLink: "https://example.com",
                    productType: .ownProduct,
                    isRecommended: true,
                    pros: ["Key benefit 1", "Key benefit 2", "Key benefit 3"],
                    cons: ["Minor limitation"],
                    sortOrder: 1
                ),
                Product(
                    name: "Alternative A",
                    shortDescription: "Popular alternative.",
                    price: "$XX/year",
                    rating: 4.2,
                    affiliateLink: "https://example.com",
                    productType: .otherAffiliate,
                    isRecommended: false,
                    pros: ["Pro 1", "Pro 2"],
                    cons: ["Con 1", "Con 2"],
                    sortOrder: 2
                )
            ]
        ),
        isBuiltIn: true
    )
    
    /// Blank starter template
    static let blankStarter = Template(
        templateId: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        templateName: "Blank Starter",
        templateVersion: "1.0.0",
        description: "Empty template - start from scratch",
        category: .blank,
        site: Site(
            name: "My Site",
            tagline: "Your tagline here"
        ),
        isBuiltIn: true
    )
}
