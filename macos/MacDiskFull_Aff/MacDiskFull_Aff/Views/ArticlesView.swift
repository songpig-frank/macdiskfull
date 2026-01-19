
//
//  ArticlesView.swift
//  WebMakr
//
//  Manage Blog Articles (CMS)
//

import SwiftUI
import UniformTypeIdentifiers

struct ArticlesView: View {
    @Binding var site: Site
    @State private var editingArticleId: UUID?
    @State private var showAIWriter: Bool = false
    @State private var confirmingRestore = false
    @State private var isTargeted: Bool = false
    
    var body: some View {
        ZStack {
            // MAIN CONTENT
            List {
                ForEach(site.articles) { article in
                    Button(action: { editingArticleId = article.id }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(article.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    // Status Badge
                                    Text(article.status.rawValue)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(statusColor(article.status).opacity(0.2))
                                        .foregroundColor(statusColor(article.status))
                                        .cornerRadius(4)
                                }
                                
                                HStack(spacing: 8) {
                                    Text(article.slug)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    
                                    if let score = article.seoScore {
                                        Text("SEO: \(score)")
                                            .font(.caption2)
                                            .foregroundColor(score >= 80 ? .green : (score >= 50 ? .orange : .red))
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if let idx = site.articles.firstIndex(where: { $0.id == article.id }) {
                                    site.articles.remove(at: idx)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red.opacity(0.7))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onDelete(perform: delete)
            }
            .listStyle(InsetListStyle())
            
            // EDITOR OVERLAY (Custom Modal)
            if let uuid = editingArticleId, let index = site.articles.firstIndex(where: { $0.id == uuid }) {
                // Dimmed Background
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Optional: Tap outside to close
                        // editingArticleId = nil 
                    }
                    .transition(.opacity)
                
                // Editor Window
                ArticleEditorView(site: $site, article: $site.articles[index]) {
                    editingArticleId = nil
                }
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
                .padding(30) // The "Margin" you requested (shows what's behind)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .id(uuid) // Force identity
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
        .overlay(
            Group {
                if isTargeted {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 3)
                        .background(Color.accentColor.opacity(0.1))
                }
            }
        )
        .navigationTitle("Articles")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button(action: importMarkdown) {
                        Label("Import MD", systemImage: "arrow.down.doc")
                    }
                    .help("Import article from Markdown file")

                    Button(action: { showAIWriter = true }) {
                        Label("AI Writer", systemImage: "sparkles")
                    }
                    .help("Generate new articles from YouTube")
                    
                    Button(action: addArticle) {
                        Label("Add Article", systemImage: "plus")
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) { 
                 Button("Restore Defaults") {
                    confirmingRestore = true
                }
                .help("Reloads the high-quality default articles")
            }
        }
        .alert(isPresented: $confirmingRestore) {
            Alert(
                title: Text("Restore Default Articles"),
                message: Text("Are you sure? This will DELETE all your current articles and replace them with the sample data. This cannot be undone."),
                primaryButton: .destructive(Text("Restore & Replace")) {
                    site.articles = Site.sampleMacDiskFull.articles
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showAIWriter) {
            AIGeneratorView(site: $site) { newArticle in
                site.articles.insert(newArticle, at: 0)
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        site.articles.remove(atOffsets: offsets)
    }
    
    func addArticle() {
        let newArticle = Article(
            title: "New Post",
            slug: "new-post-\(Int(Date().timeIntervalSince1970))",
            summary: "Short summary...",
            contentHTML: "<p>Content</p>"
        )
        site.articles.insert(newArticle, at: 0)
        editingArticleId = newArticle.id // Auto-open
    }
    


    func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url, let content = try? String(contentsOf: url, encoding: .utf8) {
                        DispatchQueue.main.async {
                            let article = parseMarkdownToArticle(content, filename: url.deletingPathExtension().lastPathComponent)
                    site.articles.insert(article, at: 0)
                        }
                    }
                }
            }
        }
        return true
    }
    
    func importMarkdown() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["md", "markdown", "txt"]
        panel.allowsMultipleSelection = true
        panel.message = "Select Markdown files to import"
        
        panel.begin { response in
            guard response == .OK else { return }
            
            for url in panel.urls {
                if let content = try? String(contentsOf: url, encoding: .utf8) {
                    let article = parseMarkdownToArticle(content, filename: url.deletingPathExtension().lastPathComponent)
                    site.articles.append(article)
                }
            }
        }
    }
    
    // Advanced parser with YAML Frontmatter support
    func parseMarkdownToArticle(_ rawContent: String, filename: String) -> Article {
        var title = filename.replacingOccurrences(of: "-", with: " ").capitalized
        var slug = filename.lowercased().replacingOccurrences(of: " ", with: "-")
        var summary = "No summary available."
        var author = "Editorial Team"
        var contentBody = rawContent
        
        // 1. Check for YAML Frontmatter
        if rawContent.hasPrefix("---") {
            let components = rawContent.components(separatedBy: "---")
            if components.count >= 3 {
                // components[0] is empty (before first ---)
                // components[1] is the YAML block
                // components[2...] is the content
                
                let yamlBlock = components[1]
                contentBody = components.dropFirst(2).joined(separator: "---").trimmingCharacters(in: .whitespacesAndNewlines)
                
                let yamlLines = yamlBlock.components(separatedBy: .newlines)
                for line in yamlLines {
                    let parts = line.split(separator: ":", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
                    if parts.count == 2 {
                        let key = parts[0]
                        let value = parts[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                        
                        switch key {
                        case "title": title = value
                        case "slug": slug = value
                        case "description": summary = value
                        case "author": author = value
                        default: break
                        }
                    }
                }
            }
        } else {
            // Fallback to simple parser if no YAML
            if let firstLine = rawContent.components(separatedBy: .newlines).first, firstLine.hasPrefix("# ") {
                 title = String(firstLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                 contentBody = String(rawContent.dropFirst(firstLine.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // 1.5 Strip AI Artifacts from content
        contentBody = stripAIArtifacts(contentBody)
        
        // 2. Convert Body to HTML (Simple Parser)
        var html = ""
        var inList = false
        let lines = contentBody.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty {
                if inList { html += "</ul>\n"; inList = false }
                continue
            }
            
            // Headers
            if trimmed.hasPrefix("# ") {
                 // Skip H1 in body if it matches title, otherwise render
                 // Usually articles shouldn't have H1 in body, but let's handle it
                 html += "<h1>\(trimmed.dropFirst(2))</h1>\n"
            }
            else if trimmed.hasPrefix("## ") {
                if inList { html += "</ul>\n"; inList = false }
                html += "<h2>\(trimmed.dropFirst(3))</h2>\n"
            } else if trimmed.hasPrefix("### ") {
                if inList { html += "</ul>\n"; inList = false }
                html += "<h3>\(trimmed.dropFirst(4))</h3>\n"
            }
            // Lists
            else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                if !inList { html += "<ul>\n"; inList = true }
                let item = trimmed.dropFirst(2)
                html += "<li>\(processInlineFormatting(String(item)))</li>\n"
            }
            // Horizontal Rule
            else if trimmed == "---" || trimmed == "***" {
                 if inList { html += "</ul>\n"; inList = false }
                 html += "<hr>\n"
            }
            // Paragraphs
            else {
                if inList { html += "</ul>\n"; inList = false }
                // Only wrap in p if it's not a block element (naive check)
                if !trimmed.hasPrefix("<") {
                    html += "<p>\(processInlineFormatting(trimmed))</p>\n"
                } else {
                    html += trimmed + "\n"
                }
            }
        }
        
        if inList { html += "</ul>\n" }
        
        return Article(
            title: title,
            slug: slug,
            summary: summary,
            contentHTML: html,
            author: author
        )
    }
    
    func processInlineFormatting(_ text: String) -> String {
        var res = text
        // Bold **text**
        res = res.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "<strong>$1</strong>", options: .regularExpression)
        // Italic *text*
        res = res.replacingOccurrences(of: "\\*(.*?)\\*", with: "<em>$1</em>", options: .regularExpression)
        // Link [Title](url)
        res = res.replacingOccurrences(of: "\\[(.*?)\\]\\((.*?)\\)", with: "<a href=\"$2\">$1</a>", options: .regularExpression)
        return res
    }
    
    /// Returns the appropriate color for article status
    func statusColor(_ status: ArticleStatus) -> Color {
        switch status {
        case .draft: return .orange
        case .published: return .green
        case .archived: return .gray
        }
    }
    
    /// Returns the appropriate color for SEO score
    func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return .green }
        if score >= 60 { return .orange }
        return .red
    }
    
    /// Returns a label for the SEO score
    func scoreLabel(_ score: Int) -> String {
        if score >= 90 { return "Excellent" }
        if score >= 80 { return "Good" }
        if score >= 60 { return "Needs Work" }
        if score >= 40 { return "Poor" }
        return "Critical"
    }
    
    /// Remove common AI chatbot artifacts from imported content
    func stripAIArtifacts(_ content: String) -> String {
        var cleaned = content
        
        // Patterns that indicate AI conversation chatter (case-insensitive line removal)
        let artifactPatterns = [
            "(?i)^.*here is the article.*$",
            "(?i)^.*here's the article.*$",
            "(?i)^.*here is a.*article.*$",
            "(?i)^.*i hope this helps.*$",
            "(?i)^.*let me know if you need.*$",
            "(?i)^.*feel free to.*$",
            "(?i)^.*please let me know.*$",
            "(?i)^sure!.*$",
            "(?i)^certainly!.*$",
            "(?i)^of course!.*$",
            "(?i)^absolutely!.*$",
            "(?i)^.*as an ai.*$",
            "(?i)^.*as a language model.*$",
            "(?i)^sources:.*$",
            "(?i)^references:.*$",
            "(?i)^citations:.*$",
            "(?i)^\\[sources\\].*$",
            "(?i)^note:.*ai.*$",
            "(?i)^\\*\\*note:\\*\\*.*$"
        ]
        
        for pattern in artifactPatterns {
            cleaned = cleaned.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        }
        
        // Remove multiple consecutive blank lines
        while cleaned.contains("\n\n\n") {
            cleaned = cleaned.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}



// UUID wrapper for Sheet .item
struct WrappedUUID: Identifiable {
    let uuid: UUID
    var id: UUID { uuid }
}

struct ArticleEditorView: View {
    @Binding var site: Site
    @Binding var article: Article
    var onClose: () -> Void
    @State private var selectedTab: Int = 0
    @State private var isPolishing: Bool = false
    @State private var pendingPolishedResult: PolishedResult? = nil
    @State private var showComparison: Bool = false
    @State private var showImageAssistant: Bool = false
    @State private var isAnalyzing: Bool = false
    @State private var lastAnalysis: AIContentService.ContentAnalysis? = nil
    @State private var showNoImagesWarning: Bool = false
    
    // Detect if article has real images (not placeholders)
    private var hasRealImages: Bool {
        let html = article.contentHTML.lowercased()
        let hasImg = html.contains("<img")
        let isPlaceholder = html.contains("placehold.co") || html.contains("placeholder")
        return hasImg && !isPlaceholder
    }
    
    private var imageStatus: (icon: String, color: Color, label: String) {
        let html = article.contentHTML.lowercased()
        if !html.contains("<img") {
            return ("photo.badge.plus", .orange, "No Images")
        } else if html.contains("placehold.co") || html.contains("placeholder") {
            return ("photo.badge.exclamationmark", .yellow, "Placeholders")
        } else {
            return ("photo.badge.checkmark", .green, "Has Images")
        }
    }
    
    enum ActiveAlert: Identifiable {
        case error(String)
        case analysis(AIContentService.ContentAnalysis)
        case noImagesWarning
        var id: String {
            switch self {
            case .error: return "error"
            case .analysis: return "analysis"
            case .noImagesWarning: return "noImagesWarning"
            }
        }
    }
    @State private var activeAlert: ActiveAlert?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
            
                // Custom Header
                HStack {
                    Text(selectedTab == 0 ? "Edit Article" : "Preview")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if let result = pendingPolishedResult {
                        Text("Reviewing Polish...")
                            .foregroundColor(.blue)
                        Button("Discard") {
                            pendingPolishedResult = nil
                            showComparison = false
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.red)
                    } else if isPolishing {
                        ProgressView("Polishing...")
                            .scaleEffect(0.8)
                    } else if isAnalyzing {
                        ProgressView("Analyzing...")
                            .scaleEffect(0.8)
                    } else {
                        // Image Status Indicator
                        HStack(spacing: 4) {
                            Image(systemName: imageStatus.icon)
                                .foregroundColor(imageStatus.color)
                            Text(imageStatus.label)
                                .font(.caption)
                                .foregroundColor(imageStatus.color)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(imageStatus.color.opacity(0.1))
                        .cornerRadius(6)
                        
                        Divider().frame(height: 20)
                        
                        // 1. IMAGE MAGIC (First priority)
                        Button(action: { showImageAssistant = true }) {
                            Label("Image Magic", systemImage: "photo.on.rectangle")
                        }
                        .help("Add or generate images for this article")
                        
                        // 2. CHECK SEO SCORE
                        Button(action: {
                            analyzeContent()
                        }) {
                            Label("Check Score", systemImage: "chart.bar")
                        }
                        .help("Evaluate current SEO score")
                        
                        // 3. POLISH WITH AI
                        Button(action: {
                            polishContent()
                        }) {
                            Label("Polish with AI", systemImage: "wand.and.stars")
                        }
                        .help("AI-powered content optimization")
                        
                        Button("Done", action: onClose)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                
                Picker("", selection: $selectedTab) {
                    Text("Edit Source").tag(0)
                    Text("Live Preview").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Divider()
                
                if selectedTab == 0 {
                    // EDIT MODE
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Metadata
                            GroupBox(label: Text("Metadata")) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Title:")
                                            .frame(width: 60, alignment: .trailing)
                                        TextField("Article Title", text: $article.title)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .font(.headline)
                                    }
                                    
                                    HStack {
                                        Text("Slug:")
                                            .frame(width: 60, alignment: .trailing)
                                        TextField("url-slug", text: $article.slug)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                    
                                    HStack {
                                        Text("Author:")
                                            .frame(width: 60, alignment: .trailing)
                                        TextField("Author Name", text: Binding(
                                            get: { article.author ?? "Editorial Team" },
                                            set: { article.author = $0 }
                                        ))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                    
                                    HStack(alignment: .top) {
                                         Text("Summary:")
                                            .frame(width: 60, alignment: .trailing)
                                        TextEditor(text: $article.summary)
                                            .frame(height: 60)
                                            .border(Color.gray.opacity(0.2))
                                    }
                                    
                                    // SEO Keywords
                                    if let keywords = article.seoKeywords, !keywords.isEmpty {
                                        Divider()
                                        Text("Ranking Keywords:").font(.caption.bold())
                                        Text(keywords.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    // SEO Recommendations
                                    if let recs = article.seoRecommendations, !recs.isEmpty {
                                        Divider()
                                        Text("Recommendations:").font(.caption.bold())
                                        ForEach(recs.prefix(3), id: \.self) { rec in
                                             Text("• " + rec).font(.caption).foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text("Status:")
                                            .frame(width: 60, alignment: .trailing)
                                        Picker("", selection: $article.status) {
                                            ForEach(ArticleStatus.allCases, id: \.self) { status in
                                                Text(status.rawValue).tag(status)
                                            }
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                    }
                                    
                                    if article.status == .archived {
                                        HStack {
                                            Text("Redirect:")
                                                .frame(width: 60, alignment: .trailing)
                                            TextField("https://...", text: Binding(
                                                get: { article.redirectURL ?? "" },
                                                set: { article.redirectURL = $0.isEmpty ? nil : $0 }
                                            ))
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                    }
                                }
                                .padding()
                            }
                            
                            // SEO SCORE PANEL (Persistent - shows after Check Score)
                            if let analysis = lastAnalysis {
                                GroupBox(label: Label("SEO Analysis", systemImage: "chart.bar.fill")) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        // Big Score Display
                                        HStack(spacing: 16) {
                                            ZStack {
                                                Circle()
                                                    .stroke(scoreColor(analysis.score).opacity(0.3), lineWidth: 8)
                                                    .frame(width: 60, height: 60)
                                                Circle()
                                                    .trim(from: 0, to: CGFloat(analysis.score) / 100.0)
                                                    .stroke(scoreColor(analysis.score), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                                    .frame(width: 60, height: 60)
                                                    .rotationEffect(.degrees(-90))
                                                Text("\(analysis.score)")
                                                    .font(.title2.bold())
                                                    .foregroundColor(scoreColor(analysis.score))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(scoreLabel(analysis.score))
                                                    .font(.headline)
                                                    .foregroundColor(scoreColor(analysis.score))
                                                Text("AI-powered SEO evaluation")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: { lastAnalysis = nil }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.secondary)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .help("Dismiss")
                                        }
                                        
                                        Divider()
                                        
                                        // Analysis Text
                                        Text("Analysis")
                                            .font(.caption.bold())
                                        Text(analysis.analysis)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        // Recommendations
                                        if !analysis.recommendations.isEmpty {
                                            Divider()
                                            Text("Recommendations")
                                                .font(.caption.bold())
                                            ForEach(analysis.recommendations, id: \.self) { rec in
                                                HStack(alignment: .top, spacing: 6) {
                                                    Image(systemName: "arrow.right.circle.fill")
                                                        .foregroundColor(.blue)
                                                        .font(.caption)
                                                    Text(rec)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                }
                                .background(scoreColor(analysis.score).opacity(0.05))
                                .cornerRadius(8)
                            }
                            // Also show saved article score if no fresh analysis
                            else if let savedScore = article.seoScore {
                                GroupBox(label: Label("Last SEO Score", systemImage: "chart.bar")) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .stroke(scoreColor(savedScore).opacity(0.3), lineWidth: 6)
                                                .frame(width: 50, height: 50)
                                            Circle()
                                                .trim(from: 0, to: CGFloat(savedScore) / 100.0)
                                                .stroke(scoreColor(savedScore), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                                .frame(width: 50, height: 50)
                                                .rotationEffect(.degrees(-90))
                                            Text("\(savedScore)")
                                                .font(.headline)
                                                .foregroundColor(scoreColor(savedScore))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(scoreLabel(savedScore))
                                                .font(.subheadline.bold())
                                                .foregroundColor(scoreColor(savedScore))
                                            Text("From last Polish. Click 'Check Score' to refresh.")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(8)
                                }
                            }
                            
                            GroupBox(label: Text("Content (HTML)")) {
                                TextEditor(text: $article.contentHTML)
                                    .font(.system(.body, design: .monospaced))
                                    .disableAutocorrection(true)
                                    .frame(minHeight: 400)
                                    .padding(4)
                            }
                        }
                        .padding()
                    }
                } else {
                    // PREVIEW MODE
                    WebView(html: generatePreviewHTML(article))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .blur(radius: showComparison ? 5 : 0) // Blur editor when comparison is active
            
            // COMPARISON OVERLAY
            if showComparison, let result = pendingPolishedResult {
                 Color.black.opacity(0.6)
                     .edgesIgnoringSafeArea(.all)
                     .onTapGesture { }
                     .transition(.opacity)
                 
                 PolishedResultComparisonView(
                     originalTitle: article.title,
                     originalSlug: article.slug,
                     originalSummary: article.summary,
                     originalHTML: article.contentHTML,
                     result: result,
                     onApply: {
                         article.title = result.title
                         article.slug = result.slug
                         article.summary = result.summary
                         article.contentHTML = result.html
                         article.seoScore = result.seo_score
                         article.seoKeywords = result.keywords
                         article.seoAnalysis = result.analysis
                         article.seoRecommendations = result.recommendations
                         article.seoConflictResolution = result.conflict_resolution
                         showComparison = false
                         pendingPolishedResult = nil
                     },
                     onCancel: {
                         showComparison = false
                         pendingPolishedResult = nil
                     }
                 )
                  

                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .padding(10) // MAXIMIZED SIZE
                 .transition(.scale(scale: 0.99).combined(with: .opacity))
                 .id("comparison-overlay")
            }
        }
        .sheet(isPresented: $showImageAssistant) {
            ImageAssistantView(contentHTML: $article.contentHTML, site: site, onClose: { showImageAssistant = false })
        }
        .alert(item: $activeAlert) { item in
            switch item {
            case .error(let msg):
                return Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
            case .analysis(let analysis):
                 return Alert(
                     title: Text("SEO Score: \(analysis.score)"),
                     message: Text((analysis.analysis) + "\n\nRecommendations:\n" + (analysis.recommendations.joined(separator: "\n- "))),
                     dismissButton: .default(Text("OK"))
                 )
            case .noImagesWarning:
                return Alert(
                    title: Text("⚠️ Missing Images"),
                    message: Text("This article doesn't have any images yet. SEO scores and AI polishing work better with real images. Would you like to add images first?"),
                    primaryButton: .default(Text("Add Images")) {
                        showImageAssistant = true
                    },
                    secondaryButton: .cancel(Text("Continue Anyway")) {
                        analyzeContent()
                    }
                )
            }
        }
    }
    

    
    func analyzeContent() {
        isAnalyzing = true
        
        // Get the correct API key based on provider
        var key = ""
        switch site.aiProvider {
        case "OpenAI", "OpenRouter":
            key = site.openAIKey
        case "Anthropic":
            key = site.anthropicKey
        case "Gemini":
            key = site.geminiKey
        case "Ollama":
            key = "" // Ollama doesn't need a key
        default:
            key = site.openAIKey
        }
        
        // Check if we have a key (except for Ollama)
        if key.isEmpty && site.aiProvider != "Ollama" {
            activeAlert = .error("No API Key found for \(site.aiProvider). Please configure it in Site Settings.")
            isAnalyzing = false
            return
        }
        
        // Check if article has content
        if article.contentHTML.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            activeAlert = .error("Article has no content to analyze. Please add some content first.")
            isAnalyzing = false
            return
        }
        
        AIContentService.shared.analyzeContent(
            contentHTML: article.contentHTML,
            siteName: site.name,
            siteTagline: site.tagline,
            apiKey: key,
            provider: site.aiProvider,
            model: site.aiModel,
            endpointURL: site.ollamaURL
        ) { result in
             DispatchQueue.main.async {
                 isAnalyzing = false
                 switch result {
                 case .success(let analysis):
                     lastAnalysis = analysis
                     // Update article's SEO score
                     article.seoScore = analysis.score
                     activeAlert = .analysis(analysis)
                 case .failure(let error):
                     activeAlert = .error(error.localizedDescription)
                 }
             }
        }
    }
    func polishContent() {
        isPolishing = true
        
        // Get the correct API key based on provider
        var key = ""
        switch site.aiProvider {
        case "OpenAI", "OpenRouter":
            key = site.openAIKey
        case "Anthropic":
            key = site.anthropicKey
        case "Gemini":
            key = site.geminiKey
        case "Ollama":
            key = "" // Ollama doesn't need a key
        default:
            key = site.openAIKey
        }
        
        // DEBUG: Log what we're sending
        print("🚀 [Polish] Starting Polish with AI...")
        print("🚀 [Polish] Provider: \(site.aiProvider), Model: \(site.aiModel)")
        print("🚀 [Polish] API Key present: \(!key.isEmpty)")
        print("🚀 [Polish] Content length: \(article.contentHTML.count) chars")
        
        if key.isEmpty && site.aiProvider != "Ollama" {
            print("❌ [Polish] ERROR: No API key configured!")
            isPolishing = false
            activeAlert = .error("No API key configured for \(site.aiProvider). Go to Site Settings and add your key.")
            return
        }
        
        // Check if article has content
        if article.contentHTML.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("❌ [Polish] ERROR: No content!")
            isPolishing = false
            activeAlert = .error("Article has no content to polish. Please add some content first.")
            return
        }
        
        AIContentService.shared.polishArticle(
            contentHTML: article.contentHTML,
            siteName: site.name,
            siteTagline: site.tagline,
            existingTitles: site.articles.map { $0.title },
            customRules: site.optimizationRules,
            apiKey: key,
            provider: site.aiProvider,
            model: site.aiModel,
            endpointURL: site.ollamaURL
        ) { result in
            DispatchQueue.main.async {
                isPolishing = false
                switch result {
                case .success(let refined):
                    print("✅ [Polish] Success! Title: \(refined.title)")
                    print("✅ [Polish] Score: \(refined.original_score) → \(refined.seo_score)")
                    pendingPolishedResult = refined
                    showComparison = true
                case .failure(let error):
                    print("❌ [Polish] ERROR: \(error.localizedDescription)")
                    activeAlert = .error("Polish failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - SEO Score Helpers
    
    func scoreColor(_ score: Int) -> Color {
        if score >= 80 { return .green }
        if score >= 60 { return .orange }
        return .red
    }
    
    func scoreLabel(_ score: Int) -> String {
        if score >= 90 { return "Excellent" }
        if score >= 80 { return "Good" }
        if score >= 60 { return "Needs Work" }
        if score >= 40 { return "Poor" }
        return "Critical"
    }
    
    func generatePreviewHTML(_ article: Article) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { 
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; 
                    padding: 40px; 
                    line-height: 1.8; 
                    margin: 0 auto; 
                    color: #333; 
                    max-width: 800px; /* Constrain width for readability */
                    background-color: #fff;
                }
                h1 { 
                    border-bottom: 2px solid #f0f0f0; 
                    padding-bottom: 16px; 
                    font-size: 2.25em; 
                    font-weight: 700;
                    margin-bottom: 24px;
                    line-height: 1.2;
                }
                h2 { 
                    margin-top: 40px; 
                    margin-bottom: 16px;
                    font-size: 1.75em; 
                    font-weight: 600;
                    color: #111;
                }
                h3 {
                    margin-top: 32px;
                    margin-bottom: 12px;
                    font-size: 1.4em;
                    font-weight: 600;
                }
                p {
                    margin-bottom: 20px;
                    font-size: 1.1em;
                }
                img { 
                    max-width: 100%; 
                    height: auto; /* Maintain aspect ratio */
                    border-radius: 12px; 
                    box-shadow: 0 4px 12px rgba(0,0,0,0.1); /* Subtle shadow for polish */
                    margin: 24px 0;
                    display: block;
                }
                blockquote { 
                    border-left: 4px solid #007bff; 
                    background: #f8f9fa;
                    margin: 24px 0; 
                    padding: 16px 20px; 
                    color: #444; 
                    font-style: italic;
                    border-radius: 0 8px 8px 0;
                }
                code { 
                    background: #f1f3f5; 
                    padding: 2px 6px; 
                    border-radius: 4px; 
                    font-family: "SF Mono", Menlo, monospace; 
                    font-size: 0.9em;
                    color: #e03131;
                }
                pre {
                    background: #f8f9fa;
                    padding: 16px;
                    border-radius: 8px;
                    overflow-x: auto;
                    border: 1px solid #e9ecef;
                }
                table { 
                    width: 100%; 
                    border-collapse: collapse; 
                    margin: 24px 0; 
                    font-size: 0.95em;
                }
                th, td { 
                    border: 1px solid #e9ecef; 
                    padding: 12px 16px; 
                    text-align: left; 
                }
                th { 
                    background-color: #f8f9fa; 
                    font-weight: 600; 
                }
                a { 
                    color: #007bff; 
                    text-decoration: none; 
                    border-bottom: 1px solid transparent;
                    transition: border-color 0.2s;
                }
                a:hover { 
                    border-bottom-color: #007bff; 
                }
                ul, ol {
                    margin-bottom: 20px;
                    padding-left: 24px;
                }
                li {
                    margin-bottom: 8px;
                }
                .meta {
                    color: #666;
                    font-size: 0.95em;
                    margin-bottom: 32px;
                }
            </style>
        </head>
        <body>
            <h1>\(article.title)</h1>
            <div class="meta">
                By \(article.author)
            </div>
            \(article.contentHTML)
        </body>
        </html>
        """
    }
}
