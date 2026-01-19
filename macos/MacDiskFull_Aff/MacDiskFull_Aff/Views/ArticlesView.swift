
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
        List {
            ForEach(site.articles) { article in
                Button(action: { editingArticleId = article.id }) {
                    VStack(alignment: .leading) {
                        Text(article.title)
                            .font(.headline)
                        Text(article.slug)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onDelete(perform: delete)
        }
        .listStyle(InsetListStyle())
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
                site.articles.append(newArticle)
            }
        }
        .sheet(item: Binding(
            get: { editingArticleId.map { WrappedUUID(uuid: $0) } },
            set: { editingArticleId = $0?.uuid }
        )) { wrappedId in
            if let index = site.articles.firstIndex(where: { $0.id == wrappedId.uuid }) {
                ArticleEditorView(site: $site, article: $site.articles[index]) {
                    editingArticleId = nil
                }
                .frame(minWidth: 1000, minHeight: 800)
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
        site.articles.append(newArticle)
        editingArticleId = newArticle.id // Auto-open
    }
    


    func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url, let content = try? String(contentsOf: url, encoding: .utf8) {
                        DispatchQueue.main.async {
                            let article = parseMarkdownToArticle(content, filename: url.deletingPathExtension().lastPathComponent)
                            site.articles.append(article)
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
    
    // Basic formatting from Perplexity/Markdown to App HTML
    func parseMarkdownToArticle(_ rawContent: String, filename: String) -> Article {
        var lines = rawContent.components(separatedBy: .newlines)
        
        // 1. Extract Title (First line if it starts with #, or filename)
        var title = filename.replacingOccurrences(of: "-", with: " ").capitalized
        if let first = lines.first, first.hasPrefix("# ") {
            title = String(first.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            lines.removeFirst() // Remove title from body
        }
        
        // 2. Extract Summary (First paragraph)
        var summary = "No summary available."
        // Find first non-empty line
        if let introIndex = lines.firstIndex(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) {
            summary = lines[introIndex]
        }
        
        // 3. Convert Body to HTML
        var html = ""
        var inList = false
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.isEmpty {
                if inList { html += "</ul>\n"; inList = false }
                continue
            }
            
            // Headers
            if trimmed.hasPrefix("## ") {
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
            // Numbered Lists
            else if trimmed.range(of: "^\\d+\\. ", options: .regularExpression) != nil {
                 // Simple hack: treat numbered lists as ul for now to avoid complexity, or just wrap in <p> if lazy. 
                 // Let's standardizes on bullet points for simplicity or implement <ol> logic if strictly needed.
                 // For now, treat as paragraph line or list item.
                 html += "<p>\(processInlineFormatting(trimmed))</p>\n"
            }
            // Paragraphs
            else {
                if inList { html += "</ul>\n"; inList = false }
                html += "<p>\(processInlineFormatting(trimmed))</p>\n"
            }
        }
        
        if inList { html += "</ul>\n" }
        
        return Article(
            title: title,
            slug: title.lowercased().replacingOccurrences(of: " ", with: "-").filter { "abcdefghijklmnopqrstuvwxyz0123456789-".contains($0) },
            summary: summary,
            contentHTML: html
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
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Custom Header
            HStack {
                Text(selectedTab == 0 ? "Edit Article" : "Preview")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if isPolishing {
                    ProgressView("Polishing...")
                        .scaleEffect(0.8)
                } else {
                    Button(action: polishContent) {
                        Label("Polish with AI", systemImage: "wand.and.stars")
                    }
                    .help("Refine formatting and remove meta-text using AI")
                }
                
                Button("Done") {
                    onClose()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
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
                    VStack(spacing: 16) {
                        GroupBox(label: Text("Metadata")) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Title:")
                                        .frame(width: 60, alignment: .trailing)
                                    TextField("Title", text: $article.title)
                                }
                                HStack {
                                    Text("Slug:")
                                        .frame(width: 60, alignment: .trailing)
                                    TextField("Slug (URL)", text: $article.slug)
                                }
                                HStack {
                                    Text("Author:")
                                        .frame(width: 60, alignment: .trailing)
                                    TextField("Author", text: $article.author)
                                }
                                HStack(alignment: .top) {
                                     Text("Summary:")
                                        .frame(width: 60, alignment: .trailing)
                                    TextEditor(text: $article.summary)
                                        .frame(height: 60)
                                        .border(Color.gray.opacity(0.2))
                                }
                            }
                            .padding()
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
        // Removed navigationTitle modifier as we have a custom header
    }
    
    func polishContent() {
        isPolishing = true
        var key = site.openAIKey
        if site.aiProvider == "Anthropic" { key = site.anthropicKey }
        
        AIContentService.shared.polishArticle(
            contentHTML: article.contentHTML,
            apiKey: key,
            provider: site.aiProvider,
            model: site.aiModel,
            endpointURL: site.ollamaURL
        ) { result in
            DispatchQueue.main.async {
                isPolishing = false
                switch result {
                case .success(let refined):
                    article.contentHTML = refined
                case .failure(let error):
                    print("Polish error: \(error.localizedDescription)")
                    // Optional: Show alert
                }
            }
        }
    }
    
    func generatePreviewHTML(_ article: Article) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: -apple-system, sans-serif; padding: 40px; line-height: 1.6; margin: 0; color: #333; }
                h1 { border-bottom: 2px solid #eee; padding-bottom: 10px; font-size: 2.5em; }
                h2 { margin-top: 30px; font-size: 1.8em; }
                img { max-width: 100%; border-radius: 8px; }
                blockquote { border-left: 4px solid #ccc; margin: 0; padding-left: 16px; color: #666; font-style: italic; }
                code { background: #f4f4f4; padding: 2px 5px; border-radius: 4px; font-family: monospace; }
                table { width: 100%; border-collapse: collapse; margin: 20px 0; }
                th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
                th { background-color: #f7f7f7; font-weight: bold; }
                a { color: #0066cc; text-decoration: none; }
                a:hover { text-decoration: underline; }
                .btn { display: inline-block; padding: 8px 16px; background: #007bff; color: white; border-radius: 4px; text-decoration: none; margin-top: 5px; }
            </style>
        </head>
        <body>
            <h1>\(article.title)</h1>
            <p style="color: #666;"><em>By \(article.author)</em></p>
            <hr>
            \(article.contentHTML)
        </body>
        </html>
        """
    }
}
