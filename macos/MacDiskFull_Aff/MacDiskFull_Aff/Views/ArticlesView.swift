
//
//  ArticlesView.swift
//  WebMakr
//
//  Manage Blog Articles (CMS)
//

import SwiftUI

struct ArticlesView: View {
    @Binding var site: Site
    @State private var editingArticleId: UUID?
    
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
        .navigationTitle("Articles")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addArticle) {
                    Label("Add Article", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .automatic) {
                Button("Restore Defaults") {
                    // Reset to the beefed up seeded content
                    site.articles = Site(name: "", tagline: "", domain: "", affiliateSettings: AffiliateSettings(), products: []).articles // Accessing default or sample
                    // Ideally use static sample
                    let sample = Site.sampleMacDiskFull
                    site.articles = sample.articles
                }
                .help("Reloads the high-quality default articles")
            }
        }
        .sheet(item: Binding(
            get: { editingArticleId.map { WrappedUUID(uuid: $0) } },
            set: { editingArticleId = $0?.uuid }
        )) { wrappedId in
            if let index = site.articles.firstIndex(where: { $0.id == wrappedId.uuid }) {
                NavigationView {
                    ArticleEditorView(article: $site.articles[index])
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { editingArticleId = nil }
                            }
                        }
                }
                .frame(width: 900, height: 700)
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
}

// UUID wrapper for Sheet .item
struct WrappedUUID: Identifiable {
    let uuid: UUID
    var id: UUID { uuid }
}

struct ArticleEditorView: View {
    @Binding var article: Article
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 16) {
            
            Picker("", selection: $selectedTab) {
                Text("Edit Source").tag(0)
                Text("Live Preview").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if selectedTab == 0 {
                // EDIT MODE
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
                            .padding(4)
                    }
                }
                .padding(.horizontal)
                
            } else {
                // PREVIEW MODE
                WebView(html: generatePreviewHTML(article))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding()
            }
        }
        .padding(.vertical)
        .navigationTitle(selectedTab == 0 ? "Edit Article" : "Preview")
    }
    
    func generatePreviewHTML(_ article: Article) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: -apple-system, sans-serif; padding: 20px; line-height: 1.6; max-width: 700px; margin: 0 auto; color: #333; }
                h1 { border-bottom: 2px solid #eee; padding-bottom: 10px; }
                img { max-width: 100%; border-radius: 8px; }
                blockquote { border-left: 4px solid #ccc; margin: 0; padding-left: 16px; color: #666; }
                code { background: #f4f4f4; padding: 2px 5px; border-radius: 4px; font-family: monospace; }
                table { width: 100%; border-collapse: collapse; margin: 20px 0; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
            </style>
        </head>
        <body>
            <h1>\(article.title)</h1>
            <p><em>By \(article.author)</em></p>
            <hr>
            \(article.contentHTML)
        </body>
        </html>
        """
    }
}
