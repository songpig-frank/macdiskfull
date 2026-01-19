
//
//  SiteGenerator+Pages.swift
//  WebMakr
//
//  Extension to handle multi-page generation (Articles, About, Contact)
//

import Foundation

extension SiteGeneratorSync {
    
    // MARK: - Article Generation
    
    func generateArticles(to dir: URL) throws {
        // 1. Create articles directory
        let articlesDir = dir.appendingPathComponent("articles")
        try FileManager.default.createDirectory(at: articlesDir, withIntermediateDirectories: true)
        
        // 2. Generate Reference (Index) Page for Articles
        try generateArticleIndex(to: dir.appendingPathComponent("articles.html"))
        
        // 3. Generate each Article
        for article in site.articles where article.status == .published {
            let filename = (article.slug.isEmpty ? "article-\(article.id)" : article.slug) + ".html"
            let url = articlesDir.appendingPathComponent(filename)
            try generateSingleArticle(article, to: url)
        }
    }
    
    private func generateArticleIndex(to url: URL) throws {
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Articles – \(escapeHTML(site.name))</title>
            <meta name="description" content="Latest news comparisons and guides for Mac users.">
            <link rel="stylesheet" href="style.css">
            <link rel="icon" href="\(getAssetURL(site.faviconURL, defaultName: "favicon"))">
        </head>
        <body>
            \(generateSharedHeader(activePage: "articles"))
            
            <main class="page-content container">
                <h1>Latest Articles</h1>
                <p class="lead">Guides, comparisons, and news for Mac users.</p>
                
                <div class="article-grid">
                <div class="article-grid">
                    \(site.articles
                        .filter { $0.status == .published }
                        .sorted { $0.publishedDate > $1.publishedDate }
                        .map { article in
                        """
                        <div class="article-card">
                            <div class="article-content">
                                <h3><a href="articles/\(article.slug).html">\(escapeHTML(article.title))</a></h3>
                                <div class="meta">\(formatDate(article.publishedDate)) • \(escapeHTML(article.author))</div>
                                <p>\(escapeHTML(article.summary))</p>
                                <a href="articles/\(article.slug).html" class="read-more">Read Article →</a>
                            </div>
                        </div>
                        """
                    }.joined(separator: "\n"))
                </div>
            </main>
            
            \(generateSharedFooter())
        </body>
        </html>
        """
        
        try html.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func generateSingleArticle(_ article: Article, to url: URL) throws {
        // Adjust style.css path since we are in /articles/ subfolder
        let relativeCSS = "../style.css"
        
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>\(escapeHTML(article.title)) – \(escapeHTML(site.name))</title>
            <meta name="description" content>\(escapeHTML(article.summary))">
            
            <!-- Open Graph -->
            <meta property="og:title" content="\(escapeHTML(article.title))">
            <meta property="og:description" content="\(escapeHTML(article.summary))">
            <meta property="og:type" content="article">
            
            <link rel="stylesheet" href="\(relativeCSS)">
            <link rel="icon" href="../\(getAssetURL(site.faviconURL, defaultName: "favicon"))">
        </head>
        <body>
            \(generateSharedHeader(activePage: "articles", depth: 1))
            
            <main class="page-content container">
                <article class="prose">
                    <header class="article-header">
                        <h1>\(escapeHTML(article.title))</h1>
                        <div class="article-meta">
                            <span>By \(escapeHTML(article.author))</span>
                            <span>•</span>
                            <span>\(formatDate(article.publishedDate))</span>
                        </div>
                    </header>
                    
                    <div class="article-body">
                        \(article.contentHTML)
                    </div>
                    
                    <!-- Related / Disclaimer -->
                    <div class="article-footer">
                        <p class="disclaimer"><em>Note: We may earn a commission from links in this article.</em></p>
                    </div>
                </article>
            </main>
            
            \(generateSharedFooter(depth: 1))
        </body>
        </html>
        """
        
        try html.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    }
    
    // MARK: - Static Pages
    
    func generateStaticPages(to dir: URL) throws {
        try generateAboutPage(to: dir.appendingPathComponent("about.html"))
        try generateContactPage(to: dir.appendingPathComponent("contact.html"))
        try generateDisclosurePage(to: dir.appendingPathComponent("disclosure.html"))
    }
    
