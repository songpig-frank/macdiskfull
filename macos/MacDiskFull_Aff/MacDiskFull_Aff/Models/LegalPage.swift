//
//  LegalPage.swift
//  WebMakr
//
//  Legal Page model with version control, site-specific content generation, and import
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
    
    /// Generate site-specific content with placeholders filled
    func generateContent(siteName: String, domain: String, email: String, address: String = "") -> String {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
        let year = Calendar.current.component(.year, from: Date())
        
        switch self {
        case .privacyPolicy:
            return """
            <h2>Privacy Policy for \(siteName)</h2>
            <p><em>Last updated: \(today)</em></p>
            
            <p>\(siteName) ("we," "our," or "us") operates the website \(domain) (the "Site"). This page informs you of our policies regarding the collection, use, and disclosure of personal information we receive from users of the Site.</p>
            
            <h3>1. Information We Collect</h3>
            <p>We may collect the following types of information:</p>
            <ul>
                <li><strong>Personal Information:</strong> Name, email address, and any information you voluntarily provide when contacting us or subscribing to our newsletter.</li>
                <li><strong>Usage Data:</strong> Information about how you access and use the Site, including your IP address, browser type, pages visited, and time spent on pages.</li>
                <li><strong>Cookies and Tracking:</strong> We use cookies and similar tracking technologies to monitor activity on our Site.</li>
            </ul>
            
            <h3>2. How We Use Your Information</h3>
            <p>We use the collected information for various purposes:</p>
            <ul>
                <li>To provide and maintain our Site</li>
                <li>To notify you about changes to our Site</li>
                <li>To provide customer support</li>
                <li>To gather analysis or valuable information to improve our Site</li>
                <li>To monitor the usage of our Site</li>
                <li>To detect, prevent and address technical issues</li>
            </ul>
            
            <h3>3. Data Sharing and Disclosure</h3>
            <p>We do not sell, trade, or rent your personal identification information to others. We may share generic aggregated demographic information not linked to any personal identification information with our business partners and advertisers.</p>
            
            <h3>4. Third-Party Services</h3>
            <p>Our Site may contain links to third-party websites. We have no control over the content, privacy policies, or practices of any third-party sites or services.</p>
            
            <h3>5. Data Security</h3>
            <p>The security of your data is important to us, but remember that no method of transmission over the Internet or method of electronic storage is 100% secure.</p>
            
            <h3>6. Your Rights</h3>
            <p>You have the right to access, update, or delete your personal information. You may also opt out of receiving marketing communications from us.</p>
            
            <h3>7. Children's Privacy</h3>
            <p>Our Site does not address anyone under the age of 13. We do not knowingly collect personal information from children under 13.</p>
            
            <h3>8. Changes to This Privacy Policy</h3>
            <p>We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.</p>
            
            <h3>9. Contact Us</h3>
            <p>If you have any questions about this Privacy Policy, please contact us:</p>
            <ul>
                <li>By email: \(email)</li>
                \(address.isEmpty ? "" : "<li>By mail: \(address)</li>")
            </ul>
            
            <p><em>© \(year) \(siteName). All rights reserved.</em></p>
            """
            
        case .termsOfService:
            return """
            <h2>Terms of Service for \(siteName)</h2>
            <p><em>Last updated: \(today)</em></p>
            
            <p>Please read these Terms of Service ("Terms") carefully before using \(domain) (the "Site") operated by \(siteName) ("we," "our," or "us").</p>
            
            <h3>1. Acceptance of Terms</h3>
            <p>By accessing or using our Site, you agree to be bound by these Terms. If you disagree with any part of the terms, you may not access the Site.</p>
            
            <h3>2. Description of Service</h3>
            <p>\(siteName) provides information, product comparisons, reviews, and recommendations. The content is for informational purposes only.</p>
            
            <h3>3. User Conduct</h3>
            <p>You agree not to:</p>
            <ul>
                <li>Use the Site for any unlawful purpose or in violation of any local, state, national, or international law</li>
                <li>Attempt to interfere with the proper working of the Site</li>
                <li>Bypass any measures we may use to prevent or restrict access to the Site</li>
                <li>Use any automated means to access the Site for any purpose without our express written permission</li>
            </ul>
            
            <h3>4. Intellectual Property</h3>
            <p>The Site and its original content, features, and functionality are owned by \(siteName) and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.</p>
            
            <h3>5. Disclaimer of Warranties</h3>
            <p>THE SITE IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS. WE MAKE NO WARRANTIES, EXPRESSED OR IMPLIED, AND HEREBY DISCLAIM AND NEGATE ALL OTHER WARRANTIES INCLUDING, WITHOUT LIMITATION, IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.</p>
            
            <h3>6. Limitation of Liability</h3>
            <p>IN NO EVENT SHALL \(siteName.uppercased()), ITS DIRECTORS, EMPLOYEES, PARTNERS, AGENTS, SUPPLIERS, OR AFFILIATES, BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING WITHOUT LIMITATION, LOSS OF PROFITS, DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES.</p>
            
            <h3>7. Indemnification</h3>
            <p>You agree to defend, indemnify, and hold harmless \(siteName) and its licensees, employees, contractors, agents, officers, and directors from and against any and all claims, damages, obligations, losses, liabilities, costs, and expenses arising from your use of the Site or violation of these Terms.</p>
            
            <h3>8. Third-Party Links</h3>
            <p>Our Site may contain links to third-party websites or services that are not owned or controlled by \(siteName). We have no control over, and assume no responsibility for, the content, privacy policies, or practices of any third-party sites.</p>
            
            <h3>9. Affiliate Disclosure</h3>
            <p>Some links on this Site may be affiliate links. We may receive a commission at no extra cost to you if you click through and make a purchase.</p>
            
            <h3>10. Governing Law</h3>
            <p>These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which \(siteName) operates, without regard to its conflict of law provisions.</p>
            
            <h3>11. Changes to Terms</h3>
            <p>We reserve the right to modify or replace these Terms at any time. It is your responsibility to review these Terms periodically.</p>
            
            <h3>12. Contact Us</h3>
            <p>If you have any questions about these Terms, please contact us at \(email).</p>
            
            <p><em>© \(year) \(siteName). All rights reserved.</em></p>
            """
            
        case .cookiePolicy:
            return """
            <h2>Cookie Policy for \(siteName)</h2>
            <p><em>Last updated: \(today)</em></p>
            
            <p>This Cookie Policy explains how \(siteName) ("we," "our," or "us") uses cookies and similar technologies on \(domain).</p>
            
            <h3>1. What Are Cookies</h3>
            <p>Cookies are small text files that are placed on your computer or mobile device when you visit a website. They are widely used to make websites work more efficiently and provide information to the owners of the site.</p>
            
            <h3>2. How We Use Cookies</h3>
            <p>We use cookies for the following purposes:</p>
            <ul>
                <li><strong>Essential Cookies:</strong> These are necessary for the website to function properly.</li>
                <li><strong>Analytics Cookies:</strong> Help us understand how visitors interact with our website (e.g., Google Analytics).</li>
                <li><strong>Preference Cookies:</strong> Remember your settings and preferences.</li>
                <li><strong>Marketing Cookies:</strong> Track your activity to deliver relevant advertisements.</li>
                <li><strong>Affiliate Cookies:</strong> Track referrals from our site to merchant partners.</li>
            </ul>
            
            <h3>3. Third-Party Cookies</h3>
            <p>We may use third-party services that place cookies on your device, including:</p>
            <ul>
                <li>Google Analytics (analytics)</li>
                <li>Amazon Associates (affiliate tracking)</li>
                <li>Other affiliate networks</li>
            </ul>
            
            <h3>4. Managing Cookies</h3>
            <p>Most web browsers allow you to control cookies through their settings. You can:</p>
            <ul>
                <li>Delete all cookies from your browser</li>
                <li>Block all cookies</li>
                <li>Allow all cookies</li>
                <li>Block third-party cookies</li>
                <li>Clear all cookies when you close the browser</li>
            </ul>
            <p>Note: Blocking cookies may impact your experience on our Site.</p>
            
            <h3>5. Changes to This Policy</h3>
            <p>We may update this Cookie Policy from time to time. Please check back periodically.</p>
            
            <h3>6. Contact Us</h3>
            <p>If you have questions about our use of cookies, please contact us at \(email).</p>
            
            <p><em>© \(year) \(siteName). All rights reserved.</em></p>
            """
            
        case .eula:
            return """
            <h2>End User License Agreement for \(siteName)</h2>
            <p><em>Last updated: \(today)</em></p>
            
            <p>This End User License Agreement ("Agreement") is a legal agreement between you ("User") and \(siteName) ("Licensor") for the use of any software, applications, or digital products provided through \(domain).</p>
            
            <h3>1. License Grant</h3>
            <p>Subject to the terms of this Agreement, Licensor grants you a limited, non-exclusive, non-transferable, revocable license to use the software for personal, non-commercial purposes.</p>
            
            <h3>2. Restrictions</h3>
            <p>You may NOT:</p>
            <ul>
                <li>Copy, modify, or distribute the software</li>
                <li>Reverse engineer, decompile, or disassemble the software</li>
                <li>Rent, lease, or lend the software to third parties</li>
                <li>Use the software for any unlawful purpose</li>
                <li>Remove any proprietary notices or labels</li>
            </ul>
            
            <h3>3. Intellectual Property</h3>
            <p>The software and all copies thereof are proprietary to Licensor and title thereto remains exclusively with Licensor. All rights not specifically granted in this Agreement are reserved by Licensor.</p>
            
            <h3>4. Disclaimer of Warranties</h3>
            <p>THE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.</p>
            
            <h3>5. Limitation of Liability</h3>
            <p>IN NO EVENT SHALL LICENSOR BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES WHATSOEVER ARISING OUT OF THE USE OF OR INABILITY TO USE THE SOFTWARE.</p>
            
            <h3>6. Indemnification</h3>
            <p>You agree to indemnify, defend, and hold harmless \(siteName), its officers, directors, employees, and agents from any claims, damages, losses, or expenses arising from your use of the software.</p>
            
            <h3>7. Termination</h3>
            <p>This license is effective until terminated. Your rights under this license will terminate automatically without notice if you fail to comply with any term of this Agreement.</p>
            
            <h3>8. Governing Law</h3>
            <p>This Agreement shall be governed by the laws of the jurisdiction in which Licensor operates.</p>
            
            <h3>9. Contact</h3>
            <p>For questions about this Agreement, contact us at \(email).</p>
            
            <p><em>© \(year) \(siteName). All rights reserved.</em></p>
            """
            
        case .affiliateDisclosure:
            return """
            <h2>Affiliate Disclosure for \(siteName)</h2>
            <p><em>Last updated: \(today)</em></p>
            
            <p>\(siteName) (\(domain)) is a participant in various affiliate advertising programs designed to provide a means for sites to earn advertising fees by advertising and linking to merchant websites.</p>
            
            <h3>1. What This Means</h3>
            <p>When you click on certain links on our Site and make a purchase, we may receive a small commission at no additional cost to you. This helps support our Site and allows us to continue providing free content.</p>
            
            <h3>2. FTC Compliance</h3>
            <p>In accordance with the Federal Trade Commission (FTC) guidelines, we disclose that:</p>
            <ul>
                <li>We may receive compensation for links and/or recommendations on this website</li>
                <li>Our opinions and reviews are our own and not influenced by compensation</li>
                <li>We only recommend products/services we believe will add value to our readers</li>
            </ul>
            
            <h3>3. Affiliate Programs We Participate In</h3>
            <p>\(siteName) participates in affiliate programs including but not limited to:</p>
            <ul>
                <li>Amazon Associates Program</li>
                <li>Various software affiliate programs</li>
                <li>Other merchant partner programs</li>
            </ul>
            
            <h3>4. Amazon Associates Disclosure</h3>
            <p>As an Amazon Associate, \(siteName) earns from qualifying purchases. Amazon and the Amazon logo are trademarks of Amazon.com, Inc. or its affiliates.</p>
            
            <h3>5. Our Commitment to You</h3>
            <p>We are committed to providing honest, unbiased reviews and recommendations. Our goal is to help you make informed decisions, not just to earn commissions.</p>
            
            <h3>6. Questions?</h3>
            <p>If you have any questions about our affiliate relationships, please contact us at \(email).</p>
            
            <p><em>© \(year) \(siteName). All rights reserved.</em></p>
            """
            
        case .disclaimer:
            return """
            <h2>Disclaimer for \(siteName)</h2>
            <p><em>Last updated: \(today)</em></p>
            
            <p>The information provided on \(domain) (the "Site") is for general informational purposes only. All information on the Site is provided in good faith, however, we make no representation or warranty of any kind regarding the accuracy, adequacy, validity, reliability, availability, or completeness of any information on the Site.</p>
            
            <h3>1. No Professional Advice</h3>
            <p>The Site cannot and does not contain professional advice. The information is provided for general informational and educational purposes only and is not a substitute for professional advice. Accordingly, before taking any actions based upon such information, we encourage you to consult with appropriate professionals.</p>
            
            <h3>2. External Links Disclaimer</h3>
            <p>The Site may contain links to external websites that are not provided or maintained by or in any way affiliated with \(siteName). Please note that we do not guarantee the accuracy, relevance, timeliness, or completeness of any information on these external websites.</p>
            
            <h3>3. Affiliate Links Disclaimer</h3>
            <p>The Site may contain affiliate links. If you click on an affiliate link and make a purchase, we may receive a commission at no extra cost to you. For more information, please see our Affiliate Disclosure.</p>
            
            <h3>4. Product Reviews Disclaimer</h3>
            <p>Our product reviews and comparisons are based on our research, testing, and honest opinions. However, individual experiences may vary. We encourage you to do your own research before making purchase decisions.</p>
            
            <h3>5. "As Is" Disclaimer</h3>
            <p>THE SITE IS PROVIDED ON AN "AS-IS" AND "AS AVAILABLE" BASIS. YOU AGREE THAT YOUR USE OF THE SITE AND OUR SERVICES WILL BE AT YOUR SOLE RISK. TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED.</p>
            
            <h3>6. Limitation of Liability</h3>
            <p>\(siteName.uppercased()) AND ITS AFFILIATES SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE, OR OTHER TORT, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THE SITE.</p>
            
            <h3>7. Hold Harmless</h3>
            <p>You agree to hold harmless \(siteName), its owners, operators, affiliates, and agents from any claims, damages, losses, or expenses (including attorney fees) that arise out of your use of the Site or any violation of these terms.</p>
            
            <h3>8. Changes to This Disclaimer</h3>
            <p>We reserve the right to make changes to this Disclaimer at any time. Please check this page periodically for updates.</p>
            
            <h3>9. Contact Us</h3>
            <p>If you have any questions about this Disclaimer, please contact us at \(email).</p>
            
            <p><em>© \(year) \(siteName). All rights reserved.</em></p>
            """
        }
    }
    
    /// Basic default content (used as fallback)
    var defaultContent: String {
        return generateContent(siteName: "[Your Site Name]", domain: "[yourdomain.com]", email: "[email@example.com]")
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
    
    /// Initialize with site-specific content
    init(pageType: LegalPageType, site: Site) {
        self.id = UUID()
        self.pageType = pageType
        self.title = pageType.rawValue
        self.contentHTML = pageType.generateContent(
            siteName: site.name,
            domain: site.domain,
            email: site.contact.email,
            address: site.contact.address
        )
        self.status = .draft
        self.version = 1
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.revisions = []
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
    
    /// Regenerate content for this page using site info
    mutating func regenerateContent(for site: Site) {
        contentHTML = pageType.generateContent(
            siteName: site.name,
            domain: site.domain,
            email: site.contact.email,
            address: site.contact.address
        )
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
