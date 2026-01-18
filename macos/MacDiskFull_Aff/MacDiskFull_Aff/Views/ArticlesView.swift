
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
                .frame(width: 800, height: 600)
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
    
    var body: some View {
        Form {
            Section(header: Text("Metadata")) {
                TextField("Title", text: $article.title)
                TextField("Slug (URL)", text: $article.slug)
                TextField("Author", text: $article.author)
            }
            
            Section(header: Text("SEO Summary")) {
                TextEditor(text: $article.summary)
                    .frame(height: 80)
            }
            
            Section(header: Text("Content (HTML)")) {
                TextEditor(text: $article.contentHTML)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 400)
            }
            
            Section(header: Text("Preview")) {
                // Formatting tips
                Text("Use <h3> for headings, <p> for paragraphs.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .navigationTitle("Edit Article")
    }
}
