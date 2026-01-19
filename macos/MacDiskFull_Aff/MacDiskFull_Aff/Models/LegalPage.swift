//
//  LegalPage.swift
//  WebMakr
//
//  Legal Page model with version control and archiving
//

import Foundation

/// Types of legal pages
enum LegalPageType: String, Codable, CaseIterable, Identifiable {
    case privacyPolicy = "Privacy Policy"
    case termsOfService = "Terms of Service"
    case cookiePolicy = "Cookie Policy"
    case eula = "End User License Agreement"
    case affiliateDisclosure = "Affiliate Disclosure"
    case disclaimer = "Disclaimer"
    
    var id: String { rawValue }
    
    var slug: String {
        switch self {
        case .privacyPolicy: return "privacy"
        case .termsOfService: return "terms"
        case .cookiePolicy: return "cookies"
        case .eula: return "eula"
        case .affiliateDisclosure: return "disclosure"
        case .disclaimer: return "disclaimer"
        }
    }
    
    var icon: String {
        switch self {
        case .privacyPolicy: return "lock.shield"
        case .termsOfService: return "doc.text"
        case .cookiePolicy: return "server.rack"
        case .eula: return "signature"
        case .affiliateDisclosure: return "dollarsign.circle"
        case .disclaimer: return "exclamationmark.triangle"
        }
    }
    
    /// Default boilerplate content for each page type
    var defaultContent: String {
        switch self {
        case .privacyPolicy:
            return """
            <h2>Privacy Policy</h2>
            <p><em>Last updated: [DATE]</em></p>
            
            <h3>Information We Collect</h3>
            <p>We collect information you provide directly to us, such as when you contact us or subscribe to our newsletter.</p>
            
            <h3>How We Use Your Information</h3>
            <p>We use the information we collect to provide, maintain, and improve our services.</p>
            
            <h3>Cookies</h3>
            <p>We use cookies and similar technologies to collect information about your browsing activities.</p>
            
            <h3>Contact Us</h3>
            <p>If you have any questions about this Privacy Policy, please contact us.</p>
            """
            
        case .termsOfService:
            return """
            <h2>Terms of Service</h2>
            <p><em>Last updated: [DATE]</em></p>
            
            <h3>Acceptance of Terms</h3>
            <p>By accessing or using our website, you agree to be bound by these Terms of Service.</p>
            
            <h3>Use of Service</h3>
            <p>You may use our service only for lawful purposes and in accordance with these Terms.</p>
            
            <h3>Intellectual Property</h3>
            <p>The content on this website is owned by us and protected by copyright laws.</p>
            
            <h3>Limitation of Liability</h3>
            <p>We shall not be liable for any indirect, incidental, or consequential damages.</p>
            """
            
        case .cookiePolicy:
            return """
            <h2>Cookie Policy</h2>
            <p><em>Last updated: [DATE]</em></p>
            
            <h3>What Are Cookies</h3>
            <p>Cookies are small text files stored on your device when you visit our website.</p>
            
            <h3>How We Use Cookies</h3>
            <p>We use cookies to improve your experience, analyze site traffic, and personalize content.</p>
            
            <h3>Types of Cookies We Use</h3>
            <ul>
                <li><strong>Essential Cookies:</strong> Required for the website to function properly.</li>
                <li><strong>Analytics Cookies:</strong> Help us understand how visitors interact with our site.</li>
                <li><strong>Marketing Cookies:</strong> Used to deliver relevant advertisements.</li>
            </ul>
            
            <h3>Managing Cookies</h3>
            <p>You can control cookies through your browser settings.</p>
            """
            
        case .eula:
            return """
            <h2>End User License Agreement</h2>
            <p><em>Last updated: [DATE]</em></p>
            
            <h3>License Grant</h3>
            <p>We grant you a limited, non-exclusive, non-transferable license to use our software.</p>
            
            <h3>Restrictions</h3>
            <p>You may not copy, modify, distribute, or create derivative works of our software.</p>
            
            <h3>Termination</h3>
            <p>This license is effective until terminated. It will terminate automatically if you fail to comply with any term.</p>
            
            <h3>Disclaimer of Warranties</h3>
            <p>The software is provided "as is" without warranty of any kind.</p>
            """
            
        case .affiliateDisclosure:
            return """
            <h2>Affiliate Disclosure</h2>
            <p><em>Last updated: [DATE]</em></p>
            
            <p>This website contains affiliate links. This means we may earn a commission if you click on a link and make a purchase. This comes at no additional cost to you.</p>
            
            <h3>How This Affects You</h3>
            <p>Our recommendations are based on our honest opinions and research. We only recommend products we believe will provide value to our readers.</p>
            
            <h3>FTC Compliance</h3>
            <p>In accordance with FTC guidelines, we disclose our affiliate relationships on pages containing affiliate links.</p>
            """
            
        case .disclaimer:
            return """
            <h2>Disclaimer</h2>
            <p><em>Last updated: [DATE]</em></p>
            
            <h3>General Information</h3>
            <p>The information provided on this website is for general informational purposes only.</p>
            
            <h3>No Professional Advice</h3>
            <p>Nothing on this website constitutes professional advice. Consult with a qualified professional before making decisions.</p>
            
            <h3>External Links</h3>
            <p>We are not responsible for the content of external websites linked from our site.</p>
            """
        }
    }
}

