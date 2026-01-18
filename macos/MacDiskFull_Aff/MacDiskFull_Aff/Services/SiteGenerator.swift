//
//  SiteGenerator.swift
//  WebMakr
//
//  MVP Site Generator - Single comparison page with SEO
//  Compatible with macOS 11.0 (Big Sur) and later
//

import Foundation

/// MVP Site Generator - generates a single comparison landing page
class SiteGeneratorSync {
    let site: Site
    private let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
    }()
    
    init(site: Site) {
        self.site = site
    }
    
    // MARK: - Main Generate Function
    
    /// Generate the complete static site to a folder
    func generate() throws -> URL {
        let outputDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("WebMakr")
            .appendingPathComponent(site.domain.isEmpty ? "site" : site.domain.replacingOccurrences(of: ".", with: "_"))
        
        // Clean and create directory
        try? FileManager.default.removeItem(at: outputDir)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        
        // Create assets folder
        let assetsDir = outputDir.appendingPathComponent("assets")
        try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)
        
        // Generate all files
        try generateCSS(to: outputDir)
        try generateIndexHTML(to: outputDir)
        try generateRobotsTxt(to: outputDir)
        try generateSitemapXml(to: outputDir)
        try generateAssetPlaceholders(to: assetsDir)
        try generatePrettyLinks(to: outputDir) // Pro Feature
        try generateLegalPages(to: outputDir)  // Pro Feature
        
        // Multi-Page Content
        try generateArticles(to: outputDir)
        try generateStaticPages(to: outputDir)
        
        return outputDir
    }
    
    /// Generate to a user-specified folder
    func generate(to outputDir: URL) throws {
        // Create directory if needed
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        
        // Create assets folder
        let assetsDir = outputDir.appendingPathComponent("assets")
        try FileManager.default.createDirectory(at: assetsDir, withIntermediateDirectories: true)
        
        // Generate all files
        try generateCSS(to: outputDir)
        try generateIndexHTML(to: outputDir)
        try generateRobotsTxt(to: outputDir)
        try generateSitemapXml(to: outputDir)
        try generateAssetPlaceholders(to: assetsDir)
        try generatePrettyLinks(to: outputDir) // Pro Feature
        try generateLegalPages(to: outputDir)  // Pro Feature
        
        // Multi-Page Content
        try generateArticles(to: outputDir)
        try generateStaticPages(to: outputDir)
    }
    
    // MARK: - SEO Files
    
    private func generateRobotsTxt(to dir: URL) throws {
        var content = """
        User-agent: *
        Allow: /
        """
        
        if !site.domain.isEmpty {
            content += "\nSitemap: https://\(site.domain)/sitemap.xml"
        }
        
        let url = dir.appendingPathComponent("robots.txt")
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func generateSitemapXml(to dir: URL) throws {
        // Only generate if domain is set
        guard !site.domain.isEmpty else { return }
        
        let today = dateFormatter.string(from: Date())
        let content = """
        <?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          <url>
            <loc>https://\(site.domain)/</loc>
            <lastmod>\(today)</lastmod>
            <priority>1.0</priority>
          </url>
        </urlset>
        """
        
        let url = dir.appendingPathComponent("sitemap.xml")
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func generateAssetPlaceholders(to dir: URL) throws {
        // Create a simple placeholder OG image (1x1 transparent PNG)
        // In real app, you'd include actual images
        // For MVP, we'll just note that these should be added
        
        let readme = """
        # Assets Folder
        
        Add these files:
        - og-image.png (1200x630 Open Graph image)
        - favicon.png (32x32 favicon)
        
        These will be used in the generated HTML.
        """
        
        let readmeURL = dir.appendingPathComponent("README.txt")
        try readme.write(to: readmeURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - CSS Generation
    
    private func generateCSS(to dir: URL) throws {
        let primaryColor = site.theme.primaryColor
        
        let css = """
        /* WebMakr Generated CSS - \(site.name) */
        
        :root {
            --primary: \(primaryColor);
            --primary-glow: \(primaryColor)40;
            --bg-dark: #0a0a0f;
            --bg-card: rgba(255, 255, 255, 0.03);
            --border: rgba(255, 255, 255, 0.08);
            --text: #ffffff;
            --text-muted: #9ca3af;
            --success: #22c55e;
            --warning: #fbbf24;
            --danger: #ef4444;
        }
        
        *, *::before, *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        html {
            scroll-behavior: smooth;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
            background: var(--bg-dark);
            color: var(--text);
            line-height: 1.6;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 1.5rem;
        }
        
        a {
            color: var(--primary);
            text-decoration: none;
        }
        
        a:hover {
            text-decoration: underline;
        }
        
        /* ========== HEADER ========== */
        
        header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 100;
            background: rgba(10, 10, 15, 0.85);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--border);
            padding: 1rem 0;
        }
        
        header .container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 0.5rem;
        }
        
        .logo {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text);
            text-decoration: none;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 60%;
        }
        
        .logo span {
            color: var(--primary);
        }
        
        .nav-cta {
            background: var(--primary);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 9999px;
            font-weight: 600;
            font-size: 0.875rem;
            text-decoration: none;
            transition: transform 0.2s, box-shadow 0.2s;
            white-space: nowrap;
            flex-shrink: 0;
        }
        
        .nav-cta:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 20px var(--primary-glow);
            text-decoration: none;
        }
        
        /* ========== HERO ========== */
        
        .hero {
            padding: 8rem 0 4rem;
            text-align: center;
            background: radial-gradient(ellipse at 50% 0%, var(--primary-glow), transparent 60%);
        }
        
        .hero h1 {
            font-size: clamp(2rem, 5vw, 3.5rem);
            font-weight: 800;
            margin-bottom: 1rem;
            line-height: 1.1;
        }
        
        .hero .gradient-text {
            background: linear-gradient(135deg, var(--primary), #ec4899);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .hero p {
            color: var(--text-muted);
            font-size: 1.125rem;
            max-width: 600px;
            margin: 0 auto 2rem;
        }
        
        .hero-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        /* ========== BUTTONS ========== */
        
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.875rem 1.75rem;
            border-radius: 9999px;
            font-weight: 600;
            font-size: 1rem;
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
            border: none;
        }
        
        .btn-primary {
            background: var(--primary);
            color: white;
            box-shadow: 0 4px 20px var(--primary-glow);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 30px var(--primary-glow);
            text-decoration: none;
        }
        
        .btn-secondary {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text);
            border: 1px solid var(--border);
        }
        
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.1);
            text-decoration: none;
        }
        
        .btn-sm {
            padding: 0.5rem 1rem;
            font-size: 0.875rem;
        }
        
        /* ========== FEATURED PRODUCT ========== */
        
        .featured-section {
            padding: 1.5rem 0 2rem;
        }
        
        .featured-card {
            background: linear-gradient(135deg, var(--primary-glow), transparent);
            border: 1px solid var(--primary);
            border-radius: 1rem;
            padding: 2rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            max-width: 500px;
            margin: 0 auto;
        }
        
        .featured-badge {
            background: var(--primary);
            color: white;
            padding: 0.25rem 1rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 1rem;
        }
        
        .featured-card h3 {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
        }
        
        .featured-price {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--primary);
            margin: 0.5rem 0 1rem;
        }
        
        .rating {
            color: var(--warning);
            font-size: 1.25rem;
            letter-spacing: 0.1em;
        }
        
        /* ========== COMPARISON TABLE ========== */
        
        .comparison-section {
            padding: 0.5rem 0 2rem;
        }
        
        .comparison-section h2 {
            text-align: center;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        
        .comparison-section p {
            text-align: center;
            color: var(--text-muted);
            margin-bottom: 2rem;
        }
        
        /* Table wrapper for horizontal scroll on mobile */
        .table-wrapper {
            width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            border-radius: 1rem;
            border: 1px solid var(--border);
        }
        
        .comparison-table {
            width: 100%;
            min-width: 700px;
            border-collapse: collapse;
            background: var(--bg-card);
            table-layout: fixed;  /* Equal column widths */
        }
        
        .comparison-table th,
        .comparison-table td {
            padding: 1rem 0.75rem;
            text-align: center;
            border-bottom: 1px solid var(--border);
            border-right: 1px solid var(--border);  /* Vertical dividers */
            vertical-align: top;
            word-wrap: break-word;
        }
        
        /* Last column no right border */
        .comparison-table th:last-child,
        .comparison-table td:last-child {
            border-right: none;
        }
        
        /* Row label column - fixed narrow width */
        .comparison-table th:first-child,
        .comparison-table td:first-child {
            width: 80px;
            min-width: 80px;
            text-align: left;
            background: #12121a;
            font-weight: 600;
            border-right: 2px solid var(--border);
        }
        
        .comparison-table th {
            background: #1a1a25;
            font-weight: 600;
            padding: 1.25rem 0.75rem;
        }
        
        .comparison-table tbody tr:hover {
            background: rgba(255, 255, 255, 0.03);
        }
        
        /* Featured column - more prominent */
        .comparison-table .featured-col {
            background: rgba(147, 51, 234, 0.12);
            border-left: 2px solid var(--primary);
            border-right: 2px solid var(--primary);
        }
        
        .comparison-table thead .featured-col {
            background: rgba(147, 51, 234, 0.2);
            border-top: 2px solid var(--primary);
        }
        
        /* Alternating row backgrounds for readability */
        .comparison-table tbody tr:nth-child(even) {
            background: rgba(255, 255, 255, 0.02);
        }
        
        .comparison-table tbody tr:nth-child(even) .featured-col {
            background: rgba(147, 51, 234, 0.15);
        }
        
        .comparison-table .best-badge {
            background: var(--primary);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            display: inline-block;
            margin-bottom: 0.5rem;
        }
        
        .comparison-table .product-name {
            font-weight: 600;
            font-size: 1rem;
        }
        
        .comparison-table .product-price {
            color: var(--primary);
            font-weight: 700;
            margin-top: 0.25rem;
        }
        
        .comparison-table .product-rating {
            color: var(--warning);
            font-size: 0.875rem;
        }
        
        .check-yes {
            color: var(--success);
            font-weight: 600;
        }
        
        .check-no {
            color: var(--text-muted);
        }
        
        .pros-cons {
            text-align: left;
            font-size: 0.75rem;
            line-height: 1.4;
            white-space: normal;
            min-width: 120px;
        }
        
        .pros-cons .pro {
            color: var(--success);
        }
        
        .pros-cons .con {
            color: var(--danger);
        }
        
        /* ========== FOOTER ========== */
        
        footer {
            border-top: 1px solid var(--border);
            padding: 2rem 0 1.5rem;
            margin-top: 1rem;
        }
        
        .footer-content {
            text-align: center;
        }
        
        .footer-brand {
            margin-bottom: 1.5rem;
        }
        
        .footer-brand h3 {
            font-size: 1.25rem;
            margin-bottom: 0.5rem;
        }
        
        .footer-brand p {
            color: var(--text-muted);
            font-size: 0.875rem;
        }
        
        .affiliate-disclosure {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--border);
            padding: 1rem 1.5rem;
            border-radius: 0.5rem;
            font-size: 0.75rem;
            color: var(--text-muted);
            max-width: 800px;
            margin: 2rem auto;
            text-align: left;
        }
        
        .footer-bottom {
            padding-top: 1.5rem;
            color: var(--text-muted);
            font-size: 0.75rem;
        }
        
        /* ========== MOBILE PRODUCT CARDS ========== */
        
        .mobile-cards {
            display: none;  /* Hidden on desktop */
        }
        
        .product-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 1rem;
            padding: 1.25rem;
            margin-bottom: 1rem;
        }
        
        .product-card.featured {
            border-color: var(--primary);
            background: linear-gradient(180deg, rgba(147, 51, 234, 0.1) 0%, var(--bg-card) 100%);
        }
        
        .product-card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 0.75rem;
        }
        
        .product-card-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin: 0;
        }
        
        .product-card-badge {
            background: var(--primary);
            color: white;
            font-size: 0.6rem;
            padding: 0.2rem 0.5rem;
            border-radius: 9999px;
            font-weight: 700;
            text-transform: uppercase;
        }
        
        .product-card-meta {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
            font-size: 0.875rem;
        }
        
        .product-card-price {
            color: var(--primary);
            font-weight: 700;
        }
        
        .product-card-rating {
            color: var(--warning);
        }
        
        .product-card-lists {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .product-card-pros h4,
        .product-card-cons h4 {
            font-size: 0.75rem;
            margin-bottom: 0.5rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        
        .product-card-pros h4 {
            color: var(--success);
        }
        
        .product-card-cons h4 {
            color: var(--error);
        }
        
        .product-card-pros ul,
        .product-card-cons ul {
            list-style: none;
            padding: 0;
            margin: 0;
            font-size: 0.8rem;
            line-height: 1.5;
        }
        
        .product-card-pros li::before {
            content: "+ ";
            color: var(--success);
        }
        
        .product-card-cons li::before {
            content: "- ";
            color: var(--error);
        }
        
        .product-card .btn {
            width: 100%;
            text-align: center;
        }
        
        /* Free trial watermark - remove in paid version */
        .watermark {
            position: fixed;
            bottom: 10px;
            right: 10px;
            background: rgba(0,0,0,0.7);
            color: #666;
            font-size: 10px;
            padding: 4px 8px;
            border-radius: 4px;
            z-index: 9999;
        }
        
        /* ========== RESPONSIVE ========== */
        
        @media (max-width: 768px) {
            .hero {
                padding: 5rem 0 2rem;
            }
            
            .hero h1 {
                font-size: 1.75rem;
                line-height: 1.3;
            }
            
            .hero p {
                font-size: 0.95rem;
            }
            
            .featured-card {
                padding: 1.25rem;
            }
            
            .comparison-section h2 {
                font-size: 1.35rem;
            }
            
            .btn {
                padding: 0.5rem 0.75rem;
                font-size: 0.75rem;
            }
            
            /* ===== MOBILE: HIDE TABLE, SHOW CARDS ===== */
            
            .table-wrapper {
                display: none !important;  /* Hide table on mobile */
            }
            
            .mobile-cards {
                display: block !important;  /* Show cards on mobile */
            }
            
            /* Header mobile */
            .logo {
                font-size: 1rem;
                max-width: 55%;
            }
            
            .nav-cta {
                padding: 0.4rem 0.75rem;
                font-size: 0.7rem;
            }
            
            footer {
                padding: 2rem 0;
            }
            
            .affiliate-disclosure {
                font-size: 0.6rem;
                padding: 0.6rem;
            }
        }
        
        /* ========== ARTICLES & PAGES ========== */
        
        .page-content {
            padding: 4rem 0;
            min-height: 60vh;
            max-width: 800px; /* Readability */
            margin: 0 auto;
        }
        
        .article-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        
        .article-card {
            background: var(--bg-card);
            border: 1px solid var(--border);
            border-radius: 1rem;
            overflow: hidden;
            transition: transform 0.2s;
        }
        
        .article-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary);
        }
        
        .article-content {
            padding: 1.5rem;
        }
        
        .article-content h3 {
            margin-top: 0;
            font-size: 1.25rem;
        }
        
        .article-content h3 a {
            color: var(--text);
            text-decoration: none;
        }
        
        .article-content .meta {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-bottom: 1rem;
        }
        
        .read-more {
            display: inline-block;
            margin-top: 1rem;
            color: var(--primary);
            font-weight: 600;
            text-decoration: none;
        }
        
        /* Single Article Typography */
        .prose {
            font-size: 1.1rem;
            line-height: 1.7;
            color: #d1d5db;
        }
        
        .prose h1 { margin-bottom: 0.5rem; font-size: 2.5rem; color: #fff; }
        .prose h2 { margin-top: 2.5rem; margin-bottom: 1rem; font-size: 1.8rem; color: #fff; }
        .prose h3 { margin-top: 2rem; margin-bottom: 0.8rem; font-size: 1.5rem; color: #fff; }
        .prose p { margin-bottom: 1.5rem; }
        .prose ul, .prose ol { margin-bottom: 1.5rem; padding-left: 1.5rem; }
        .prose li { margin-bottom: 0.5rem; }
        .prose a { color: var(--primary); text-decoration: underline; }
        
        .article-header {
            margin-bottom: 3rem;
            border-bottom: 1px solid var(--border);
            padding-bottom: 2rem;
        }
        
        .article-meta {
            color: var(--text-muted);
        }
        
        /* Shared Header Nav */
        .desktop-nav {
            display: flex;
            gap: 2rem;
        }
        
        .desktop-nav a {
            color: var(--text-muted);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.2s;
        }
        
        .desktop-nav a:hover, .desktop-nav a.active {
            color: #fff;
        }
        
        .contact-box {
            background: var(--bg-card);
            border: 1px solid var(--border);
            padding: 2rem;
            border-radius: 1rem;
            margin: 2rem 0;
        }
        
        .footer-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr;
            gap: 2rem;
            margin-bottom: 2rem;
            text-align: left;
        }
        
        .footer-grid ul {
            list-style: none;
            padding: 0;
        }
        
        .footer-grid li {
            margin-bottom: 0.5rem;
        }
        
        .footer-grid a {
            color: var(--text-muted);
            text-decoration: none;
        }
        
        .footer-grid a:hover {
            color: var(--primary);
        }

        @media (max-width: 768px) {
            .footer-grid {
                 grid-template-columns: 1fr;
                 text-align: center;
            }
        }
        """
        
        let cssURL = dir.appendingPathComponent("style.css")
        try css.write(to: cssURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Index HTML Generation
    
    private func generateIndexHTML(to dir: URL) throws {
        let recommendedProduct = site.products.first { $0.isRecommended }
        let sortedProducts = site.products.sorted { $0.sortOrder < $1.sortOrder }
        
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            
            <!-- Primary Meta Tags -->
            <title>\(escapeHTML(site.name)) – \(escapeHTML(site.tagline))</title>
            <meta name="title" content="\(escapeHTML(site.name)) – \(escapeHTML(site.tagline))">
            <meta name="description" content="\(escapeHTML(site.tagline)). Compare the best tools and find the right solution.">
            
            <!-- Favicon -->
            <link rel="icon" type="image/png" href="assets/favicon.png">
            
            \(generateCanonicalTag())
            
            <!-- Open Graph / Facebook -->
            <meta property="og:type" content="website">
            \(site.domain.isEmpty ? "" : "<meta property=\"og:url\" content=\"https://\(site.domain)/\">")
            <meta property="og:title" content="\(escapeHTML(site.name))">
            <meta property="og:description" content="\(escapeHTML(site.tagline))">
            <meta property="og:image" content="assets/og-image.png">
            
            <!-- Twitter -->
            <meta name="twitter:card" content="summary_large_image">
            \(site.domain.isEmpty ? "" : "<meta name=\"twitter:url\" content=\"https://\(site.domain)/\">")
            <meta name="twitter:title" content="\(escapeHTML(site.name))">
            <meta name="twitter:description" content="\(escapeHTML(site.tagline))">
            <meta name="twitter:image" content="assets/og-image.png">
            
            <link rel="stylesheet" href="style.css">
            \(generateGeniusLinkScript())
        </head>
        <body>
            \(generateSharedHeader(activePage: "home"))
            
            <!-- Hero -->
            <section class="hero">
                <div class="container">
                    <h1>\(formatHeadline(site.tagline))</h1>
                    <p>Compare the best options and find the perfect solution. Honest reviews, real comparisons.</p>
                    <div class="hero-buttons">
                        <a href="#comparison" class="btn btn-primary">See the Comparison</a>
                        \(recommendedProduct != nil ? "<a href=\"\(getLink(for: recommendedProduct!))\" class=\"btn btn-secondary\" target=\"_blank\" rel=\"noopener\">Visit Top Pick →</a>" : "")
                    </div>
                </div>
            </section>
            
            \(generateFeaturedSection(recommendedProduct))
            
            <!-- Comparison Table -->
            <section id="comparison" class="comparison-section">
                <div class="container">
                    <h2>Compare Top Products</h2>
                    <p>See how the leading options stack up against each other.</p>
                    
                    <!-- Desktop: Comparison Table -->
                    <div class="table-wrapper">
                        \(generateComparisonTable(sortedProducts))
                    </div>
                    
                    <!-- Mobile: Product Cards -->
                    <div class="mobile-cards">
                        \(generateMobileCards(sortedProducts))
                    </div>
                </div>
            </section>
            
            <!-- Latest Articles -->
            <section class="latest-articles container" style="padding: 4rem 1rem;">
                <h2 style="text-align: center; margin-bottom: 2rem; font-size: 2rem;">Latest News</h2>
                <div class="article-grid">
                    \(site.articles.prefix(3).map { article in
                        """
                        <div class="article-card">
                            <div class="article-content">
                                <h3><a href="articles/\(article.slug).html">\(escapeHTML(article.title))</a></h3>
                                <p style="font-size: 0.9rem; color: var(--text-muted);">\(escapeHTML(article.summary))</p>
                                <a href="articles/\(article.slug).html" class="read-more">Read →</a>
                            </div>
                        </div>
                        """
                    }.joined(separator: "\n"))
                </div>
                <div style="text-align: center; margin-top: 2rem;">
                    <a href="articles.html" class="btn btn-secondary">View All Articles</a>
                </div>
            </section>
            
            \(generateSharedFooter())
            
            <!-- WebMakr Watermark (remove in paid version) -->
            <div class="watermark">Built with WebMakr</div>
        </body>
        </html>
        """
        
        let indexURL = dir.appendingPathComponent("index.html")
        try html.write(to: indexURL, atomically: true, encoding: .utf8)
    }
    
    // MARK: - Helper Methods
    
    func escapeHTML(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
    
    private func generateCanonicalTag() -> String {
        guard !site.domain.isEmpty else { return "" }
        return "<link rel=\"canonical\" href=\"https://\(site.domain)/\">"
    }
    
    func formatLogo(_ name: String) -> String {
        if name.lowercased().contains(".com") {
            let parts = name.components(separatedBy: ".")
            if parts.count >= 2 {
                return "\(parts[0])<span>.\(parts[1])</span>"
            }
        }
        return escapeHTML(name)
    }
    
    func formatHeadline(_ tagline: String) -> String {
        // Add gradient effect to question marks or last word
        if tagline.contains("?") {
            let parts = tagline.components(separatedBy: "?")
            return "\(escapeHTML(parts[0]))<span class=\"gradient-text\">?</span>"
        }
        return escapeHTML(tagline)
    }
    
    private func generateFeaturedSection(_ product: Product?) -> String {
        guard let product = product else { return "" }
        
        let stars = String(repeating: "★", count: Int(product.rating)) + String(repeating: "☆", count: 5 - Int(product.rating)) + " \(product.rating)"
        
        return """
        <!-- Featured Product -->
        <section class="featured-section">
            <div class="container">
                <div class="featured-card">
                    <span class="featured-badge">⭐ Our Top Pick</span>
                    <h3>\(escapeHTML(product.name))</h3>
                    <p class="rating">\(stars)</p>
                    <p class="featured-price">\(escapeHTML(product.price))</p>
                    <p style="color: var(--text-muted); margin-bottom: 1rem;">\(escapeHTML(product.shortDescription))</p>
                    <a href="\(getLink(for: product))" class="btn btn-primary" target="_blank" rel="noopener">
                        Visit \(escapeHTML(product.name)) →
                    </a>
                </div>
            </div>
        </section>
        """
    }
    
    private func generateComparisonTable(_ products: [Product]) -> String {
        guard !products.isEmpty else {
            return "<p style=\"text-align: center; color: var(--text-muted);\">No products to compare yet.</p>"
        }
        
        var html = """
        <table class="comparison-table">
            <thead>
                <tr>
                    <th style="min-width: 100px;"></th>
        """
        
        // Header row with product names
        for product in products {
            let featuredClass = product.isRecommended ? " featured-col" : ""
            html += """
                    <th class="\(featuredClass)">
                        \(product.isRecommended ? "<span class=\"best-badge\">Best Choice</span><br>" : "")
                        <span class="product-name">\(escapeHTML(product.name))</span><br>
                        <span class="product-rating">\(String(repeating: "★", count: Int(product.rating)))\(String(repeating: "☆", count: 5 - Int(product.rating))) \(product.rating)</span><br>
                        <span class="product-price">\(escapeHTML(product.price))</span>
                    </th>
            """
        }
        
        html += """
                </tr>
            </thead>
            <tbody>
        """
        
        // Pros row
        html += "<tr><td><strong>Pros</strong></td>"
        for product in products {
            let featuredClass = product.isRecommended ? " featured-col" : ""
            let prosHTML = product.pros.prefix(3).map { "<span class=\"pro\">+ \(escapeHTML($0))</span>" }.joined(separator: "<br>")
            html += "<td class=\"pros-cons\(featuredClass)\">\(prosHTML.isEmpty ? "-" : prosHTML)</td>"
        }
        html += "</tr>"
        
        // Cons row
        html += "<tr><td><strong>Cons</strong></td>"
        for product in products {
            let featuredClass = product.isRecommended ? " featured-col" : ""
            let consHTML = product.cons.prefix(3).map { "<span class=\"con\">- \(escapeHTML($0))</span>" }.joined(separator: "<br>")
            html += "<td class=\"pros-cons\(featuredClass)\">\(consHTML.isEmpty ? "-" : consHTML)</td>"
        }
        html += "</tr>"
        
        // Type row
        html += "<tr><td>Type</td>"
        for product in products {
            let featuredClass = product.isRecommended ? " featured-col" : ""
            html += "<td class=\"\(featuredClass)\">\(product.productType.rawValue)</td>"
        }
        html += "</tr>"
        
        // CTA row
        html += "<tr><td></td>"
        for product in products {
            let featuredClass = product.isRecommended ? " featured-col" : ""
            let btnClass = product.isRecommended ? "btn-primary" : "btn-secondary"
            html += """
                <td class="\(featuredClass)">
                    <a href="\(getLink(for: product))" class="btn btn-sm \(btnClass)" target="_blank" rel="noopener">
                        \(product.isRecommended ? "Visit Site →" : "View Details")
                    </a>
                </td>
            """
        }
        html += "</tr>"
        
        html += """
            </tbody>
        </table>
        """
        
        return html
    }
    
    private func generateMobileCards(_ products: [Product]) -> String {
        var html = ""
        
        for product in products {
            let featuredClass = product.isRecommended ? " featured" : ""
            let stars = String(repeating: "★", count: Int(product.rating)) + String(repeating: "☆", count: 5 - Int(product.rating)) + " \(product.rating)"
            let btnClass = product.isRecommended ? "btn-primary" : "btn-secondary"
            
            let prosHTML = product.pros.prefix(3).map { "<li>\(escapeHTML($0))</li>" }.joined()
            let consHTML = product.cons.prefix(3).map { "<li>\(escapeHTML($0))</li>" }.joined()
            
            html += """
            <div class="product-card\(featuredClass)">
                <div class="product-card-header">
                    <h3 class="product-card-title">\(escapeHTML(product.name))</h3>
                    \(product.isRecommended ? "<span class=\"product-card-badge\">Best Choice</span>" : "")
                </div>
                
                <div class="product-card-meta">
                    <span class="product-card-price">\(escapeHTML(product.price))</span>
                    <span class="product-card-rating">\(stars)</span>
                </div>
                
                <div class="product-card-lists">
                    <div class="product-card-pros">
                        <h4>Pros</h4>
                        <ul>\(prosHTML.isEmpty ? "<li>-</li>" : prosHTML)</ul>
                    </div>
                    <div class="product-card-cons">
                        <h4>Cons</h4>
                        <ul>\(consHTML.isEmpty ? "<li>-</li>" : consHTML)</ul>
                    </div>
                </div>
                
                <a href="\(getLink(for: product))" class="btn \(btnClass)" target="_blank" rel="noopener">
                    \(product.isRecommended ? "Visit Site →" : "View Details")
                </a>
            </div>
            """
        }
        
        return html
    }
}

extension SiteGeneratorSync {
    
    // MARK: - Pro Features Generators
    
    func generatePrettyLinks(to dir: URL) throws {
        guard site.usePrettyLinks else { return }
        
        let goDir = dir.appendingPathComponent("go")
        try FileManager.default.createDirectory(at: goDir, withIntermediateDirectories: true)
        
        for product in site.products {
            // 1. Check for Cloaking Bans (e.g. Amazon)
            // If banned, we DO NOT generate a redirect page.
            if let networkId = product.affiliateNetworkId {
                 // Check DB
                 if let program = AffiliateDatabase.shared.programs.first(where: { $0.name == networkId }),
                    program.bansCloaking == true {
                     continue
                 }
                 // Legacy check
                 if networkId == "Amazon Associates" { continue }
            }
            
            // Slugify name
            let slug = product.name.lowercased()
                .replacingOccurrences(of: " ", with: "-")
                .components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
            
            guard !slug.isEmpty, !product.affiliateLink.isEmpty else { continue }
            
            let productDir = goDir.appendingPathComponent(slug)
            try FileManager.default.createDirectory(at: productDir, withIntermediateDirectories: true)
            
            // THIRSTY TRACKING: Add GA4 Event
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="robots" content="noindex, nofollow">
                <meta http-equiv="refresh" content="0; url=\(product.affiliateLink)" />
                <title>Redirecting to \(product.name)...</title>
                <script>
                    window.location.href = "\(product.affiliateLink)";
                    
                    // Thirsty-style Click Tracking (Google Analytics 4)
                    // You would replace G-XXXXXXXXXX with your ID in Site Settings
                    /*
                    window.dataLayer = window.dataLayer || [];
                    function gtag(){dataLayer.push(arguments);}
                    gtag('js', new Date());
                    gtag('config', 'G-XXXXXXXXXX');
                    gtag('event', 'affiliate_click', {
                      'event_category': 'Affiliate',
                      'event_label': '\(product.name)',
                      'transport_type': 'beacon'
                    });
                    */
                </script>
            </head>
            <body>
                <p>Redirecting to \(product.name)... <a href='\(product.affiliateLink)'>Click here if not redirected.</a></p>
            </body>
            </html>
            """
            
            try html.write(to: productDir.appendingPathComponent("index.html"), atomically: true, encoding: .utf8)
        }
    }
    
    func generateLegalPages(to dir: URL) throws {
        guard site.generateLegalPages else { return }
        
        // Privacy Policy
        let privacy = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Privacy Policy - \(site.name)</title>
            <link rel="stylesheet" href="style.css">
            <style>
                body { max-width: 800px; margin: 0 auto; padding: 2rem; line-height: 1.6; font-family: sans-serif; color: #333; }
                h1, h2, h3 { color: #111; }
                a { color: \(site.theme.primaryColor); text-decoration: none; }
                .container { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
                body.dark-mode { background: #111; color: #eee; }
                body.dark-mode .container { background: #222; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Privacy Policy</h1>
                <p>Last updated: \(dateFormatter.string(from: Date()))</p>
                
                <p>This Privacy Policy describes how \(site.name) (the "Site") collects, uses, and discloses your Personal Information when you visit or make a purchase from the Site.</p>
                
                <h2>Affiliate Disclosure</h2>
                <p>\(site.affiliateSettings.defaultAffiliateDisclosure)</p>
                
                <h2>Information Collection</h2>
                <p>We do not collect personal information directly. However, third-party services (like analytics or affiliate partners) may use cookies.</p>
                
                <h2>Contact Us</h2>
                <p>For more information about our privacy practices, please contact us.</p>
                
                <p style="margin-top: 2rem;"><a href="index.html">← Back to Home</a></p>
            </div>
        </body>
        </html>
        """
        try privacy.write(to: dir.appendingPathComponent("privacy.html"), atomically: true, encoding: .utf8)
        
        // Terms
        let terms = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Terms of Service - \(site.name)</title>
            <link rel="stylesheet" href="style.css">
            <style>
                body { max-width: 800px; margin: 0 auto; padding: 2rem; line-height: 1.6; font-family: sans-serif; color: #333; }
                h1, h2, h3 { color: #111; }
                a { color: \(site.theme.primaryColor); text-decoration: none; }
                .container { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Terms of Service</h1>
                 <p>Last updated: \(dateFormatter.string(from: Date()))</p>
                
                <p>Please read these Terms of Service completely using \(site.domain.isEmpty ? site.name : site.domain) which is owned and operated by \(site.name).</p>
                
                <p>By using or accessing the Site in any way, viewing or browsing the Site, or adding your own content to the Site, you are agreeing to be bound by these Terms of Service.</p>
                
                <h2>Intellectual Property</h2>
                <p>The Site and all of its original content are the sole property of \(site.name) and are, as such, fully protected by the appropriate international copyright and other intellectual property rights laws.</p>
                
                <h2>Disclaimer</h2>
                <p>All content is for informational purposes only. We make no representations as to accuracy, completeness, currentness, suitability, or validity of any information on this site.</p>
                
                <p style="margin-top: 2rem;"><a href="index.html">← Back to Home</a></p>
            </div>
        </body>
        </html>
        """
        try terms.write(to: dir.appendingPathComponent("terms.html"), atomically: true, encoding: .utf8)
    }
    
    // Helper to determine accurate link (Raw vs Pretty)
    func getLink(for product: Product) -> String {
        guard site.usePrettyLinks else { return product.affiliateLink }
        
        // 1. Check for Cloaking Bans (Amazon)
        if let networkId = product.affiliateNetworkId {
             if let program = AffiliateDatabase.shared.programs.first(where: { $0.name == networkId }),
                program.bansCloaking == true {
                 return product.affiliateLink
             }
             if networkId == "Amazon Associates" { return product.affiliateLink }
        }
        
        let slug = product.name.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        
        if slug.isEmpty || product.affiliateLink.isEmpty {
            return product.affiliateLink
        }
        
        // Return pretty path (with index.html for local file testing)
        return "go/\(slug)/index.html"
    }
    
    func generateGeniusLinkScript() -> String {
        guard !site.affiliateSettings.geniusLinkTSID.isEmpty else { return "" }
        return """
        <!-- Amazon Link Engine (GeniusLink) -->
        <script src="//cdn.gei.us/snippet.js" async></script>
        <script>
            document.addEventListener("DOMContentLoaded", function() {
                if (typeof GeiUs !== 'undefined') {
                    GeiUs.snippet.config.tsid = \(site.affiliateSettings.geniusLinkTSID);
                }
            });
        </script>
        """
    }
}