    private func generateAboutPage(to url: URL) throws {
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>About Us – \(escapeHTML(site.name))</title>
            <link rel="stylesheet" href="style.css">
        </head>
        <body>
            \(generateSharedHeader(activePage: "about"))
            
            <main class="page-content container">
                <h1>About Us</h1>
                <p>Welcome to <strong>\(escapeHTML(site.name))</strong>.</p>
                
                <p>We are a team of Mac enthusiasts dedicated to solving the most annoying problems Apple users face: running out of storage, slow performance, and confusing software choices.</p>
                
                <h2>Our Mission</h2>
                <p>With the release of Apple Silicon (M1, M2, M3, M4), Macs have become faster than ever. But the base storage options often feel stuck in the past. 256GB is simply not enough for modern professionals.</p>
                <p>That's why we built this site: to provide honest comparisons of disk cleaning tools, external storage solutions, and optimization guides.</p>
                
                <h2>Why trust us?</h2>
                <ul>
                    <li>We test every piece of software we recommend.</li>
                    <li>We actually use these Macs daily.</li>
                    <li>We prioritize privacy and transparency.</li>
                </ul>
            </main>
            
            \(generateSharedFooter())
        </body>
        </html>
        """
        try html.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func generateContactPage(to url: URL) throws {
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Contact Us – \(escapeHTML(site.name))</title>
            <link rel="stylesheet" href="style.css">
        </head>
        <body>
            \(generateSharedHeader(activePage: "contact"))
            
            <main class="page-content container">
                <h1>Contact Us</h1>
                <p>Have a question or a tip? We'd love to hear from you.</p>
                
                <div class="contact-box">
                    <p><strong>Email:</strong> support@macdiskfull.com</p>
                    <p><strong>Twitter:</strong> @MacDiskFull</p>
                </div>
                
                <p class="tiny-text">Please allow 24-48 hours for a response.</p>
            </main>
            
            \(generateSharedFooter())
        </body>
        </html>
        """
        try html.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func generateDisclosurePage(to url: URL) throws {
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Affiliate Disclosure – \(escapeHTML(site.name))</title>
            <link rel="stylesheet" href="style.css">
        </head>
        <body>
            \(generateSharedHeader(activePage: ""))
            
            <main class="page-content container">
                <h1>Affiliate Disclosure</h1>
                <div class="prose">
                    <p>\(escapeHTML(site.affiliateSettings.defaultAffiliateDisclosure))</p>
                    <p>MacDiskFull.com is a participant in the Amazon Services LLC Associates Program, an affiliate advertising program designed to provide a means for sites to earn advertising fees by advertising and linking to Amazon.com.</p>
                    <p>We also participate in other affiliate programs including Impact, PartnerStack, and Lemon Squeezy.</p>
                    <p>However, our editors are not paid to write favorable reviews. All opinions are our own.</p>
                </div>
            </main>
            
            \(generateSharedFooter())
        </body>
        </html>
        """
        try html.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    }
    
    // MARK: - Shared Components
    
    /// Depth indicates how deep we are in folders. 0 = root, 1 = /articles/
    func generateSharedHeader(activePage: String, depth: Int = 0) -> String {
        let prefix = depth == 0 ? "" : "../"
        
        return """
        <header>
            <div class="container">
                <a href="\(prefix)index.html" class="logo">
                    \(formatLogo(site.name))
                </a>
                <nav class="desktop-nav">
                    <a href="\(prefix)index.html" class="\(activePage == "home" ? "active" : "")">Home</a>
                    <a href="\(prefix)articles.html" class="\(activePage == "articles" ? "active" : "")">Articles</a>
                    <a href="\(prefix)about.html" class="\(activePage == "about" ? "active" : "")">About</a>
                    <a href="\(prefix)contact.html" class="\(activePage == "contact" ? "active" : "")">Contact</a>
                </nav>
                <div class="mobile-menu-btn">☰</div>
            </div>
        </header>
        """
    }
    
    func generateSharedFooter(depth: Int = 0) -> String {
        let prefix = depth == 0 ? "" : "../"
        
        return """
        <footer>
            <div class="container">
                <div class="footer-grid">
                    <div class="col">
                        <h4>\(escapeHTML(site.name))</h4>
                        <p class="footer-desc">\(escapeHTML(site.tagline))</p>
                    </div>
                    <div class="col">
                        <h4>Company</h4>
                        <ul>
                            <li><a href="\(prefix)about.html">About</a></li>
                            <li><a href="\(prefix)contact.html">Contact</a></li>
                            <li><a href="\(prefix)privacy.html">Privacy</a></li>
                        </ul>
                    </div>
                    <div class="col">
                        <h4>Articles</h4>
                        <ul>
                            <li><a href="\(prefix)articles.html">Latest News</a></li>
                            <li><a href="\(prefix)index.html#comparison">Comparison</a></li>
                        </ul>
                    </div>
                </div>
                
                <div class="affiliate-disclosure">
                    \(escapeHTML(site.affiliateSettings.defaultAffiliateDisclosure))
                    <br><a href="\(prefix)disclosure.html">Read Full Disclosure</a>
                </div>
                
                <div class="footer-bottom">
                    &copy; \(Calendar.current.component(.year, from: Date())) \(escapeHTML(site.name)). All rights reserved.
                </div>
            </div>
        </footer>
        """
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