/// Status of a legal page
enum LegalPageStatus: String, Codable, CaseIterable {
    case draft = "Draft"
    case published = "Published"
    case archived = "Archived"
}

/// A revision/version of a legal page
struct LegalPageRevision: Identifiable, Codable, Hashable {
    let id: UUID
    let version: Int
    let contentHTML: String
    let createdAt: Date
    let note: String
    
    init(id: UUID = UUID(), version: Int, contentHTML: String, createdAt: Date = Date(), note: String = "") {
        self.id = id
        self.version = version
        self.contentHTML = contentHTML
        self.createdAt = createdAt
        self.note = note
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LegalPageRevision, rhs: LegalPageRevision) -> Bool {
        lhs.id == rhs.id
    }
}

/// A legal page with version control
struct LegalPage: Identifiable, Codable {
    let id: UUID
    var pageType: LegalPageType
    var title: String
    var contentHTML: String
    var status: LegalPageStatus
    var version: Int
    var createdAt: Date
    var modifiedAt: Date
    var revisions: [LegalPageRevision]
    
    init(
        id: UUID = UUID(),
        pageType: LegalPageType,
        title: String? = nil,
        contentHTML: String? = nil,
        status: LegalPageStatus = .draft,
        version: Int = 1,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        revisions: [LegalPageRevision] = []
    ) {
        self.id = id
        self.pageType = pageType
        self.title = title ?? pageType.rawValue
        self.contentHTML = contentHTML ?? pageType.defaultContent
        self.status = status
        self.version = version
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.revisions = revisions
    }
    
    /// Create a new revision from the current content
    mutating func saveRevision(note: String = "") {
        let revision = LegalPageRevision(
            version: version,
            contentHTML: contentHTML,
            note: note
        )
        revisions.append(revision)
        version += 1
        modifiedAt = Date()
    }
    
    /// Restore content from a specific revision
    mutating func restoreRevision(_ revision: LegalPageRevision) {
        // Save current as a revision first
        saveRevision(note: "Saved before restoring to version \(revision.version)")
        // Restore content
        contentHTML = revision.contentHTML
        modifiedAt = Date()
    }
    
    /// Archive this page (keeps it but hides from public)
    mutating func archive() {
        status = .archived
        modifiedAt = Date()
    }
    
    /// Publish this page
    mutating func publish() {
        status = .published
        modifiedAt = Date()
    }
}

// MARK: - Sample Data

extension LegalPage {
    static let samplePrivacyPolicy = LegalPage(
        pageType: .privacyPolicy,
        status: .published
    )
    
    static let sampleTerms = LegalPage(
        pageType: .termsOfService,
        status: .published
    )
    
    static let sampleCookiePolicy = LegalPage(
        pageType: .cookiePolicy,
        status: .draft
    )
}
